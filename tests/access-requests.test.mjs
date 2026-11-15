import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import {readFile} from 'node:fs/promises'; import assert from 'node:assert/strict';
const db=new PGlite({extensions:{pgcrypto}});
await db.exec(`create role anon; create role authenticated; create schema auth; create table auth.users(id uuid primary key,email text,email_confirmed_at timestamptz,encrypted_password text); create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$; grant usage on schema auth to authenticated; grant execute on function auth.uid() to authenticated;`);
await db.exec(await readFile('supabase/schema.sql','utf8'));
await db.exec(await readFile('database-updates/202611130001_access_requests.sql','utf8'));
const ids={teacher:'10000000-0000-4000-8000-000000000001',student:'20000000-0000-4000-8000-000000000001',intruder:'20000000-0000-4000-8000-000000000002'};
await db.query(`insert into auth.users(id,email,email_confirmed_at,encrypted_password) values($1,'teacher@example.org',now(),extensions.crypt('teacher-pass', extensions.gen_salt('bf',5)))`,[ids.teacher]);
await db.query(`insert into impulso_private.teachers(user_id,name) values($1,'Professora')`,[ids.teacher]);
async function role(r){await db.exec('set role '+r)} async function as(id){await db.query("select set_config('request.jwt.claim.sub',$1,false)",[id])}
async function q(sql,params=[]){return (await db.query(sql,params)).rows[0]?.result} async function rpc(op,data={}){return q('select public.impulso($1,$2::jsonb) as result',[op,JSON.stringify(data)])}
async function rejects(fn,label){let err=null;try{await fn()}catch(e){err=e}assert(err,label+' deve ser negado')}
await role('anon'); await q('select public.impulso_request_access($1,$2) as result',['Estudante','student@example.org']);await q('select public.impulso_request_access($1,$2) as result',['Estudante','student@example.org']);await rejects(()=>q('select public.impulso_requests() as result'),'lista anônima');
await role('authenticated'); await as(ids.teacher); let requests=await q('select public.impulso_requests() as result'); assert.equal(requests.length,1);const request=requests[0];
await rejects(()=>rpc('add_student',{name:'Teste',email:'student@example.org'}),'cadastro antigo');
const prepared=await q('select public.impulso_begin_student($1,$2,$3) as result',['Estudante','student@example.org',request.id]);
await role('none');
await db.query(`insert into auth.users(id,email,email_confirmed_at,encrypted_password) values($1,'student@example.org',now(),extensions.crypt('Generic123', extensions.gen_salt('bf',5)))`,[ids.student]);
await role('authenticated');await as(ids.student);await rejects(()=>rpc('load'),'acesso durante provisionamento');await rejects(()=>q('select public.impulso_requests() as result'),'estudante listar pedidos');await rejects(()=>q('select public.impulso_v1($1,$2::jsonb) as result',['load','{}']),'burlar função antiga');
await as(ids.teacher);await q('select public.impulso_finish_student($1,$2) as result',[prepared.student_id,ids.student]);requests=await q('select public.impulso_requests() as result');assert.equal(requests.length,0);
await as(ids.student);assert.equal((await rpc('load')).password_change_required,true);await rejects(()=>rpc('create_team',{name:'Tentativa'}),'criar grupo antes da troca');await rejects(()=>q('select public.impulso_finish_password($1) as result',['Generic123']),'reutilizar senha inicial');
await role('none');await db.query(`update auth.users set encrypted_password=extensions.crypt('OutraSenha123',extensions.gen_salt('bf',5)) where id=$1`,[ids.student]);
await role('authenticated');await as(ids.student);await rejects(()=>q('select public.impulso_finish_password($1) as result',['Errada123']),'informar senha errada');await q('select public.impulso_finish_password($1) as result',['OutraSenha123']);assert.equal((await rpc('load')).role,'aluno');await rpc('create_team',{name:'Grupo'});
await as(ids.intruder);await rejects(()=>q('select public.impulso_begin_student($1,$2,$3) as result',['Atacante','x@example.org',null]),'terceiro criar aluno');await rejects(()=>q('select * from impulso_private.first_passwords'),'ler hashes');
console.log('Testes de solicitações, bloqueio, senha inicial e permissões passaram.');await db.close();
