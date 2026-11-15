-- IMPULSO: instalação em um projeto Supabase novo. Execute no SQL Editor como administrador.
-- As tabelas vivem em schema privado e só são acessadas por uma função que verifica a sessão.
begin;
create schema if not exists impulso_private;
revoke all on schema impulso_private from public, anon, authenticated;

create table impulso_private.teachers (
  user_id uuid primary key references auth.users(id),
  name text not null check(length(name) between 1 and 120)
);
create table impulso_private.students (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references impulso_private.teachers(user_id),
  name text not null check(length(name) between 1 and 120),
  email text not null unique check (email=lower(email) and length(email) between 3 and 254),
  user_id uuid unique references auth.users(id),
  created_at timestamptz not null default now()
);
create table impulso_private.teams (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references impulso_private.teachers(user_id),
  name text not null check(length(name) between 1 and 120),
  created_at timestamptz not null default now()
);
create table impulso_private.members (
  team_id uuid not null references impulso_private.teams(id) on delete cascade,
  student_id uuid primary key references impulso_private.students(id),
  joined_at timestamptz not null default now()
);
create table impulso_private.invites (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references impulso_private.teams(id) on delete cascade,
  student_id uuid not null references impulso_private.students(id),
  invited_by uuid references impulso_private.students(id),
  status text not null default 'pending' check(status in ('pending','accepted','declined','cancelled')),
  created_at timestamptz not null default now()
);
create unique index impulso_invite_one_pending on impulso_private.invites(team_id,student_id) where status='pending';
create table impulso_private.projects (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null unique references impulso_private.teams(id) on delete cascade,
  name text not null check(length(name) between 1 and 200),
  link text not null check(length(link)<=2048 and link ~* '^https?://[^[:space:]]+$'),
  description text not null default '', benefits text not null default '', details text not null default '',
  restrictions text not null default '', company text not null default '', area text not null default '',
  validity date, details_completed boolean not null default false,
  created_at timestamptz not null default now(),
  check(length(description)<=10000 and length(benefits)<=10000 and length(details)<=10000 and length(restrictions)<=10000 and length(company)<=200 and length(area)<=200)
);
create table impulso_private.tasks (
  id uuid primary key default gen_random_uuid(), project_id uuid not null references impulso_private.projects(id) on delete cascade,
  name text not null check(length(name) between 1 and 200), deadline date not null,
  status text not null default 'pending' check(status in ('pending','delivered')),
  link text not null default '' check(link='' or (length(link)<=2048 and link ~* '^https?://[^[:space:]]+$')),
  notes text not null default '' check(length(notes)<=10000), created_at timestamptz not null default now()
);
create table impulso_private.messages (
  id uuid primary key default gen_random_uuid(), teacher_id uuid not null references impulso_private.teachers(user_id),
  team_id uuid references impulso_private.teams(id) on delete cascade,
  author text not null check(length(author) between 1 and 120), body text not null check(length(body) between 1 and 5000),
  created_at timestamptz not null default now()
);
-- Defense in depth: tables are private, no direct grants and RLS has no policies.
alter table impulso_private.teachers enable row level security;
alter table impulso_private.students enable row level security;
alter table impulso_private.teams enable row level security;
alter table impulso_private.members enable row level security;
alter table impulso_private.invites enable row level security;
alter table impulso_private.projects enable row level security;
alter table impulso_private.tasks enable row level security;
alter table impulso_private.messages enable row level security;
revoke all on all tables in schema impulso_private from public, anon, authenticated;

create function public.impulso(op text, data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path = pg_catalog, impulso_private, auth as $$
declare
 u uuid := auth.uid(); current_email text; sid uuid; tid uuid; teacher uuid; is_teacher boolean := false;
 team_row impulso_private.teams%rowtype; invite_row impulso_private.invites%rowtype; project_row impulso_private.projects%rowtype;
 target_id uuid; record_id uuid; output jsonb; search_text text; newname text; newlink text;
begin
 if u is null then raise exception 'Faça login para continuar.'; end if;
 select lower(email) into current_email from auth.users where id=u and email_confirmed_at is not null;
 if current_email is null then raise exception 'Confirme seu e-mail antes de acessar a plataforma.'; end if;
 select user_id into teacher from impulso_private.teachers where user_id=u;
 is_teacher := teacher is not null;
 if not is_teacher then
   -- Só vincula cadastro reservado pelo professor ao usuário cujo e-mail foi verificado.
   update impulso_private.students set user_id=u where email=current_email and (user_id is null or user_id=u);
   select id, teacher_id into sid, teacher from impulso_private.students where user_id=u and email=current_email;
   if sid is null then raise exception 'Seu e-mail ainda não foi cadastrado pelo professor. Peça a ele para cadastrar você.'; end if;
   select team_id into tid from impulso_private.members where student_id=sid;
 end if;

 if op='load' then
   return jsonb_build_object(
    'role',case when is_teacher then 'professor' else 'aluno' end,
    'me',case when is_teacher then (select name from impulso_private.teachers where user_id=u) else (select name from impulso_private.students where id=sid) end,
    'students',case when is_teacher then coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'name',s.name,'email',s.email,'active',s.user_id is not null) order by s.name) from impulso_private.students s where s.teacher_id=teacher),'[]'::jsonb) else '[]'::jsonb end,
    'teams',coalesce((select jsonb_agg(jsonb_build_object('id',t.id,'name',t.name,
      'members',coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'name',s.name) order by s.name) from impulso_private.members m join impulso_private.students s on s.id=m.student_id where m.team_id=t.id),'[]'::jsonb),
      'pending',coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'name',s.name) order by s.name) from impulso_private.invites i join impulso_private.students s on s.id=i.student_id where i.team_id=t.id and i.status='pending'),'[]'::jsonb)) order by t.created_at desc)
      from impulso_private.teams t where t.teacher_id=teacher and (is_teacher or t.id=tid)),'[]'::jsonb),
    'invites',case when not is_teacher then coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'team_name',t.name,'inviter',coalesce(s.name,'Professor(a)')) order by i.created_at desc) from impulso_private.invites i join impulso_private.teams t on t.id=i.team_id left join impulso_private.students s on s.id=i.invited_by where i.student_id=sid and i.status='pending'),'[]'::jsonb) else '[]'::jsonb end,
    'projects',coalesce((select jsonb_agg(jsonb_build_object('id',p.id,'team_id',p.team_id,'team_name',t.name,'name',p.name,'link',p.link,'description',p.description,'benefits',p.benefits,'details',p.details,'restrictions',p.restrictions,'company',p.company,'area',p.area,'validity',p.validity,'details_completed',p.details_completed) order by p.created_at desc) from impulso_private.projects p join impulso_private.teams t on t.id=p.team_id where t.teacher_id=teacher and (is_teacher or t.id=tid)),'[]'::jsonb),
    'tasks',coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'project_id',x.project_id,'name',x.name,'deadline',x.deadline,'status',x.status,'link',x.link,'notes',x.notes) order by x.deadline) from impulso_private.tasks x join impulso_private.projects p on p.id=x.project_id join impulso_private.teams t on t.id=p.team_id where t.teacher_id=teacher and (is_teacher or t.id=tid)),'[]'::jsonb),
    'messages',coalesce((select jsonb_agg(q.item order by q.created_at desc) from (select jsonb_build_object('id',m.id,'team_id',m.team_id,'team_name',coalesce(t.name,'Aviso geral'),'author',m.author,'body',m.body,'created_at',m.created_at) item,m.created_at from impulso_private.messages m left join impulso_private.teams t on t.id=m.team_id where m.teacher_id=teacher and (is_teacher or m.team_id=tid or m.team_id is null) order by m.created_at desc limit 100) q),'[]'::jsonb));
 elsif op='add_student' then
   if not is_teacher then raise exception 'Apenas professores podem cadastrar alunos.'; end if;
   newname:=trim(coalesce(data->>'name','')); current_email:=lower(trim(coalesce(data->>'email','')));
   if length(newname) not between 1 and 120 or current_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' or length(current_email)>254 then raise exception 'Informe nome e e-mail válidos.'; end if;
   insert into impulso_private.students(teacher_id,name,email) values (teacher,newname,current_email); return jsonb_build_object('ok',true);
 elsif op='search_students' then
   if is_teacher or tid is null then raise exception 'Somente integrantes podem convidar colegas.'; end if;
   search_text:=lower(trim(coalesce(data->>'query','')));
   if length(search_text)<2 then return '[]'::jsonb; end if;
   if length(search_text)>254 then raise exception 'Pesquisa muito longa.'; end if;
   return coalesce((select jsonb_agg(jsonb_build_object('id',q.id,'name',q.name)) from (select s.id,s.name from impulso_private.students s where s.teacher_id=teacher and s.id<>sid and (position(search_text in lower(s.name))>0 or s.email=search_text) and not exists(select 1 from impulso_private.members m where m.student_id=s.id) and not exists(select 1 from impulso_private.invites i where i.student_id=s.id and i.team_id=tid and i.status='pending') order by s.name limit 20) q),'[]'::jsonb);
 elsif op='create_team' then
   if is_teacher then raise exception 'O grupo deve ser criado por um aluno.'; end if;
   perform 1 from impulso_private.students where id=sid for update;
   if exists(select 1 from impulso_private.members where student_id=sid) then raise exception 'Você já pertence a um grupo.'; end if;
   newname:=trim(coalesce(data->>'name','')); if length(newname) not between 1 and 120 then raise exception 'Informe o nome do grupo.'; end if;
   insert into impulso_private.teams(teacher_id,name) values(teacher,newname) returning id into record_id;
   insert into impulso_private.members(team_id,student_id) values(record_id,sid);
   update impulso_private.invites set status='cancelled' where student_id=sid and status='pending';
   return jsonb_build_object('id',record_id);
 elsif op='rename_team' then
   select * into team_row from impulso_private.teams where id=(data->>'team_id')::uuid and teacher_id=teacher and (is_teacher or id=tid);
   if not found then raise exception 'Grupo não encontrado.'; end if;
   newname:=trim(coalesce(data->>'name','')); if length(newname) not between 1 and 120 then raise exception 'Informe o nome do grupo.'; end if;
   update impulso_private.teams set name=newname where id=team_row.id; return jsonb_build_object('ok',true);
 elsif op='remove_member' then
   if not is_teacher then raise exception 'Apenas o professor pode remover integrantes.'; end if;
   select * into team_row from impulso_private.teams where id=(data->>'team_id')::uuid and teacher_id=teacher;
   if not found then raise exception 'Grupo não encontrado.'; end if;
   delete from impulso_private.members where team_id=team_row.id and student_id=(data->>'student_id')::uuid;
   if not found then raise exception 'Integrante não encontrado.'; end if;
   return jsonb_build_object('ok',true);
 elsif op='invite' then
   if is_teacher or tid is null then raise exception 'Somente integrantes podem convidar colegas.'; end if;
   target_id:=(data->>'student_id')::uuid;
   perform 1 from impulso_private.students where id=target_id and teacher_id=teacher for update;
   if not found or target_id=sid then raise exception 'Aluno não encontrado.'; end if;
   if exists(select 1 from impulso_private.members where student_id=target_id) then raise exception 'Este aluno já participa de um grupo.'; end if;
   insert into impulso_private.invites(team_id,student_id,invited_by) values(tid,target_id,sid); return jsonb_build_object('ok',true);
 elsif op='respond_invite' then
   if is_teacher then raise exception 'Convite inválido.'; end if;
   perform 1 from impulso_private.students where id=sid for update;
   select * into invite_row from impulso_private.invites where id=(data->>'id')::uuid and student_id=sid and status='pending' for update;
   if not found then raise exception 'Convite não encontrado ou já respondido.'; end if;
   if coalesce((data->>'accept')::boolean,false) then
     if exists(select 1 from impulso_private.members where student_id=sid) then raise exception 'Você já participa de um grupo.'; end if;
     insert into impulso_private.members(team_id,student_id) values(invite_row.team_id,sid);
     update impulso_private.invites set status='accepted' where id=invite_row.id;
     update impulso_private.invites set status='cancelled' where student_id=sid and status='pending';
   else update impulso_private.invites set status='declined' where id=invite_row.id; end if;
   return jsonb_build_object('ok',true);
 elsif op='cancel_invite' then
   select i.* into invite_row from impulso_private.invites i join impulso_private.teams t on t.id=i.team_id where i.id=(data->>'id')::uuid and i.status='pending' and t.teacher_id=teacher and (is_teacher or t.id=tid);
   if not found then raise exception 'Convite não encontrado.'; end if;
   update impulso_private.invites set status='cancelled' where id=invite_row.id and status='pending'; return jsonb_build_object('ok',true);
 elsif op='save_project' then
   if is_teacher or tid is null then raise exception 'Somente o grupo pode cadastrar nome e link da demanda.'; end if;
   newname:=trim(coalesce(data->>'name','')); newlink:=trim(coalesce(data->>'link',''));
   if length(newname) not between 1 and 200 or length(newlink)>2048 or newlink !~* '^https?://[^[:space:]]+$' then raise exception 'Informe nome e link HTTP ou HTTPS válidos.'; end if;
   insert into impulso_private.projects(team_id,name,link) values(tid,newname,newlink) on conflict(team_id) do update set name=excluded.name,link=excluded.link; return jsonb_build_object('ok',true);
 elsif op='project_details' then
   if not is_teacher then raise exception 'Apenas o professor pode complementar os dados.'; end if;
   select p.* into project_row from impulso_private.projects p join impulso_private.teams t on t.id=p.team_id where p.id=(data->>'id')::uuid and t.teacher_id=teacher;
   if not found then raise exception 'Demanda não encontrada.'; end if;
   update impulso_private.projects set name=trim(coalesce(data->>'name','')), description=coalesce(data->>'description',''), benefits=coalesce(data->>'benefits',''), details=coalesce(data->>'details',''), restrictions=coalesce(data->>'restrictions',''), company=coalesce(data->>'company',''), area=coalesce(data->>'area',''),validity=nullif(data->>'validity','')::date, details_completed=true where id=project_row.id;
   return jsonb_build_object('ok',true);
 elsif op='save_task' then
   select p.* into project_row from impulso_private.projects p join impulso_private.teams t on t.id=p.team_id where p.id=(data->>'project_id')::uuid and t.teacher_id=teacher and (is_teacher or t.id=tid);
   if not found then raise exception 'Demanda não encontrada.'; end if;
   if coalesce(data->>'id','')='' then
     insert into impulso_private.tasks(project_id,name,deadline,status,link,notes) values(project_row.id,trim(coalesce(data->>'name','')),(data->>'deadline')::date,coalesce(data->>'status','pending'),coalesce(data->>'link',''),coalesce(data->>'notes',''));
   else
     update impulso_private.tasks set name=trim(coalesce(data->>'name','')),deadline=(data->>'deadline')::date,status=coalesce(data->>'status','pending'),link=coalesce(data->>'link',''),notes=coalesce(data->>'notes','') where id=(data->>'id')::uuid and project_id=project_row.id;
     if not found then raise exception 'Atividade não encontrada.'; end if;
   end if; return jsonb_build_object('ok',true);
 elsif op='post' then
   if is_teacher then
     if coalesce(data->>'team_id','')='' then target_id:=null; else target_id:=(data->>'team_id')::uuid; if not exists(select 1 from impulso_private.teams where id=target_id and teacher_id=teacher) then raise exception 'Grupo não encontrado.'; end if; end if;
     newname:=(select name from impulso_private.teachers where user_id=u);
   else if tid is null then raise exception 'Crie ou entre em um grupo para publicar.'; end if; target_id:=tid; newname:=(select name from impulso_private.students where id=sid); end if;
   insert into impulso_private.messages(teacher_id,team_id,author,body) values(teacher,target_id,newname,trim(coalesce(data->>'body',''))); return jsonb_build_object('ok',true);
 else raise exception 'Ação desconhecida.';
 end if;
end $$;
revoke all on function public.impulso(text,jsonb) from public, anon, authenticated;
grant execute on function public.impulso(text,jsonb) to authenticated;
commit;

notify pgrst, 'reload schema';
