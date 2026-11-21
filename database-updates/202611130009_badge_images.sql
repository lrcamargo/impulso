-- Alpha.12: imagens públicas de medalhas no Storage. Executar depois do SQL 008.
-- As imagens não devem conter dados pessoais. Tamanho máximo 2 MiB.
begin;
alter table impulso_private.learning_badges add column image_path text not null default '';
alter table impulso_private.learning_badges add constraint learning_badge_image_path_format check (image_path='' or (length(image_path)<=200 and image_path ~ '^[0-9a-f-]{36}/[0-9a-f-]{36}\.(png|jpg|webp)$'));
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
 values('impulso-medalhas','impulso-medalhas',true,2097152,array['image/png','image/jpeg','image/webp'])
 on conflict(id) do nothing;
-- Abortar se houver um bucket com o mesmo nome e configuração diferente.
do $$ begin if not exists(select 1 from storage.buckets where id='impulso-medalhas' and public=true and file_size_limit=2097152 and allowed_mime_types @> array['image/png','image/jpeg','image/webp']::text[] and allowed_mime_types <@ array['image/png','image/jpeg','image/webp']::text[]) then raise exception 'O bucket impulso-medalhas já existe com configuração diferente. Pare e peça orientação.'; end if; end $$;
create function public.impulso_badge_upload_allowed() returns boolean
language sql stable security definer set search_path=pg_catalog,impulso_private,auth as $$
 select exists(select 1 from impulso_private.teachers where user_id=auth.uid())
$$;
revoke all on function public.impulso_badge_upload_allowed() from public,anon,authenticated;
grant execute on function public.impulso_badge_upload_allowed() to authenticated;
create policy impulso_badge_image_insert on storage.objects for insert to authenticated with check (
 bucket_id='impulso-medalhas' and public.impulso_badge_upload_allowed() and name ~ ('^'||auth.uid()::text||'/[0-9a-f-]{36}\.(png|jpg|webp)$')
);
create policy impulso_badge_image_select on storage.objects for select to authenticated using (
 bucket_id='impulso-medalhas' and public.impulso_badge_upload_allowed() and name ~ ('^'||auth.uid()::text||'/[0-9a-f-]{36}\.(png|jpg|webp)$')
);
create policy impulso_badge_image_delete on storage.objects for delete to authenticated using (
 bucket_id='impulso-medalhas' and public.impulso_badge_upload_allowed() and name ~ ('^'||auth.uid()::text||'/[0-9a-f-]{36}\.(png|jpg|webp)$')
);

alter function public.impulso_learning(text,jsonb) rename to impulso_learning_v10;
revoke all on function public.impulso_learning_v10(text,jsonb) from public,anon,authenticated;
create function public.impulso_learning(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare state jsonb; base jsonb; items jsonb; u uuid:=auth.uid(); is_teacher boolean; bid uuid; n text; ic text; path text;
begin
 state:=public.impulso('load','{}'::jsonb);
 if coalesce((state->>'password_change_required')::boolean,false) then raise exception 'Troque sua senha inicial antes de continuar.'; end if;
 is_teacher:=state->>'role'='professor';
 if op='save_badge' then
  if not is_teacher then raise exception 'Somente o responsável pode gerenciar medalhas.'; end if;
  n:=trim(coalesce(data->>'name',''));ic:=coalesce(data->>'icon','');path:=coalesce(data->>'image_path','');
  if length(n) not between 1 and 100 or ic not in ('star','bulb','group','flag','rocket') then raise exception 'Confira o nome e o símbolo da medalha.'; end if;
  if path<>'' and (path !~ ('^'||u::text||'/[0-9a-f-]{36}\.(png|jpg|webp)$') or not exists(select 1 from storage.objects where bucket_id='impulso-medalhas' and name=path)) then raise exception 'Imagem não encontrada ou não autorizada.'; end if;
  bid:=nullif(data->>'id','')::uuid;
  if bid is null then insert into impulso_private.learning_badges(teacher_id,name,icon,image_path) values(u,n,ic,path) returning id into bid;
  else update impulso_private.learning_badges set name=n,icon=ic,image_path=path where id=bid and teacher_id=u;
   if not found then raise exception 'Medalha não encontrada.'; end if;
  end if;
  return jsonb_build_object('ok',true,'id',bid);
 elsif op='load' then
  base:=public.impulso_learning_v10(op,data);
  select coalesce(jsonb_agg(z.item||jsonb_build_object('image_path',b.image_path) order by z.ord),'[]'::jsonb) into items
   from jsonb_array_elements(base->'badges') with ordinality z(item,ord) join impulso_private.learning_badges b on b.id=(z.item->>'id')::uuid;
  return jsonb_set(base,'{badges}',items);
 end if;
 return public.impulso_learning_v10(op,data);
end $$;
revoke all on function public.impulso_learning(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso_learning(text,jsonb) to authenticated;
commit;
notify pgrst,'reload schema';
