-- IMPULSO 0.1.0-alpha.13: LINKS MANUAIS E MURAL.
-- Pré-requisito: alpha.12 revisada, SQL 008/009 já instalados.
-- Sem upload automático. Executar uma vez após aprovação e backup.
begin;

-- Fonte: database-updates/202611130011_link_local_entrega.sql
-- Link manual de entrega, por atividade, para alpha.12 revisada (008/009).
-- Independente do SQL 010. Não aplicar sem backup e autorização; executar uma vez.
do $$ begin
 if to_regprocedure('public.impulso_learning(text,jsonb)') is null or to_regprocedure('public.impulso_group_admin(text,jsonb)') is null or to_regclass('impulso_private.learning_badges') is null then raise exception 'Pré-requisitos alpha.12 ausentes.'; end if;
 if exists(select 1 from information_schema.columns where table_schema='impulso_private' and table_name='learning_activities' and column_name='delivery_destination_url') or to_regprocedure('public.impulso_learning_before_delivery_link(text,jsonb)') is not null then raise exception 'A atualização de link já foi aplicada. Não execute novamente.'; end if;
 if not exists(select 1 from pg_proc p where p.oid=to_regprocedure('public.impulso_learning(text,jsonb)')
  and md5(replace(p.prosrc,chr(13)||chr(10),chr(10)))='9ed808a07aee3fe0200044e46821b530' and p.prosecdef and p.provolatile='v'
  and p.proconfig=array['search_path=pg_catalog, impulso_private, auth']::text[]
  and has_function_privilege('authenticated',p.oid,'EXECUTE') and not has_function_privilege('anon',p.oid,'EXECUTE')) then raise exception 'A função de atividades difere da versão revisada. Interrompa e peça orientação.'; end if;
end $$;
alter table impulso_private.learning_activities add column delivery_destination_url text not null default '' check (length(delivery_destination_url)<=2048 and (delivery_destination_url='' or delivery_destination_url ~ '^https://[^[:space:]/?#@]+([/?#][^[:space:]]*)?$'));
alter table impulso_private.learning_activities add column delivery_destination_mode text not null default 'all' check(delivery_destination_mode in ('all','group'));
create table impulso_private.learning_delivery_destinations(
 activity_id uuid not null references impulso_private.learning_activities(id) on delete cascade,
 team_id uuid not null references impulso_private.teams(id) on delete cascade,
 url text not null check(length(url)<=2048 and (url='' or url ~ '^https://[^[:space:]/?#@]+([/?#][^[:space:]]*)?$')),
 primary key(activity_id,team_id)
);
alter table impulso_private.learning_delivery_destinations enable row level security;
revoke all on impulso_private.learning_delivery_destinations from public,anon,authenticated;
alter function public.impulso_learning(text,jsonb) rename to impulso_learning_before_delivery_link;
revoke all on function public.impulso_learning_before_delivery_link(text,jsonb) from public,anon,authenticated;
create function public.impulso_learning(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare result jsonb; dest text; activity_id uuid; items jsonb; mode text; pair record; team_uuid uuid; activity_row impulso_private.learning_activities%rowtype;
begin
 if op='save_activity' then
  if data ? 'delivery_destination_url' then
   if jsonb_typeof(data->'delivery_destination_url')<>'string' then raise exception 'Informe um link HTTPS válido.'; end if;
   dest:=trim(data->>'delivery_destination_url');
   if length(dest)>2048 or (dest<>'' and dest !~ '^https://[^[:space:]/?#@]+([/?#][^[:space:]]*)?$') then raise exception 'Informe um link HTTPS válido.'; end if;
  end if;
  if data ? 'delivery_destination_mode' then mode:=data->>'delivery_destination_mode';if mode not in ('all','group') or mode is null then raise exception 'Escolha um tipo de link válido.'; end if;end if;
  if data ? 'delivery_group_links' and (jsonb_typeof(data->'delivery_group_links')<>'object' or length((data->'delivery_group_links')::text)>100000) then raise exception 'Lista de links inválida.'; end if;
 end if;
 result:=public.impulso_learning_before_delivery_link(op,data);
 if op='save_activity' then
  activity_id:=nullif(result->>'id','')::uuid;
  select * into activity_row from impulso_private.learning_activities where id=activity_id and teacher_id=auth.uid() for update;
  if not found then raise exception 'Atividade não encontrada.'; end if;
  update impulso_private.learning_activities set delivery_destination_url=coalesce(dest,delivery_destination_url),delivery_destination_mode=coalesce(mode,delivery_destination_mode) where id=activity_id;
  if data ? 'delivery_group_links' then
   for pair in select key,value from jsonb_each(data->'delivery_group_links') loop
    begin team_uuid:=pair.key::uuid; exception when invalid_text_representation then raise exception 'Grupo inválido.'; end;
    if jsonb_typeof(pair.value)<>'string' then raise exception 'Link de grupo inválido.'; end if;
    dest:=trim(pair.value#>>'{}');
    if length(dest)>2048 or (dest<>'' and dest !~ '^https://[^[:space:]/?#@]+([/?#][^[:space:]]*)?$') then raise exception 'Informe um link HTTPS válido para cada grupo.'; end if;
    if not exists(select 1 from impulso_private.teams t where t.id=team_uuid and t.teacher_id=auth.uid() and (activity_row.team_id is null or activity_row.team_id=t.id)) then raise exception 'Grupo não autorizado para esta atividade.'; end if;
    insert into impulso_private.learning_delivery_destinations(activity_id,team_id,url) values(activity_id,team_uuid,dest) on conflict on constraint learning_delivery_destinations_pkey do update set url=excluded.url;
   end loop;
  end if;
 elsif op='load' then
  -- Definitions are already restricted to the authenticated teacher by the legacy function.
  select coalesce(jsonb_agg(z.item||jsonb_build_object('delivery_destination_url',a.delivery_destination_url,'delivery_destination_mode',a.delivery_destination_mode,'delivery_group_links',coalesce((select jsonb_object_agg(d.team_id::text,d.url) from impulso_private.learning_delivery_destinations d join impulso_private.teams t on t.id=d.team_id and t.teacher_id=a.teacher_id where d.activity_id=a.id),'{}'::jsonb)) order by z.ord),'[]'::jsonb) into items
   from jsonb_array_elements(result->'definitions') with ordinality z(item,ord) join impulso_private.learning_activities a on a.id=(z.item->>'id')::uuid;
  result:=jsonb_set(result,'{definitions}',items);
  -- Students get only the URL for their own team; the mapping is never returned.
  select coalesce(jsonb_agg(z.item||jsonb_build_object('delivery_destination_url',case when a.delivery_destination_mode='all' then a.delivery_destination_url else coalesce((select d.url from impulso_private.learning_delivery_destinations d where d.activity_id=a.id and d.team_id=(z.item->>'team_id')::uuid),'') end,'delivery_destination_mode',a.delivery_destination_mode) order by z.ord),'[]'::jsonb) into items
   from jsonb_array_elements(result->'activities') with ordinality z(item,ord) join impulso_private.learning_activities a on a.id=(z.item->>'id')::uuid;
  result:=jsonb_set(result,'{activities}',items);
  result:=result||jsonb_build_object('delivery_destination_supported',true);
 end if;
 return result;
end $$;
revoke all on function public.impulso_learning(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso_learning(text,jsonb) to authenticated;



-- Fonte: database-updates/202611130012_mural_canais.sql
-- Mural com canal da turma, grupo e conversa individual com o professor.
-- Candidata para alpha.12 revisada; executar uma vez após backup e aprovação.
do $$ begin
 if to_regprocedure('public.impulso_before_mural_channels(text,jsonb)') is not null or to_regclass('impulso_private.mural_private_messages') is not null then raise exception 'A atualização do mural já foi aplicada.'; end if;
 if not exists(select 1 from pg_proc p where p.oid=to_regprocedure('public.impulso(text,jsonb)') and md5(replace(p.prosrc,chr(13)||chr(10),chr(10)))='b03f608d43b3c362bd1541da0f6b3a21' and p.prosecdef and p.provolatile='v' and p.proconfig=array['search_path=pg_catalog, impulso_private, auth']::text[] and has_function_privilege('authenticated',p.oid,'EXECUTE') and not has_function_privilege('anon',p.oid,'EXECUTE')) then raise exception 'A função principal difere da versão revisada. Interrompa e peça orientação.'; end if;
end $$;
-- Private messages are separate from the legacy public/group table so an old
-- internal implementation of load cannot inadvertently read them.
create table impulso_private.mural_private_messages(
 id uuid primary key default gen_random_uuid(),
 teacher_id uuid not null references impulso_private.teachers(user_id),
 student_id uuid not null references impulso_private.students(id),
 author_user_id uuid not null references auth.users(id),
 author text not null check(length(author) between 1 and 120),
 body text not null check(length(body) between 1 and 5000),
 created_at timestamptz not null default now()
);
create index impulso_mural_private_teacher_student_date on impulso_private.mural_private_messages(teacher_id,student_id,created_at desc);
alter table impulso_private.mural_private_messages enable row level security;
revoke all on impulso_private.mural_private_messages from public,anon,authenticated;

alter function public.impulso(text,jsonb) rename to impulso_before_mural_channels;
revoke all on function public.impulso_before_mural_channels(text,jsonb) from public,anon,authenticated;
create function public.impulso(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare base jsonb; u uuid:=auth.uid(); teacher uuid; sid uuid; tid uuid; target uuid; who text; actor_name text; text_body text; channel text; combined jsonb;
begin
 if op not in ('load','post') or (op='post' and not (data ? 'channel')) then return public.impulso_before_mural_channels(op,data); end if;
 base:=public.impulso_before_mural_channels('load','{}'::jsonb);
 if coalesce((base->>'password_change_required')::boolean,false) then
  if op='load' then return base; else raise exception 'Troque sua senha inicial antes de continuar.'; end if;
 end if;
 who:=coalesce(base->>'role','');
 if who='professor' then teacher:=u;select name into actor_name from impulso_private.teachers where user_id=u;
 elsif who='aluno' then select id,teacher_id,name into sid,teacher,actor_name from impulso_private.students where user_id=u;select team_id into tid from impulso_private.members where student_id=sid;
 else raise exception 'Acesso não autorizado.'; end if;
 if op='load' then
  select coalesce(jsonb_agg(q.item order by q.created_at desc,q.sort_id desc),'[]'::jsonb) into combined from (
   select item||jsonb_build_object('channel',case when item->>'team_id' is null then 'all' else 'group' end) as item,
    (item->>'created_at')::timestamptz as created_at,item->>'id' as sort_id
    from jsonb_array_elements(base->'messages') item
   union all
   select jsonb_build_object('id',m.id,'channel','teacher','team_id',null,'team_name',case when who='professor' then 'Conversa com '||s.name else 'Conversa com professor' end,
     'author',m.author,'body',m.body,'created_at',m.created_at,'student_id',case when who='professor' then m.student_id else null end),m.created_at,m.id::text
   from impulso_private.mural_private_messages m join impulso_private.students s on s.id=m.student_id and s.teacher_id=m.teacher_id
   where m.teacher_id=teacher and (who='professor' or m.student_id=sid)
   order by created_at desc,sort_id desc limit 100
  ) q;
  return jsonb_set(base,'{messages}',combined)||jsonb_build_object('mural_channels_supported',true);
 end if;
 channel:=data->>'channel';text_body:=trim(coalesce(data->>'body',''));
 if channel not in ('all','group','teacher') or channel is null or length(text_body) not between 1 and 5000 then raise exception 'Confira o canal e a mensagem.'; end if;
 if channel='teacher' then
  if who='professor' then
   begin target:=nullif(data->>'student_id','')::uuid; exception when invalid_text_representation then raise exception 'Aluno inválido.'; end;
   if not exists(select 1 from impulso_private.students s where s.id=target and s.teacher_id=teacher) then raise exception 'Aluno não encontrado.'; end if;
  else target:=sid;end if;
  insert into impulso_private.mural_private_messages(teacher_id,student_id,author_user_id,author,body) values(teacher,target,u,actor_name,text_body);
 elsif channel='all' then
  insert into impulso_private.messages(teacher_id,team_id,author,body) values(teacher,null,actor_name,text_body);
 else
  if who='professor' then
   begin target:=nullif(data->>'team_id','')::uuid; exception when invalid_text_representation then raise exception 'Grupo inválido.'; end;
   if not exists(select 1 from impulso_private.teams t where t.id=target and t.teacher_id=teacher) then raise exception 'Grupo não encontrado.'; end if;
  else target:=tid;if target is null then raise exception 'Entre em um grupo para publicar neste canal.';end if;end if;
  insert into impulso_private.messages(teacher_id,team_id,author,body) values(teacher,target,actor_name,text_body);
 end if;
 return jsonb_build_object('ok',true);
end $$;
revoke all on function public.impulso(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso(text,jsonb) to authenticated;
-- A distinct endpoint ensures a new client cannot silently fall back to the
-- legacy post behavior if this migration is absent or later rolled back.
create function public.impulso_mural_post(p_channel text,p_team uuid,p_student uuid,p_body text) returns jsonb
language sql security definer set search_path=pg_catalog,impulso_private,auth as $$
 select public.impulso('post',jsonb_build_object('channel',p_channel,'team_id',p_team,'student_id',p_student,'body',p_body))
$$;
revoke all on function public.impulso_mural_post(text,uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.impulso_mural_post(text,uuid,uuid,text) to authenticated;



commit;
notify pgrst,'reload schema';
