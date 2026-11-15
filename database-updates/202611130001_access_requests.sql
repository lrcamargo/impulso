-- Impulso 0.1.0-alpha.2. APLICAÇÃO MANUAL EM BANCO EXISTENTE, UMA VEZ.
-- Pré-requisito: 0.1.0-alpha.1 instalado; faça backup antes de aplicar.
begin;
create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

create table impulso_private.access_requests (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references impulso_private.teachers(user_id),
  name text not null check(length(name) between 1 and 120),
  email text not null check(email=lower(email) and length(email) between 3 and 254),
  status text not null default 'pending' check(status in ('pending','approved','rejected')),
  created_at timestamptz not null default now()
);
create unique index impulso_one_pending_request on impulso_private.access_requests(teacher_id,email) where status='pending';
alter table impulso_private.access_requests enable row level security;
revoke all on impulso_private.access_requests from public, anon, authenticated;

-- NULL significa que o provisionamento está incompleto: nenhum dado fica acessível.
-- O hash inicial já é armazenado pelo Supabase Auth; a cópia serve apenas para
-- comparar a nova senha e é apagada após a troca, nunca enviada ao navegador.
create table impulso_private.first_passwords (
  student_id uuid primary key references impulso_private.students(id) on delete cascade,
  initial_password_hash text,
  request_id uuid references impulso_private.access_requests(id),
  created_at timestamptz not null default now()
);
alter table impulso_private.first_passwords enable row level security;
revoke all on impulso_private.first_passwords from public, anon, authenticated;

-- A forma original não fica acessível a clientes: toda ação passa pelo gate.
alter function public.impulso(text,jsonb) rename to impulso_v1;
revoke all on function public.impulso_v1(text,jsonb) from public, anon, authenticated;

create function public.impulso(op text, data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid(); sid uuid; gate_exists boolean; gate_hash text; is_teacher boolean;
begin
  if u is null then raise exception 'Faça login para continuar.'; end if;
  select exists(select 1 from impulso_private.teachers where user_id=u) into is_teacher;
  if not is_teacher then
    select s.id into sid from impulso_private.students s join auth.users a on a.id=u
    where (s.user_id=u or s.user_id is null) and a.email_confirmed_at is not null and lower(a.email)=s.email;
    if sid is not null then
      select true,initial_password_hash into gate_exists,gate_hash from impulso_private.first_passwords where student_id=sid;
      if coalesce(gate_exists,false) then
        if gate_hash is null then raise exception 'Sua conta ainda está sendo configurada. Tente novamente em alguns instantes.'; end if;
        if op='load' then return jsonb_build_object('password_change_required',true); end if;
        raise exception 'Troque sua senha inicial antes de acessar a plataforma.';
      end if;
    end if;
  end if;
  -- Criar cadastros precisa passar pela função de provisionamento, que cria a
  -- conta de autenticação e a proteção de primeira senha juntas no fluxo seguro.
  if op='add_student' then raise exception 'Use o cadastro de alunos da versão atualizada.'; end if;
  return public.impulso_v1(op,data);
end $$;
revoke all on function public.impulso(text,jsonb) from public, anon, authenticated;
grant execute on function public.impulso(text,jsonb) to authenticated;

-- Após Supabase Auth alterar a senha, confirme que a senha enviada é realmente
-- a senha atual e diferente da senha inicial. O token deve ser do aluno.
create function public.impulso_finish_password(new_password text) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid(); sid uuid; old_hash text; actual_hash text; ext_schema text; computed text;
begin
  if u is null then raise exception 'Faça login.'; end if;
  if length(coalesce(new_password,''))<8 or octet_length(new_password)>72 then raise exception 'Use uma senha de 8 a 72 caracteres.'; end if;
  select s.id,g.initial_password_hash,a.encrypted_password into sid,old_hash,actual_hash
    from impulso_private.students s join impulso_private.first_passwords g on g.student_id=s.id join auth.users a on a.id=s.user_id
    where s.user_id=u and a.email_confirmed_at is not null and lower(a.email)=s.email for update of g;
  if not found or old_hash is null or actual_hash is null then raise exception 'Não há troca de senha pendente.'; end if;
  select n.nspname into ext_schema from pg_catalog.pg_extension e join pg_catalog.pg_namespace n on n.oid=e.extnamespace where e.extname='pgcrypto';
  if ext_schema is null then raise exception 'Extensão de segurança não configurada.'; end if;
  execute format('select %I.crypt($1,$2)',ext_schema) into computed using new_password,actual_hash;
  if computed is distinct from actual_hash then raise exception 'Não foi possível verificar a nova senha.'; end if;
  execute format('select %I.crypt($1,$2)',ext_schema) into computed using new_password,old_hash;
  if computed=old_hash then raise exception 'Escolha uma senha diferente da senha inicial.'; end if;
  delete from impulso_private.first_passwords where student_id=sid;
  return jsonb_build_object('ok',true);
end $$;
revoke all on function public.impulso_finish_password(text) from public, anon, authenticated;
grant execute on function public.impulso_finish_password(text) to authenticated;

-- Solicitações públicas não criam usuários nem concedem acesso. O destinatário
-- é o único professor; esta versão exige configuração adicional para múltiplos.
create function public.impulso_request_access(request_name text, request_email text) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare teacher uuid; n int; clean_name text:=trim(coalesce(request_name,'')); clean_email text:=lower(trim(coalesce(request_email,'')));
begin
  if length(clean_name) not between 1 and 120 or length(clean_email)>254 or clean_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then raise exception 'Informe nome e e-mail válidos.'; end if;
  select count(*) into n from impulso_private.teachers;
  if n<>1 then raise exception 'A solicitação de acesso ainda não está configurada. Procure seu professor.'; end if;
  select user_id into teacher from impulso_private.teachers limit 1;
  -- Reduz repetição acidental. Não substitui CAPTCHA nem proteção contra abuso.
  perform pg_advisory_xact_lock(hashtext('impulso_request:'||clean_email));
  if exists(select 1 from impulso_private.students where email=clean_email) or
     exists(select 1 from impulso_private.access_requests where teacher_id=teacher and email=clean_email and (status='pending' or created_at>now()-interval '1 hour')) then
    return jsonb_build_object('ok',true);
  end if;
  -- Limite global simples para reduzir volume acidental, não substitui CAPTCHA.
  perform pg_advisory_xact_lock(hashtext('impulso_request_teacher:'||teacher::text));
  if (select count(*) from impulso_private.access_requests where teacher_id=teacher and created_at>now()-interval '24 hours')>=300 then
    raise exception 'O limite de solicitações foi atingido. Procure o professor.';
  end if;
  insert into impulso_private.access_requests(teacher_id,name,email) values(teacher,clean_name,clean_email);
  return jsonb_build_object('ok',true);
end $$;
revoke all on function public.impulso_request_access(text,text) from public, anon, authenticated;
grant execute on function public.impulso_request_access(text,text) to anon, authenticated;

create function public.impulso_requests() returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid();
begin
  if not exists(select 1 from impulso_private.teachers where user_id=u) then raise exception 'Acesso restrito ao professor.'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id',id,'name',name,'email',email,'created_at',created_at) order by created_at desc) from impulso_private.access_requests where teacher_id=u and status='pending'),'[]'::jsonb);
end $$;
revoke all on function public.impulso_requests() from public,anon,authenticated;
grant execute on function public.impulso_requests() to authenticated;

create function public.impulso_reject_request(request_id uuid) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid();
begin
  if not exists(select 1 from impulso_private.teachers where user_id=u) then raise exception 'Acesso restrito ao professor.'; end if;
  update impulso_private.access_requests set status='rejected' where id=request_id and teacher_id=u and status='pending';
  if not found then raise exception 'Solicitação não encontrada.'; end if;
  return jsonb_build_object('ok',true);
end $$;
revoke all on function public.impulso_reject_request(uuid) from public,anon,authenticated;
grant execute on function public.impulso_reject_request(uuid) to authenticated;

-- Cadastro preparado antes de criar Auth, impedindo acesso antes de concluir.
create function public.impulso_begin_student(student_name text, student_email text, request_id uuid default null) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid(); new_id uuid; clean_email text:=lower(trim(coalesce(student_email,''))); clean_name text:=trim(coalesce(student_name,''));
begin
  if not exists(select 1 from impulso_private.teachers where user_id=u) then raise exception 'Acesso restrito ao professor.'; end if;
  if length(clean_name) not between 1 and 120 or length(clean_email)>254 or clean_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then raise exception 'Informe nome e e-mail válidos.'; end if;
  if request_id is not null then
    perform 1 from impulso_private.access_requests where id=request_id and teacher_id=u and email=clean_email and status='pending' for update;
    if not found then raise exception 'Solicitação não encontrada ou já atendida.'; end if;
  end if;
  insert into impulso_private.students(teacher_id,name,email) values(u,clean_name,clean_email) returning id into new_id;
  insert into impulso_private.first_passwords(student_id,request_id) values(new_id,request_id);
  return jsonb_build_object('student_id',new_id);
end $$;
revoke all on function public.impulso_begin_student(text,text,uuid) from public,anon,authenticated;
grant execute on function public.impulso_begin_student(text,text,uuid) to authenticated;

create function public.impulso_finish_student(student_id uuid, new_user_id uuid) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid(); req uuid; h text;
begin
  if not exists(select 1 from impulso_private.teachers where user_id=u) then raise exception 'Acesso restrito ao professor.'; end if;
  select g.request_id,a.encrypted_password into req,h from impulso_private.students s join impulso_private.first_passwords g on g.student_id=s.id join auth.users a on a.id=new_user_id and lower(a.email)=s.email and a.email_confirmed_at is not null where s.id=impulso_finish_student.student_id and s.teacher_id=u and s.user_id is null and g.initial_password_hash is null for update of s,g;
  if not found or h is null then raise exception 'Cadastro não pôde ser concluído.'; end if;
  update impulso_private.students set user_id=new_user_id where id=impulso_finish_student.student_id;
  update impulso_private.first_passwords set initial_password_hash=h where first_passwords.student_id=impulso_finish_student.student_id;
  if req is not null then update impulso_private.access_requests set status='approved' where id=req and teacher_id=u and status='pending'; end if;
  return jsonb_build_object('ok',true);
end $$;
revoke all on function public.impulso_finish_student(uuid,uuid) from public,anon,authenticated;
grant execute on function public.impulso_finish_student(uuid,uuid) to authenticated;

create function public.impulso_cancel_student(student_id uuid) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare u uuid:=auth.uid();
begin
  if not exists(select 1 from impulso_private.teachers where user_id=u) then raise exception 'Acesso restrito ao professor.'; end if;
  delete from impulso_private.students s where s.id=impulso_cancel_student.student_id and s.teacher_id=u and s.user_id is null and exists(select 1 from impulso_private.first_passwords g where g.student_id=s.id and g.initial_password_hash is null);
  return jsonb_build_object('ok',true);
end $$;
revoke all on function public.impulso_cancel_student(uuid) from public,anon,authenticated;
grant execute on function public.impulso_cancel_student(uuid) to authenticated;
commit;
notify pgrst,'reload schema';
