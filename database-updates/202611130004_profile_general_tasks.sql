-- Impulso alpha.7. Pré-requisitos: alpha.1 a alpha.6 no banco; backup antes de aplicar.
begin;
create table impulso_private.student_profiles (
  student_id uuid primary key references impulso_private.students(id) on delete cascade,
  username text not null default '' check(length(username)<=32),
  avatar text not null default 'fox' check(avatar in ('fox','cat','owl','panda','rabbit','bear'))
);
create table impulso_private.general_tasks (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references impulso_private.teachers(user_id),
  name text not null check(length(name) between 1 and 200), deadline date not null, created_at timestamptz not null default now()
);
create table impulso_private.general_task_progress (
  task_id uuid not null references impulso_private.general_tasks(id) on delete cascade,
  team_id uuid not null references impulso_private.teams(id) on delete cascade,
  status text not null default 'pending' check(status in ('pending','delivered')),
  link text not null default '' check(link='' or (length(link)<=2048 and link ~* '^https?://[^[:space:]]+$')),
  notes text not null default '' check(length(notes)<=10000),
  primary key(task_id,team_id)
);
create table impulso_private.project_reviews (
  id bigint generated always as identity primary key,
  project_id uuid not null references impulso_private.projects(id) on delete cascade,
  submitted_name text not null, submitted_link text not null,
  status text not null default 'pending' check(status in ('pending','approved','rejected')),
  feedback text not null default '' check(length(feedback)<=5000),
  submitted_at timestamptz not null default now(), reviewed_at timestamptz
);
-- Projetos anteriores permanecem intactos e começam aguardando revisão.
insert into impulso_private.project_reviews(project_id,submitted_name,submitted_link)
select id,name,link from impulso_private.projects;
alter table impulso_private.project_reviews enable row level security;
revoke all on impulso_private.project_reviews from public,anon,authenticated;
alter table impulso_private.student_profiles enable row level security;
alter table impulso_private.general_tasks enable row level security;
alter table impulso_private.general_task_progress enable row level security;
revoke all on impulso_private.student_profiles,impulso_private.general_tasks,impulso_private.general_task_progress from public,anon,authenticated;

-- Validação também no servidor; URLs anteriores são preservadas.
alter function public.impulso(text,jsonb) rename to impulso_alpha2_gate;
revoke all on function public.impulso_alpha2_gate(text,jsonb) from public,anon,authenticated;
create function public.impulso(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare old_id uuid; old_name text; old_link text; new_id uuid; new_name text; new_link text; result jsonb;
begin
  if op='save_project' then
    if trim(coalesce(data->>'link','')) !~ '^https://plataforma[.]gpinovacao[.]senai[.]br/plataforma/demandas-da-industria/interna/[0-9]+$' then
      raise exception 'Use o link completo da demanda da indústria na Saga, terminando no número da demanda.';
    end if;
    select p.id,p.name,p.link into old_id,old_name,old_link
    from impulso_private.projects p join impulso_private.members m on m.team_id=p.team_id
    join impulso_private.students s on s.id=m.student_id where s.user_id=auth.uid() for update of p;
  end if;
  result:=public.impulso_alpha2_gate(op,data);
  if op='save_project' then
    select p.id,p.name,p.link into new_id,new_name,new_link
    from impulso_private.projects p join impulso_private.members m on m.team_id=p.team_id
    join impulso_private.students s on s.id=m.student_id where s.user_id=auth.uid();
    if new_id is not null and (old_id is null or old_name is distinct from new_name or old_link is distinct from new_link) then
      insert into impulso_private.project_reviews(project_id,submitted_name,submitted_link) values(new_id,new_name,new_link);
    end if;
  end if;
  return result;
end $$;
revoke all on function public.impulso(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso(text,jsonb) to authenticated;

-- O resultado de load do backend existente estabelece identidade, papel e grupos
-- autorizados, e também mantém o bloqueio até a troca da senha inicial.
create function public.impulso_extras(op text, data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare base jsonb; u uuid:=auth.uid(); teacher uuid; sid uuid; tid uuid; is_teacher boolean; def_id uuid; n text; d date; l text; notes text; st text; uname text; avatar text; projectid uuid; reviewid bigint; msg text;
begin
  base:=public.impulso('load','{}'::jsonb);
  if coalesce((base->>'password_change_required')::boolean,false) then raise exception 'Troque sua senha inicial antes de continuar.'; end if;
  is_teacher:=(base->>'role'='professor');
  if is_teacher then teacher:=u;
  else
    select s.id,s.teacher_id into sid,teacher from impulso_private.students s where s.user_id=u;
    if sid is null then raise exception 'Aluno não encontrado.'; end if;
    select m.team_id into tid from impulso_private.members m where m.student_id=sid;
  end if;
  if op='load' then
    return jsonb_build_object(
      'profile',case when is_teacher then null else coalesce((select jsonb_build_object('username',p.username,'avatar',p.avatar) from impulso_private.student_profiles p where p.student_id=sid),jsonb_build_object('username','','avatar','fox')) end,
      'general_definitions',case when is_teacher then coalesce((select jsonb_agg(jsonb_build_object('id',g.id,'name',g.name,'deadline',g.deadline) order by g.deadline,g.name) from impulso_private.general_tasks g where g.teacher_id=teacher),'[]'::jsonb) else '[]'::jsonb end,
      'reviews',coalesce((select jsonb_agg(jsonb_build_object('project_id',p.id,'status',r.status,'feedback',r.feedback,'history',(select coalesce(jsonb_agg(jsonb_build_object('name',h.submitted_name,'link',h.submitted_link,'status',h.status,'feedback',h.feedback,'submitted_at',h.submitted_at,'reviewed_at',h.reviewed_at) order by h.id desc),'[]'::jsonb) from impulso_private.project_reviews h where h.project_id=p.id))) from impulso_private.projects p join impulso_private.teams t on t.id=p.team_id join lateral (select * from impulso_private.project_reviews rr where rr.project_id=p.id order by rr.id desc limit 1) r on true where t.teacher_id=teacher and (is_teacher or t.id=tid)),'[]'::jsonb),
      'general_tasks',coalesce((select jsonb_agg(jsonb_build_object('id',g.id,'name',g.name,'deadline',g.deadline,'team_id',t.id,'team_name',t.name,'status',coalesce(p.status,'pending'),'link',coalesce(p.link,''),'notes',coalesce(p.notes,'')) order by g.deadline,g.name,t.name) from impulso_private.general_tasks g join impulso_private.teams t on t.teacher_id=g.teacher_id left join impulso_private.general_task_progress p on p.task_id=g.id and p.team_id=t.id where g.teacher_id=teacher and (is_teacher or t.id=tid)),'[]'::jsonb));
  elsif op='review_project' then
    if not is_teacher then raise exception 'Somente a professora pode avaliar demandas.'; end if;
    projectid:=(data->>'project_id')::uuid; st:=coalesce(data->>'status',''); msg:=trim(coalesce(data->>'feedback',''));
    if st not in ('approved','rejected') or length(msg)>5000 or (st='rejected' and length(msg)=0) then raise exception 'Informe a decisão e, em caso de reprovação, o motivo.'; end if;
    perform 1 from impulso_private.projects p join impulso_private.teams t on t.id=p.team_id where p.id=projectid and t.teacher_id=teacher for update of p;
    if not found then raise exception 'Demanda não encontrada.'; end if;
    select r.id into reviewid from impulso_private.project_reviews r where r.project_id=projectid order by r.id desc limit 1 for update;
    if reviewid is null or not exists(select 1 from impulso_private.project_reviews r where r.id=reviewid and r.status='pending') then raise exception 'Esta demanda não está aguardando avaliação.'; end if;
    update impulso_private.project_reviews set status=st,feedback=msg,reviewed_at=now() where id=reviewid;
    return jsonb_build_object('ok',true);
  elsif op='save_profile' then
    if is_teacher then raise exception 'Perfil disponível apenas para alunos.'; end if;
    uname:=trim(coalesce(data->>'username','')); avatar:=coalesce(data->>'avatar','');
    if length(uname)>32 or (length(uname)>0 and length(uname)<2) or uname ~ '[[:cntrl:]]' then raise exception 'O nome de usuário deve ter de 2 a 32 caracteres, ou ficar vazio.'; end if;
    if avatar not in ('fox','cat','owl','panda','rabbit','bear') then raise exception 'Escolha um avatar disponível.'; end if;
    insert into impulso_private.student_profiles(student_id,username,avatar) values(sid,uname,avatar) on conflict(student_id) do update set username=excluded.username,avatar=excluded.avatar;
    return jsonb_build_object('ok',true);
  elsif op='create_general_task' then
    if not is_teacher then raise exception 'Somente a professora pode criar tarefas gerais.'; end if;
    n:=trim(coalesce(data->>'name','')); if length(n) not between 1 and 200 then raise exception 'Informe o nome da tarefa.'; end if;
    d:=(data->>'deadline')::date; if d is null then raise exception 'Informe o prazo.'; end if;
    insert into impulso_private.general_tasks(teacher_id,name,deadline) values(teacher,n,d);
    return jsonb_build_object('ok',true);
  elsif op='save_general_progress' then
    def_id:=(data->>'task_id')::uuid; tid:= (data->>'team_id')::uuid;
    if not exists(select 1 from impulso_private.general_tasks g join impulso_private.teams t on t.teacher_id=g.teacher_id where g.id=def_id and t.id=tid and g.teacher_id=teacher and (is_teacher or exists(select 1 from impulso_private.members m where m.student_id=sid and m.team_id=t.id))) then raise exception 'Tarefa ou grupo não encontrado.'; end if;
    st:=coalesce(data->>'status',''); l:=trim(coalesce(data->>'link','')); notes:=coalesce(data->>'notes','');
    if st not in ('pending','delivered') or length(l)>2048 or (l<>'' and l !~* '^https?://[^[:space:]]+$') or length(notes)>10000 then raise exception 'Confira a situação, o link e as observações.'; end if;
    insert into impulso_private.general_task_progress(task_id,team_id,status,link,notes) values(def_id,tid,st,l,notes) on conflict(task_id,team_id) do update set status=excluded.status,link=excluded.link,notes=excluded.notes;
    return jsonb_build_object('ok',true);
  end if;
  raise exception 'Ação desconhecida.';
end $$;
revoke all on function public.impulso_extras(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso_extras(text,jsonb) to authenticated;
commit;
notify pgrst,'reload schema';
