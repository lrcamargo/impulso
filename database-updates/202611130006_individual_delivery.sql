-- Alpha.9: entregas por integrante, painel do aluno e medalhas de marcos.
-- Exige alpha.8 já aplicada. Faça backup e interrompa o uso durante a atualização.
begin;
alter table impulso_private.learning_activities add column delivery_mode text not null default 'group' check(delivery_mode in ('group','everyone'));
create table impulso_private.learning_individual_deliveries(
 activity_id uuid not null references impulso_private.learning_activities(id),team_id uuid not null references impulso_private.teams(id),student_id uuid not null references impulso_private.students(id),
 status text not null default 'pending' check(status in ('pending','delivered')),
 link text not null default '' check(link='' or (length(link)<=2048 and link ~* '^https?://[^[:space:]]+$')),
 notes text not null default '' check(length(notes)<=10000),updated_at timestamptz not null default now(),primary key(activity_id,team_id,student_id)
);
create table impulso_private.milestone_medals(
 student_id uuid not null references impulso_private.students(id) on delete cascade,
 kind text not null check(kind in ('first_group','demand_registered','demand_approved')),
 recorded_at timestamptz not null default now(),source text not null check(source in ('event','inferred')),
 primary key(student_id,kind)
);
alter table impulso_private.learning_individual_deliveries enable row level security;
alter table impulso_private.milestone_medals enable row level security;
revoke all on impulso_private.learning_individual_deliveries,impulso_private.milestone_medals from public,anon,authenticated;

-- Inferência conservadora: apenas alunos que atualmente estão em grupo/demanda.
insert into impulso_private.milestone_medals(student_id,kind,source)
select m.student_id,'first_group','inferred' from impulso_private.members m on conflict do nothing;
insert into impulso_private.milestone_medals(student_id,kind,source)
select m.student_id,'demand_registered','inferred' from impulso_private.members m join impulso_private.projects p on p.team_id=m.team_id on conflict do nothing;
insert into impulso_private.milestone_medals(student_id,kind,source)
select m.student_id,'demand_approved','inferred' from impulso_private.members m join impulso_private.projects p on p.team_id=m.team_id join lateral (select r.status from impulso_private.project_reviews r where r.project_id=p.id order by r.id desc limit 1) last_review on last_review.status='approved' on conflict do nothing;

-- Para atividades individuais, a situação coletiva acompanha a lista atual.
create function impulso_private.sync_individual_team(p_team uuid) returns void
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare a impulso_private.learning_activities%rowtype; complete boolean; st text;
begin
 -- Não manter pedidos pendentes para pessoas que já saíram do grupo,
 -- tanto em atividades individuais quanto nas entregues pelo grupo.
 update impulso_private.learning_badge_requests r set status='cancelled',decided_at=now()
 where r.team_id=p_team and r.status='pending' and not exists(select 1 from impulso_private.members m where m.team_id=p_team and m.student_id=r.student_id);
 for a in select x.* from impulso_private.learning_activities x join impulso_private.teams t on t.teacher_id=x.teacher_id and (x.team_id is null or x.team_id=t.id) where t.id=p_team and x.delivery_mode='everyone' order by x.id for update of x loop
  select exists(select 1 from impulso_private.members m where m.team_id=p_team) and not exists(select 1 from impulso_private.members m left join impulso_private.learning_individual_deliveries d on d.student_id=m.student_id and d.team_id=m.team_id and d.activity_id=a.id where m.team_id=p_team and coalesce(d.status,'pending')<>'delivered') into complete;
  st:=case when complete then 'delivered' else 'pending' end;
  insert into impulso_private.learning_activity_progress(activity_id,team_id,status) values(a.id,p_team,st) on conflict(activity_id,team_id) do update set status=excluded.status;
  if not complete then
   update impulso_private.learning_badge_requests set status='cancelled',decided_at=now() where activity_id=a.id and team_id=p_team and status='pending';
  elsif a.badge_id is not null then
   if a.badge_mode='auto' then
    insert into impulso_private.learning_badge_awards(badge_id,student_id,source) select a.badge_id,m.student_id,'automatic' from impulso_private.members m where m.team_id=p_team on conflict do nothing;
   else
    insert into impulso_private.learning_badge_requests(activity_id,team_id,badge_id,student_id) select a.id,p_team,a.badge_id,m.student_id from impulso_private.members m where m.team_id=p_team and not exists(select 1 from impulso_private.learning_badge_awards w where w.badge_id=a.badge_id and w.student_id=m.student_id) on conflict(activity_id,team_id,badge_id,student_id) do update set status='pending',decided_at=null where impulso_private.learning_badge_requests.status='cancelled';
   end if;
  end if;
 end loop;
end $$;
revoke all on function impulso_private.sync_individual_team(uuid) from public,anon,authenticated;

create function impulso_private.member_medals_and_sync() returns trigger language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare team uuid;
begin
 if tg_op='INSERT' then
  team:=new.team_id;
  insert into impulso_private.milestone_medals(student_id,kind,source) values(new.student_id,'first_group','event') on conflict do nothing;
  if exists(select 1 from impulso_private.projects p where p.team_id=team) then insert into impulso_private.milestone_medals(student_id,kind,source) values(new.student_id,'demand_registered','event') on conflict do nothing; end if;
  if exists(select 1 from impulso_private.projects p join lateral (select r.status from impulso_private.project_reviews r where r.project_id=p.id order by r.id desc limit 1) q on q.status='approved' where p.team_id=team) then insert into impulso_private.milestone_medals(student_id,kind,source) values(new.student_id,'demand_approved','event') on conflict do nothing; end if;
 else team:=old.team_id; end if;
 perform impulso_private.sync_individual_team(team);
 return null;
end $$;
revoke all on function impulso_private.member_medals_and_sync() from public,anon,authenticated;
create trigger impulso_member_medals_sync after insert or delete on impulso_private.members for each row execute function impulso_private.member_medals_and_sync();

create function impulso_private.review_medals() returns trigger language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare k text;
begin
 if tg_op='INSERT' then k:='demand_registered'; elsif new.status='approved' and old.status is distinct from new.status then k:='demand_approved'; else return null; end if;
 insert into impulso_private.milestone_medals(student_id,kind,source) select m.student_id,k,'event' from impulso_private.projects p join impulso_private.members m on m.team_id=p.team_id where p.id=new.project_id on conflict do nothing;
 return null;
end $$;
revoke all on function impulso_private.review_medals() from public,anon,authenticated;
create trigger impulso_review_medals after insert or update on impulso_private.project_reviews for each row execute function impulso_private.review_medals();
alter function public.impulso_learning(text,jsonb) rename to impulso_learning_v8;
revoke all on function public.impulso_learning_v8(text,jsonb) from public,anon,authenticated;
create function public.impulso_learning(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare base jsonb; user_state jsonb; u uuid:=auth.uid(); sid uuid; teacher uuid; is_teacher boolean; aid uuid; tid uuid; bid uuid; projectid uuid; st text; l text; notes text; n text; des text; bmode text; dmode text; due date; olda impulso_private.learning_activities%rowtype; result jsonb; rowx record;
begin
 user_state:=public.impulso('load','{}'::jsonb);
 if coalesce((user_state->>'password_change_required')::boolean,false) then raise exception 'Troque a senha inicial.'; end if;
 is_teacher:=(user_state->>'role'='professor');
 if is_teacher then teacher:=u; else select id,teacher_id into sid,teacher from impulso_private.students where user_id=u; if sid is null then raise exception 'Aluno não encontrado.'; end if; end if;
 if op='load' then
  base:=public.impulso_learning_v8(op,data);
  select coalesce(jsonb_agg(z.item || jsonb_build_object(
    'delivery_mode',a.delivery_mode,
    'my_status',case when not is_teacher and a.delivery_mode='everyone' then coalesce((select d.status from impulso_private.learning_individual_deliveries d where d.activity_id=a.id and d.team_id=(z.item->>'team_id')::uuid and d.student_id=sid),'pending') else null end,
    'delivered_count',(select count(*) from impulso_private.members m left join impulso_private.learning_individual_deliveries d on d.activity_id=a.id and d.team_id=m.team_id and d.student_id=m.student_id where m.team_id=(z.item->>'team_id')::uuid and d.status='delivered'),
    'members',case when is_teacher then coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'name',s.name,'status',case when a.delivery_mode='group' then z.item->>'status' else coalesce(d.status,'pending') end,'link',case when a.delivery_mode='group' then z.item->>'link' else coalesce(d.link,'') end,'notes',case when a.delivery_mode='group' then z.item->>'notes' else coalesce(d.notes,'') end) order by s.name) from impulso_private.members m join impulso_private.students s on s.id=m.student_id left join impulso_private.learning_individual_deliveries d on d.activity_id=a.id and d.team_id=m.team_id and d.student_id=m.student_id where m.team_id=(z.item->>'team_id')::uuid),'[]'::jsonb) else '[]'::jsonb end,
    'my_link',case when not is_teacher and a.delivery_mode='everyone' then coalesce((select d.link from impulso_private.learning_individual_deliveries d where d.activity_id=a.id and d.team_id=(z.item->>'team_id')::uuid and d.student_id=sid),'') else '' end,
    'my_notes',case when not is_teacher and a.delivery_mode='everyone' then coalesce((select d.notes from impulso_private.learning_individual_deliveries d where d.activity_id=a.id and d.team_id=(z.item->>'team_id')::uuid and d.student_id=sid),'') else '' end
  ) order by z.ord),'[]'::jsonb) into result from jsonb_array_elements(base->'activities') with ordinality z(item,ord) join impulso_private.learning_activities a on a.id=(z.item->>'id')::uuid;
  base:=jsonb_set(base,'{activities}',result);
  select coalesce(jsonb_agg(z.item || jsonb_build_object('delivery_mode',a.delivery_mode) order by z.ord),'[]'::jsonb) into result from jsonb_array_elements(base->'definitions') with ordinality z(item,ord) join impulso_private.learning_activities a on a.id=(z.item->>'id')::uuid;
  base:=jsonb_set(base,'{definitions}',result);
  return base || jsonb_build_object('milestones',case when is_teacher then '[]'::jsonb else coalesce((select jsonb_agg(kind order by recorded_at) from impulso_private.milestone_medals where student_id=sid),'[]'::jsonb) end);
 elsif op='save_activity' then
  if not is_teacher then raise exception 'Somente a professora pode criar ou editar atividades.'; end if;
  n:=trim(coalesce(data->>'name',''));des:=trim(coalesce(data->>'description',''));due:=(data->>'deadline')::date;bid:=nullif(data->>'badge_id','')::uuid;bmode:=coalesce(data->>'badge_mode','approval');dmode:=coalesce(data->>'delivery_mode','group');aid:=nullif(data->>'id','')::uuid;
  if length(n) not between 1 and 200 or length(des)>5000 or due is null or bmode not in ('auto','approval') or dmode not in ('group','everyone') then raise exception 'Confira os dados da atividade.'; end if;
  if bid is not null and not exists(select 1 from impulso_private.learning_badges where id=bid and teacher_id=teacher) then raise exception 'Medalha não encontrada.'; end if;
  if aid is null then
   projectid:=nullif(data->>'project_id','')::uuid;tid:=null;
   if projectid is not null then select t.id into tid from impulso_private.projects p join impulso_private.teams t on t.id=p.team_id where p.id=projectid and t.teacher_id=teacher; if tid is null then raise exception 'Demanda não encontrada.'; end if; end if;
   insert into impulso_private.learning_activities(teacher_id,name,description,deadline,team_id,project_id,badge_id,badge_mode,delivery_mode) values(teacher,n,des,due,tid,projectid,bid,bmode,dmode) returning id into aid;
  else
   select * into olda from impulso_private.learning_activities where id=aid and teacher_id=teacher for update;
   if not found then raise exception 'Atividade não encontrada.'; end if;
   if olda.badge_id is distinct from bid or olda.badge_mode is distinct from bmode or olda.delivery_mode is distinct from dmode then update impulso_private.learning_badge_requests set status='cancelled',decided_at=now() where activity_id=aid and status='pending'; end if;
   if olda.delivery_mode is distinct from dmode then
    delete from impulso_private.learning_individual_deliveries where activity_id=aid;
    update impulso_private.learning_activity_progress set status='pending' where activity_id=aid;
   end if;
   update impulso_private.learning_activities set name=n,description=des,deadline=due,badge_id=bid,badge_mode=bmode,delivery_mode=dmode where id=aid;
  end if;
  return jsonb_build_object('ok',true,'id',aid);
 elsif op='save_progress' then
  aid:=(data->>'activity_id')::uuid;tid:=(data->>'team_id')::uuid;
  select x.* into olda from impulso_private.learning_activities x join impulso_private.teams t on t.teacher_id=x.teacher_id and (x.team_id is null or x.team_id=t.id) where x.id=aid and t.id=tid and x.teacher_id=teacher and (is_teacher or exists(select 1 from impulso_private.members m where m.student_id=sid and m.team_id=tid)) for update of x;
  if not found then raise exception 'Atividade ou grupo não encontrado.'; end if;
  if olda.delivery_mode='group' then return public.impulso_learning_v8(op,data); end if;
  if is_teacher then raise exception 'Nesta atividade, cada aluno registra sua própria entrega.'; end if;
  st:=coalesce(data->>'status','');l:=trim(coalesce(data->>'link',''));notes:=coalesce(data->>'notes','');
  if st not in ('pending','delivered') or length(l)>2048 or (l<>'' and l !~* '^https?://[^[:space:]]+$') or length(notes)>10000 then raise exception 'Confira a situação, o link e as observações.'; end if;
  insert into impulso_private.learning_individual_deliveries(activity_id,team_id,student_id,status,link,notes) values(aid,tid,sid,st,l,notes) on conflict(activity_id,team_id,student_id) do update set status=excluded.status,link=excluded.link,notes=excluded.notes,updated_at=now();
  perform impulso_private.sync_individual_team(tid);
  return jsonb_build_object('ok',true);
 end if;
 return public.impulso_learning_v8(op,data);
end $$;
revoke all on function public.impulso_learning(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso_learning(text,jsonb) to authenticated;

-- Painel só entrega dados de alunos pertencentes à professora autenticada.
create function public.impulso_student_report(p_student_id uuid) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid(); s impulso_private.students%rowtype; tid uuid;
begin
 if not exists(select 1 from impulso_private.teachers where user_id=u) then raise exception 'Acesso restrito à professora.'; end if;
 select * into s from impulso_private.students where id=p_student_id and teacher_id=u;
 if not found then raise exception 'Aluno não encontrado.'; end if;
 select team_id into tid from impulso_private.members where student_id=s.id;
 return jsonb_build_object('name',s.name,'email',s.email,'username',coalesce((select p.username from impulso_private.student_profiles p where p.student_id=s.id),''),'avatar',coalesce((select p.avatar from impulso_private.student_profiles p where p.student_id=s.id),'fox'),
 'team',coalesce((select t.name from impulso_private.teams t where t.id=tid),''),
 'project',coalesce((select p.name from impulso_private.projects p where p.team_id=tid),''),
 'first_access',exists(select 1 from impulso_private.first_access_medals m where m.student_id=s.id),
 'milestones',coalesce((select jsonb_agg(m.kind) from impulso_private.milestone_medals m where m.student_id=s.id),'[]'::jsonb),
 'badges',coalesce((select jsonb_agg(jsonb_build_object('name',b.name,'icon',b.icon)) from impulso_private.learning_badge_awards w join impulso_private.learning_badges b on b.id=w.badge_id where w.student_id=s.id),'[]'::jsonb),
 'activities',coalesce((select jsonb_agg(jsonb_build_object('name',a.name,'deadline',a.deadline,'delivery_mode',a.delivery_mode,'status',case when a.delivery_mode='group' then coalesce(p.status,'pending') else coalesce(d.status,'pending') end,'link',case when a.delivery_mode='group' then coalesce(p.link,'') else coalesce(d.link,'') end,'notes',case when a.delivery_mode='group' then coalesce(p.notes,'') else coalesce(d.notes,'') end) order by a.deadline) from impulso_private.learning_activities a join impulso_private.teams t on t.id=tid and t.teacher_id=a.teacher_id and (a.team_id is null or a.team_id=t.id) left join impulso_private.learning_activity_progress p on p.activity_id=a.id and p.team_id=tid left join impulso_private.learning_individual_deliveries d on d.activity_id=a.id and d.team_id=tid and d.student_id=s.id where a.teacher_id=u),'[]'::jsonb));
end $$;
revoke all on function public.impulso_student_report(uuid) from public,anon,authenticated;
grant execute on function public.impulso_student_report(uuid) to authenticated;
commit;
notify pgrst,'reload schema';
