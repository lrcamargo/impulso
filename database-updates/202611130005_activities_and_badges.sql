-- alpha.8: atividades da professora, tarefas do grupo e medalhas.
-- Requer alpha.7. Faça backup e interrompa o uso do site durante a atualização.
begin;
lock table impulso_private.tasks, impulso_private.general_tasks, impulso_private.general_task_progress in share mode;
create table impulso_private.learning_badges(
 id uuid primary key default gen_random_uuid(), teacher_id uuid not null references impulso_private.teachers(user_id),
 name text not null check(length(name) between 1 and 100), icon text not null check(icon in ('star','bulb','group','flag','rocket')), created_at timestamptz not null default now()
);
create table impulso_private.learning_activities(
 id uuid primary key default gen_random_uuid(), teacher_id uuid not null references impulso_private.teachers(user_id),
 name text not null check(length(name) between 1 and 200), description text not null default '' check(length(description)<=5000), deadline date not null,
 team_id uuid references impulso_private.teams(id), project_id uuid references impulso_private.projects(id),
 points_enabled boolean not null default false, badge_id uuid references impulso_private.learning_badges(id), badge_mode text not null default 'approval' check(badge_mode in ('auto','approval')),
 created_at timestamptz not null default now()
);
create table impulso_private.learning_activity_progress(
 activity_id uuid not null references impulso_private.learning_activities(id), team_id uuid not null references impulso_private.teams(id),
 status text not null default 'pending' check(status in ('pending','delivered')),
 link text not null default '' check(link='' or (length(link)<=2048 and link ~* '^https?://[^[:space:]]+$')),
 notes text not null default '' check(length(notes)<=10000), primary key(activity_id,team_id)
);
create table impulso_private.learning_subtasks(
 id uuid primary key default gen_random_uuid(),activity_id uuid not null references impulso_private.learning_activities(id), team_id uuid not null references impulso_private.teams(id),
 name text not null check(length(name) between 1 and 200), assigned_student_id uuid references impulso_private.students(id),
 status text not null default 'pending' check(status in ('pending','done')), created_at timestamptz not null default now()
);
create table impulso_private.learning_badge_awards(
 badge_id uuid not null references impulso_private.learning_badges(id), student_id uuid not null references impulso_private.students(id),
 source text not null check(source in ('automatic','teacher','approved')), awarded_at timestamptz not null default now(), primary key(badge_id,student_id)
);
create table impulso_private.learning_badge_requests(
 id uuid primary key default gen_random_uuid(),activity_id uuid not null references impulso_private.learning_activities(id),team_id uuid not null references impulso_private.teams(id),
 badge_id uuid not null references impulso_private.learning_badges(id),student_id uuid not null references impulso_private.students(id),
 status text not null default 'pending' check(status in ('pending','approved','rejected','cancelled')),created_at timestamptz not null default now(),decided_at timestamptz,
 unique(activity_id,team_id,badge_id,student_id)
);
alter table impulso_private.learning_badges enable row level security;
alter table impulso_private.learning_activities enable row level security;
alter table impulso_private.learning_activity_progress enable row level security;
alter table impulso_private.learning_subtasks enable row level security;
alter table impulso_private.learning_badge_awards enable row level security;
alter table impulso_private.learning_badge_requests enable row level security;
revoke all on impulso_private.learning_badges,impulso_private.learning_activities,impulso_private.learning_activity_progress,impulso_private.learning_subtasks,impulso_private.learning_badge_awards,impulso_private.learning_badge_requests from public,anon,authenticated;

-- Copiar os dados existentes sem excluí-los. Depois, desativar alterações na
-- interface/RPC antiga para evitar dois registros divergentes.
insert into impulso_private.learning_activities(id,teacher_id,name,deadline,created_at)
select id,teacher_id,name,deadline,created_at from impulso_private.general_tasks;
insert into impulso_private.learning_activities(id,teacher_id,name,deadline,team_id,project_id,points_enabled,created_at)
select x.id,t.teacher_id,x.name,x.deadline,t.id,p.id,true,x.created_at from impulso_private.tasks x join impulso_private.projects p on p.id=x.project_id join impulso_private.teams t on t.id=p.team_id;
insert into impulso_private.learning_activity_progress(activity_id,team_id,status,link,notes)
select task_id,team_id,status,link,notes from impulso_private.general_task_progress;
insert into impulso_private.learning_activity_progress(activity_id,team_id,status,link,notes)
select x.id,t.id,x.status,x.link,x.notes from impulso_private.tasks x join impulso_private.projects p on p.id=x.project_id join impulso_private.teams t on t.id=p.team_id;

alter function public.impulso(text,jsonb) rename to impulso_v7;
revoke all on function public.impulso_v7(text,jsonb) from public,anon,authenticated;
create function public.impulso(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
begin
 if op='save_task' then raise exception 'Use a nova página de atividades para registrar alterações.'; end if;
 return public.impulso_v7(op,data);
end $$;
revoke all on function public.impulso(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso(text,jsonb) to authenticated;
alter function public.impulso_extras(text,jsonb) rename to impulso_extras_v7;
revoke all on function public.impulso_extras_v7(text,jsonb) from public,anon,authenticated;
create function public.impulso_extras(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
begin
 if op in ('create_general_task','save_general_progress') then raise exception 'Use a nova página de atividades para registrar alterações.'; end if;
 return public.impulso_extras_v7(op,data);
end $$;
revoke all on function public.impulso_extras(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso_extras(text,jsonb) to authenticated;

create function public.impulso_learning(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare base jsonb; u uuid:=auth.uid(); teacher uuid; sid uuid; tid uuid; is_teacher boolean; a impulso_private.learning_activities%rowtype; bid uuid; aid uuid; subid uuid; target uuid; projectid uuid; n text; des text; ic text; mode text; st text; l text; notes text; d date; requestid uuid;
begin
 base:=public.impulso('load','{}'::jsonb);
 if coalesce((base->>'password_change_required')::boolean,false) then raise exception 'Troque a senha inicial.'; end if;
 is_teacher:=(base->>'role'='professor');
 if is_teacher then teacher:=u; else select id,teacher_id into sid,teacher from impulso_private.students where user_id=u; if sid is null then raise exception 'Aluno não encontrado.'; end if; select team_id into tid from impulso_private.members where student_id=sid; end if;
 if op='load' then
   return jsonb_build_object(
    'definitions',case when is_teacher then coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'name',x.name,'description',x.description,'deadline',x.deadline,'team_id',x.team_id,'project_id',x.project_id,'badge_id',x.badge_id,'badge_mode',x.badge_mode) order by x.deadline,x.name) from impulso_private.learning_activities x where x.teacher_id=teacher),'[]'::jsonb) else '[]'::jsonb end,
    'activities',coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'name',x.name,'description',x.description,'deadline',x.deadline,'team_id',t.id,'team_name',t.name,'project_id',x.project_id,'badge_id',x.badge_id,'points_enabled',x.points_enabled,'badge_name',b.name,'badge_mode',x.badge_mode,'status',coalesce(p.status,'pending'),'link',coalesce(p.link,''),'notes',coalesce(p.notes,'')) order by x.deadline,x.name,t.name) from impulso_private.learning_activities x join impulso_private.teams t on t.teacher_id=x.teacher_id and (x.team_id is null or x.team_id=t.id) left join impulso_private.learning_activity_progress p on p.activity_id=x.id and p.team_id=t.id left join impulso_private.learning_badges b on b.id=x.badge_id where x.teacher_id=teacher and (is_teacher or t.id=tid)),'[]'::jsonb),
    'subtasks',coalesce((select jsonb_agg(jsonb_build_object('id',q.id,'activity_id',q.activity_id,'team_id',q.team_id,'name',q.name,'status',q.status,'assigned_student_id',q.assigned_student_id,'assigned_name',s.name) order by q.created_at) from impulso_private.learning_subtasks q join impulso_private.teams t on t.id=q.team_id left join impulso_private.students s on s.id=q.assigned_student_id where t.teacher_id=teacher and (is_teacher or t.id=tid)),'[]'::jsonb),
    'badges',case when is_teacher then coalesce((select jsonb_agg(jsonb_build_object('id',b.id,'name',b.name,'icon',b.icon) order by b.name) from impulso_private.learning_badges b where b.teacher_id=teacher),'[]'::jsonb) else coalesce((select jsonb_agg(jsonb_build_object('id',b.id,'name',b.name,'icon',b.icon,'awarded_at',w.awarded_at) order by w.awarded_at desc) from impulso_private.learning_badge_awards w join impulso_private.learning_badges b on b.id=w.badge_id where w.student_id=sid),'[]'::jsonb) end,
    'requests',case when is_teacher then coalesce((select jsonb_agg(jsonb_build_object('id',r.id,'student_name',s.name,'badge_name',b.name,'team_name',t.name,'activity_name',x.name) order by r.created_at) from impulso_private.learning_badge_requests r join impulso_private.students s on s.id=r.student_id join impulso_private.learning_badges b on b.id=r.badge_id join impulso_private.learning_activities x on x.id=r.activity_id join impulso_private.teams t on t.id=r.team_id where x.teacher_id=teacher and r.status='pending'),'[]'::jsonb) else '[]'::jsonb end);
 elsif op='save_badge' then
   if not is_teacher then raise exception 'Somente a professora pode criar medalhas.'; end if;
   n:=trim(coalesce(data->>'name',''));ic:=coalesce(data->>'icon','');if length(n) not between 1 and 100 or ic not in ('star','bulb','group','flag','rocket') then raise exception 'Confira o nome e o símbolo da medalha.'; end if;
   bid:=nullif(data->>'id','')::uuid;
   if bid is null then insert into impulso_private.learning_badges(teacher_id,name,icon) values(teacher,n,ic);
   else update impulso_private.learning_badges set name=n,icon=ic where id=bid and teacher_id=teacher;
     if not found then raise exception 'Medalha não encontrada.'; end if;
   end if;
   return jsonb_build_object('ok',true);
 elsif op='grant_badge' then
   if not is_teacher then raise exception 'Somente a professora pode atribuir medalhas.'; end if;
   bid:=(data->>'badge_id')::uuid; target:=(data->>'student_id')::uuid;
   if not exists(select 1 from impulso_private.learning_badges where id=bid and teacher_id=teacher) or not exists(select 1 from impulso_private.students where id=target and teacher_id=teacher) then raise exception 'Aluno ou medalha não encontrado.'; end if;
   insert into impulso_private.learning_badge_awards(badge_id,student_id,source) values(bid,target,'teacher') on conflict do nothing;
   update impulso_private.learning_badge_requests r set status='approved',decided_at=now() where r.badge_id=bid and r.student_id=target and r.status='pending';return jsonb_build_object('ok',true);
 elsif op='decide_badge' then
   if not is_teacher then raise exception 'Somente a professora pode avaliar medalhas.'; end if;
   requestid:=(data->>'id')::uuid;st:=coalesce(data->>'status','');if st not in ('approved','rejected') then raise exception 'Decisão inválida.'; end if;
   select r.badge_id,r.student_id into bid,target from impulso_private.learning_badge_requests r join impulso_private.learning_activities x on x.id=r.activity_id where r.id=requestid and x.teacher_id=teacher and r.status='pending' for update of r;
   if not found then raise exception 'Solicitação não encontrada ou já decidida.'; end if;
   update impulso_private.learning_badge_requests set status=st,decided_at=now() where id=requestid;
   if st='approved' then insert into impulso_private.learning_badge_awards(badge_id,student_id,source) values(bid,target,'approved') on conflict do nothing; end if;
   return jsonb_build_object('ok',true);
 elsif op='save_activity' then
   if not is_teacher then raise exception 'Somente a professora pode criar ou editar atividades.'; end if;
   n:=trim(coalesce(data->>'name',''));des:=trim(coalesce(data->>'description',''));d:=(data->>'deadline')::date;
   bid:=nullif(data->>'badge_id','')::uuid;mode:=coalesce(data->>'badge_mode','approval');
   if length(n) not between 1 and 200 or length(des)>5000 or d is null or mode not in ('auto','approval') then raise exception 'Confira nome, prazo e regras da atividade.'; end if;
   if bid is not null and not exists(select 1 from impulso_private.learning_badges where id=bid and teacher_id=teacher) then raise exception 'Medalha não encontrada.'; end if;
   aid:=nullif(data->>'id','')::uuid;
   if aid is null then
     projectid:=nullif(data->>'project_id','')::uuid;tid:=null;
     if projectid is not null then select t.id into tid from impulso_private.projects p join impulso_private.teams t on t.id=p.team_id where p.id=projectid and t.teacher_id=teacher; if tid is null then raise exception 'Demanda não encontrada.'; end if; end if;
     insert into impulso_private.learning_activities(teacher_id,name,description,deadline,team_id,project_id,badge_id,badge_mode) values(teacher,n,des,d,tid,projectid,bid,mode);
   else
     select * into a from impulso_private.learning_activities where id=aid and teacher_id=teacher for update;
     if not found then raise exception 'Atividade não encontrada.'; end if;
     if a.badge_id is distinct from bid or a.badge_mode is distinct from mode then
       update impulso_private.learning_badge_requests set status='cancelled',decided_at=now() where activity_id=aid and status='pending';
     end if;
     update impulso_private.learning_activities set name=n,description=des,deadline=d,badge_id=bid,badge_mode=mode where id=aid;
   end if;
   return jsonb_build_object('ok',true);
 elsif op in ('save_progress','save_subtask','toggle_subtask') then
   aid:=(data->>'activity_id')::uuid;target:=(data->>'team_id')::uuid;
   select x.* into a from impulso_private.learning_activities x join impulso_private.teams t on t.teacher_id=x.teacher_id and (x.team_id is null or x.team_id=t.id) where x.id=aid and t.id=target and x.teacher_id=teacher and (is_teacher or exists(select 1 from impulso_private.members m where m.student_id=sid and m.team_id=t.id)) for update of x;
   if not found then raise exception 'Atividade ou grupo não encontrado.'; end if;
   if op='save_progress' then
     st:=coalesce(data->>'status','');l:=trim(coalesce(data->>'link',''));notes:=coalesce(data->>'notes','');
     if st not in ('pending','delivered') or length(l)>2048 or (l<>'' and l !~* '^https?://[^[:space:]]+$') or length(notes)>10000 then raise exception 'Confira a situação, link e observações.'; end if;
     insert into impulso_private.learning_activity_progress(activity_id,team_id,status,link,notes) values(aid,target,st,l,notes) on conflict(activity_id,team_id) do update set status=excluded.status,link=excluded.link,notes=excluded.notes;
     if st='pending' then update impulso_private.learning_badge_requests set status='cancelled',decided_at=now() where activity_id=aid and team_id=target and status='pending';
     elsif a.badge_id is not null then
       if a.badge_mode='auto' then
         insert into impulso_private.learning_badge_awards(badge_id,student_id,source) select a.badge_id,m.student_id,'automatic' from impulso_private.members m where m.team_id=target on conflict do nothing;
       else
         insert into impulso_private.learning_badge_requests(activity_id,team_id,badge_id,student_id) select aid,target,a.badge_id,m.student_id from impulso_private.members m where m.team_id=target and not exists(select 1 from impulso_private.learning_badge_awards w where w.badge_id=a.badge_id and w.student_id=m.student_id) on conflict(activity_id,team_id,badge_id,student_id) do update set status='pending',decided_at=null where impulso_private.learning_badge_requests.status='cancelled';
       end if;
     end if;
     return jsonb_build_object('ok',true);
   elsif op='save_subtask' then
     if is_teacher then raise exception 'As tarefas são criadas pelo grupo.'; end if;
     n:=trim(coalesce(data->>'name',''));subid:=nullif(data->>'id','')::uuid;bid:=nullif(data->>'assigned_student_id','')::uuid;
     if length(n) not between 1 and 200 then raise exception 'Informe o nome da tarefa.'; end if;
     if bid is not null and not exists(select 1 from impulso_private.members m where m.team_id=target and m.student_id=bid) then raise exception 'Escolha um integrante do seu grupo.'; end if;
     if subid is null then insert into impulso_private.learning_subtasks(activity_id,team_id,name,assigned_student_id) values(aid,target,n,bid); else update impulso_private.learning_subtasks set name=n,assigned_student_id=bid where id=subid and activity_id=aid and team_id=target; if not found then raise exception 'Tarefa não encontrada.'; end if; end if;
     return jsonb_build_object('ok',true);
   else
     subid:=(data->>'id')::uuid;st:=coalesce(data->>'status','');if st not in ('pending','done') then raise exception 'Situação inválida.'; end if;
     update impulso_private.learning_subtasks set status=st where id=subid and activity_id=aid and team_id=target;
     if not found then raise exception 'Tarefa não encontrada.'; end if;return jsonb_build_object('ok',true);
   end if;
 end if;
 raise exception 'Ação desconhecida.';
end $$;
revoke all on function public.impulso_learning(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso_learning(text,jsonb) to authenticated;
commit;
notify pgrst,'reload schema';
