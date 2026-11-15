-- Impulso 0.1.0-alpha.3: atualizar cadastro de alunos existentes.
-- Pré-requisitos: alpha.1 e alpha.2 aplicadas; faça backup e aplique uma única vez.
begin;
create table impulso_private.student_edit_jobs (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references impulso_private.students(id),
  teacher_id uuid not null references impulso_private.teachers(user_id),
  old_email text not null,
  target_email text not null,
  target_name text not null,
  status text not null default 'pending' check(status in ('pending','done','cancelled')),
  created_at timestamptz not null default now(),
  completed_at timestamptz
);
create unique index impulso_one_pending_student_edit on impulso_private.student_edit_jobs(student_id) where status='pending';
alter table impulso_private.student_edit_jobs enable row level security;
revoke all on impulso_private.student_edit_jobs from public,anon,authenticated;

-- A sessão do professor é verificada em cada função. Nenhuma delas altera auth.users
-- diretamente; para o e-mail de uma conta vinculada, a Edge Function chama a API
-- administrativa do Supabase, depois conclui o cadastro com impulso_finish_edit.
create function public.impulso_prepare_edit(p_student_id uuid,p_name text,p_email text) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid(); s impulso_private.students%rowtype; j impulso_private.student_edit_jobs%rowtype; n text:=trim(coalesce(p_name,'')); e text:=lower(trim(coalesce(p_email,''))); a_email text; job_id uuid;
begin
 if not exists(select 1 from impulso_private.teachers where user_id=u) then raise exception 'Acesso restrito ao professor.'; end if;
 if length(n) not between 1 and 120 or length(e)>254 or e !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then raise exception 'Informe nome e e-mail válidos.'; end if;
 select * into s from impulso_private.students where id=p_student_id and teacher_id=u for update;
 if not found then raise exception 'Aluno não encontrado.'; end if;
 select * into j from impulso_private.student_edit_jobs where student_id=s.id and status='pending' for update;
 if found then
   if j.teacher_id=u and j.target_email=e and j.target_name=n then
     return jsonb_build_object('status','pending','job_id',j.id,'user_id',s.user_id,'old_email',j.old_email,'target_email',j.target_email);
   end if;
   raise exception 'Existe uma alteração incompleta. Repita a tentativa com os mesmos dados ou solicite suporte.';
 end if;
 if e=s.email then
   update impulso_private.students set name=n where id=s.id;
   return jsonb_build_object('status','done');
 end if;
 if exists(select 1 from impulso_private.students where email=e and id<>s.id) then raise exception 'Este e-mail já está cadastrado para outro aluno.'; end if;
 if exists(select 1 from auth.users where lower(email)=e and id is distinct from s.user_id) then raise exception 'Este e-mail já está associado a outra conta.'; end if;
 if s.user_id is null then
   if exists(select 1 from auth.users where lower(email)=s.email) then raise exception 'Este cadastro já possui uma conta ainda não vinculada. Verifique o caso no Supabase antes de alterar o e-mail.'; end if;
   update impulso_private.students set name=n,email=e where id=s.id;
   return jsonb_build_object('status','done');
 end if;
 select lower(email) into a_email from auth.users where id=s.user_id;
 if a_email is distinct from s.email then raise exception 'O cadastro e a conta de autenticação já estão divergentes. Solicite suporte antes de alterar.'; end if;
 insert into impulso_private.student_edit_jobs(student_id,teacher_id,old_email,target_email,target_name) values(s.id,u,s.email,e,n) returning id into job_id;
 return jsonb_build_object('status','pending','job_id',job_id,'user_id',s.user_id,'old_email',s.email,'target_email',e);
end $$;
revoke all on function public.impulso_prepare_edit(uuid,text,text) from public,anon,authenticated;
grant execute on function public.impulso_prepare_edit(uuid,text,text) to authenticated;

create function public.impulso_finish_edit(p_job_id uuid) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid(); j impulso_private.student_edit_jobs%rowtype; s impulso_private.students%rowtype; a_email text; confirmed timestamptz;
begin
 if not exists(select 1 from impulso_private.teachers where user_id=u) then raise exception 'Acesso restrito ao professor.'; end if;
 select * into j from impulso_private.student_edit_jobs where id=p_job_id and teacher_id=u for update;
 if not found then raise exception 'Alteração não encontrada.'; end if;
 if j.status='done' then return jsonb_build_object('ok',true); end if;
 if j.status<>'pending' then raise exception 'Alteração cancelada.'; end if;
 select * into s from impulso_private.students where id=j.student_id and teacher_id=u for update;
 if not found or s.email<>j.old_email or s.user_id is null then raise exception 'O cadastro foi alterado durante a operação. Solicite suporte.'; end if;
 select lower(email),email_confirmed_at into a_email,confirmed from auth.users where id=s.user_id;
 if a_email is distinct from j.target_email or confirmed is null then raise exception 'A conta de login ainda não foi atualizada. Repita a operação.'; end if;
 update impulso_private.students set name=j.target_name,email=j.target_email where id=s.id;
 update impulso_private.student_edit_jobs set status='done',completed_at=now() where id=j.id;
 return jsonb_build_object('ok',true);
end $$;
revoke all on function public.impulso_finish_edit(uuid) from public,anon,authenticated;
grant execute on function public.impulso_finish_edit(uuid) to authenticated;

-- Só permite cancelar se a conta e o cadastro continuam usando o e-mail anterior.
create function public.impulso_cancel_edit(p_job_id uuid) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid(); j impulso_private.student_edit_jobs%rowtype; s impulso_private.students%rowtype; a_email text;
begin
 if not exists(select 1 from impulso_private.teachers where user_id=u) then raise exception 'Acesso restrito ao professor.'; end if;
 select * into j from impulso_private.student_edit_jobs where id=p_job_id and teacher_id=u for update;
 if not found then raise exception 'Alteração não encontrada.'; end if;
 if j.status='done' then return jsonb_build_object('status','done'); end if;
 if j.status='cancelled' then return jsonb_build_object('status','cancelled'); end if;
 select * into s from impulso_private.students where id=j.student_id and teacher_id=u for update;
 if not found then raise exception 'Aluno não encontrado.'; end if;
 select lower(email) into a_email from auth.users where id=s.user_id;
 if s.email is distinct from j.old_email or a_email is distinct from j.old_email then raise exception 'A conta já mudou. Repita a alteração com os mesmos dados para concluir.'; end if;
 update impulso_private.student_edit_jobs set status='cancelled',completed_at=now() where id=j.id;
 return jsonb_build_object('status','cancelled');
end $$;
revoke all on function public.impulso_cancel_edit(uuid) from public,anon,authenticated;
grant execute on function public.impulso_cancel_edit(uuid) to authenticated;
commit;
notify pgrst,'reload schema';
