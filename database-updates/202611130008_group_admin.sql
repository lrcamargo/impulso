-- Alpha.12: administração de grupos. Requer SQL alpha.10; faça backup antes.
begin;
alter table impulso_private.invites add column reminded_at timestamptz;

-- Uma trava por equipe torna o limite efetivo inclusive em convites simultâneos.
create function impulso_private.check_member_limit() returns trigger
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare t_teacher uuid; s_teacher uuid; n integer;
begin
 select teacher_id into t_teacher from impulso_private.teams where id=new.team_id for update;
 select teacher_id into s_teacher from impulso_private.students where id=new.student_id;
 if t_teacher is null or s_teacher is distinct from t_teacher then raise exception 'Aluno e grupo devem pertencer ao mesmo responsável.'; end if;
 select count(*) into n from impulso_private.members where team_id=new.team_id and (tg_op='INSERT' or student_id<>old.student_id);
 if n>=5 then raise exception 'Este grupo já tem o máximo de 5 integrantes.'; end if;
 return new;
end $$;
revoke all on function impulso_private.check_member_limit() from public,anon,authenticated;
create trigger impulso_members_limit before insert or update of team_id,student_id on impulso_private.members for each row execute function impulso_private.check_member_limit();

create function public.impulso_group_admin(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare state jsonb; u uuid:=auth.uid(); sid uuid; tid uuid; inv uuid; user_role text;
begin
 state:=public.impulso('load','{}'::jsonb);
 if coalesce((state->>'password_change_required')::boolean,false) then raise exception 'Troque sua senha inicial antes de continuar.'; end if;
 user_role:=state->>'role';
 if op='reminders' then
   if user_role<>'aluno' then return '[]'::jsonb; end if;
   select id into sid from impulso_private.students where user_id=u;
   return coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'reminded_at',i.reminded_at)) from impulso_private.invites i where i.student_id=sid and i.status='pending' and i.reminded_at is not null),'[]'::jsonb);
 end if;
 if user_role<>'professor' then raise exception 'Somente o responsável pode administrar grupos.'; end if;
 if op='pending_students' then
   return coalesce((select jsonb_agg(jsonb_build_object('student_id',i.student_id,'team_name',t.name) order by t.name) from impulso_private.invites i join impulso_private.teams t on t.id=i.team_id join impulso_private.students s on s.id=i.student_id where t.teacher_id=u and s.teacher_id=u and i.status='pending'),'[]'::jsonb);
 end if;
 if op='allocate' then
   sid:=(data->>'student_id')::uuid;tid:=(data->>'team_id')::uuid;
   perform 1 from impulso_private.students where id=sid and teacher_id=u for update;
   if not found then raise exception 'Aluno não encontrado.'; end if;
   if exists(select 1 from impulso_private.members where student_id=sid) then raise exception 'Este aluno já participa de um grupo.'; end if;
   if not exists(select 1 from impulso_private.teams where id=tid and teacher_id=u) then raise exception 'Grupo não encontrado.'; end if;
   insert into impulso_private.members(team_id,student_id) values(tid,sid);
   update impulso_private.invites set status='cancelled' where student_id=sid and status='pending';
   return jsonb_build_object('ok',true);
 elsif op='remind' then
   inv:=(data->>'id')::uuid;
   update impulso_private.invites i set reminded_at=now() from impulso_private.teams t
    where i.id=inv and i.team_id=t.id and t.teacher_id=u and i.status='pending';
   if not found then raise exception 'Convite pendente não encontrado.'; end if;
   return jsonb_build_object('ok',true);
 end if;
 raise exception 'Operação não reconhecida.';
end $$;
revoke all on function public.impulso_group_admin(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso_group_admin(text,jsonb) to authenticated;
commit;
notify pgrst,'reload schema';
