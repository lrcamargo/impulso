-- alpha.10: pontos configuráveis em atividades. Requer alpha.9 já aplicada.
-- Faça backup e atualize banco e site na mesma janela de manutenção.
begin;
alter table impulso_private.learning_activities add column point_value integer not null default 0 check(point_value between 0 and 1000000);
-- Preserve a regra anterior: atividades específicas migradas já valiam 100.
update impulso_private.learning_activities set point_value=100 where points_enabled=true;
create index learning_activities_teacher_team_idx on impulso_private.learning_activities(teacher_id,team_id);

-- Valores são calculados sobre os registros atuais, sem gravar créditos duplicados.
create function impulso_private.team_score(p_team uuid) returns bigint
language sql stable security definer set search_path=pg_catalog,impulso_private,auth as $$
 select coalesce(sum(a.point_value),0)::bigint from impulso_private.teams t
 join impulso_private.learning_activities a on a.teacher_id=t.teacher_id and (a.team_id is null or a.team_id=t.id)
 join impulso_private.learning_activity_progress p on p.activity_id=a.id and p.team_id=t.id and p.status='delivered'
 where t.id=p_team
$$;
create function impulso_private.student_score(p_student uuid) returns bigint
language sql stable security definer set search_path=pg_catalog,impulso_private,auth as $$
 select coalesce(sum(a.point_value),0)::bigint from impulso_private.students s
 join impulso_private.members m on m.student_id=s.id
 join impulso_private.teams t on t.id=m.team_id and t.teacher_id=s.teacher_id
 join impulso_private.learning_activities a on a.teacher_id=t.teacher_id and (a.team_id is null or a.team_id=t.id)
 left join impulso_private.learning_activity_progress p on p.activity_id=a.id and p.team_id=t.id
 left join impulso_private.learning_individual_deliveries d on d.activity_id=a.id and d.team_id=t.id and d.student_id=s.id
 where s.id=p_student and ((a.delivery_mode='group' and p.status='delivered') or (a.delivery_mode='everyone' and d.status='delivered'))
$$;
revoke all on function impulso_private.team_score(uuid) from public,anon,authenticated;
revoke all on function impulso_private.student_score(uuid) from public,anon,authenticated;

alter function public.impulso_learning(text,jsonb) rename to impulso_learning_v9;
revoke all on function public.impulso_learning_v9(text,jsonb) from public,anon,authenticated;
create function public.impulso_learning(op text,data jsonb default '{}'::jsonb) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare base jsonb; who jsonb; u uuid:=auth.uid(); sid uuid; teacher uuid; is_teacher boolean; value_text text; n integer; result jsonb; item_id uuid;
begin
 who:=public.impulso('load','{}'::jsonb);
 if coalesce((who->>'password_change_required')::boolean,false) then raise exception 'Troque sua senha inicial antes de continuar.'; end if;
 is_teacher:=(who->>'role'='professor');
 if is_teacher then teacher:=u; else select id,teacher_id into sid,teacher from impulso_private.students where user_id=u; if sid is null then raise exception 'Aluno não encontrado.'; end if; end if;
 if op='save_activity' then
   if not is_teacher then raise exception 'Somente a professora pode criar ou editar atividades.'; end if;
   if data ? 'point_value' then
     value_text:=coalesce(data->>'point_value','');
     if value_text !~ '^(0|[1-9][0-9]{0,6})$' then raise exception 'Informe pontos inteiros entre 0 e 1.000.000.'; end if;
     n:=value_text::integer;
     if n>1000000 then raise exception 'Informe pontos inteiros entre 0 e 1.000.000.'; end if;
   end if;
   result:=public.impulso_learning_v9(op,data);
   item_id:=(result->>'id')::uuid;
   if data ? 'point_value' then update impulso_private.learning_activities set point_value=n where id=item_id and teacher_id=teacher; end if;
   return result;
 elsif op='load' then
   base:=public.impulso_learning_v9(op,data);
   select coalesce(jsonb_agg(z.item || jsonb_build_object('point_value',a.point_value) order by z.ord),'[]'::jsonb) into result from jsonb_array_elements(base->'activities') with ordinality z(item,ord) join impulso_private.learning_activities a on a.id=(z.item->>'id')::uuid;
   base:=jsonb_set(base,'{activities}',result);
   select coalesce(jsonb_agg(z.item || jsonb_build_object('point_value',a.point_value) order by z.ord),'[]'::jsonb) into result from jsonb_array_elements(base->'definitions') with ordinality z(item,ord) join impulso_private.learning_activities a on a.id=(z.item->>'id')::uuid;
   base:=jsonb_set(base,'{definitions}',result);
   return base || jsonb_build_object(
     'my_points',case when not is_teacher then impulso_private.student_score(sid) else null end,
     'student_points',case when is_teacher then coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'points',impulso_private.student_score(s.id)) order by s.name) from impulso_private.students s where s.teacher_id=teacher),'[]'::jsonb) else '[]'::jsonb end,
     'team_points',coalesce((select jsonb_agg(jsonb_build_object('id',t.id,'points',impulso_private.team_score(t.id)) order by t.name) from impulso_private.teams t where t.teacher_id=teacher and (is_teacher or exists(select 1 from impulso_private.members m where m.team_id=t.id and m.student_id=sid))),'[]'::jsonb));
 end if;
 return public.impulso_learning_v9(op,data);
end $$;
revoke all on function public.impulso_learning(text,jsonb) from public,anon,authenticated;
grant execute on function public.impulso_learning(text,jsonb) to authenticated;

-- Perfil do aluno continua restrito ao professor responsável.
alter function public.impulso_student_report(uuid) rename to impulso_student_report_v9;
revoke all on function public.impulso_student_report_v9(uuid) from public,anon,authenticated;
create function public.impulso_student_report(p_student_id uuid) returns jsonb
language plpgsql security definer set search_path=pg_catalog,impulso_private,auth as $$
declare report jsonb;
begin
 report:=public.impulso_student_report_v9(p_student_id);
 return report || jsonb_build_object('points',impulso_private.student_score(p_student_id));
end $$;
revoke all on function public.impulso_student_report(uuid) from public,anon,authenticated;
grant execute on function public.impulso_student_report(uuid) to authenticated;
commit;
notify pgrst,'reload schema';
