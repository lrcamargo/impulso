-- Impulso alpha.6: medalha de primeiro acesso. Banco alpha.2 já aplicado.
-- Faça backup e execute uma única vez no SQL Editor do projeto correto.
begin;
create table impulso_private.first_access_medals (
  student_id uuid primary key references impulso_private.students(id) on delete cascade,
  recorded_at timestamptz not null default now(),
  source text not null check (source in ('password_changed','inferred_approved_request','teacher_verified'))
);
alter table impulso_private.first_access_medals enable row level security;
revoke all on impulso_private.first_access_medals from public,anon,authenticated;

-- Evidência conservadora: uma solicitação aprovada vinculada à mesma professora
-- e e-mail antes do cadastro, com usuário vinculado/confirmado e gate ausente.
-- Sem gate não prova troca para alunos legados ou cadastrados diretamente, pois
-- a alpha.2 apagava o registro da troca e não guardava sua origem/histórico.
insert into impulso_private.first_access_medals(student_id,source)
select s.id,'inferred_approved_request'
from impulso_private.students s join auth.users u on u.id=s.user_id
where u.email_confirmed_at is not null and lower(u.email)=s.email
  and not exists(select 1 from impulso_private.first_passwords f where f.student_id=s.id)
  and exists(select 1 from impulso_private.access_requests r
    where r.teacher_id=s.teacher_id and r.email=s.email and r.status='approved' and r.created_at<=s.created_at)
on conflict(student_id) do nothing;

-- Mantém a validação de senha original e registra a medalha na mesma transação.
alter function public.impulso_finish_password(text) rename to impulso_finish_password_alpha2;
revoke all on function public.impulso_finish_password_alpha2(text) from public,anon,authenticated;
create function public.impulso_finish_password(new_password text) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare result jsonb; sid uuid;
begin
  result:=public.impulso_finish_password_alpha2(new_password);
  select id into sid from impulso_private.students where user_id=auth.uid();
  if sid is null then raise exception 'Aluno não encontrado.'; end if;
  insert into impulso_private.first_access_medals(student_id,source)
  values(sid,'password_changed') on conflict(student_id) do nothing;
  return result;
end $$;
revoke all on function public.impulso_finish_password(text) from public,anon,authenticated;
grant execute on function public.impulso_finish_password(text) to authenticated;

-- Consulta apenas a própria medalha, sem expor nomes ou dados de outros alunos.
create function public.impulso_first_access_medal() returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare sid uuid; awarded boolean;
begin
  if auth.uid() is null then raise exception 'Faça login.'; end if;
  select s.id into sid from impulso_private.students s join auth.users u on u.id=s.user_id
  where s.user_id=auth.uid() and lower(u.email)=s.email and u.email_confirmed_at is not null;
  if sid is null then raise exception 'Aluno não encontrado.'; end if;
  if exists(select 1 from impulso_private.first_passwords g where g.student_id=sid) then
    raise exception 'Troque sua senha inicial antes de acessar a plataforma.';
  end if;
  select exists(select 1 from impulso_private.first_access_medals m where m.student_id=sid) into awarded;
  return jsonb_build_object('awarded',awarded);
end $$;
revoke all on function public.impulso_first_access_medal() from public,anon,authenticated;
grant execute on function public.impulso_first_access_medal() to authenticated;
commit;
notify pgrst,'reload schema';
