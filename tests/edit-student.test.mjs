import {PGlite} from '@electric-sql/pglite';
import {pgcrypto} from '@electric-sql/pglite/contrib/pgcrypto';
import {readFile} from 'node:fs/promises';
import assert from 'node:assert/strict';
const db=new PGlite({extensions:{pgcrypto}});
await db.exec(`create role anon; create role authenticated; create schema auth; create table auth.users(id uuid primary key,email text unique,email_confirmed_at timestamptz,encrypted_password text); create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$; grant usage on schema auth to authenticated; grant execute on function auth.uid() to authenticated;`);
for (const file of ['supabase/schema.sql','database-updates/202611130001_access_requests.sql','database-updates/202611130002_edit_students.sql']) await db.exec(await readFile(file,'utf8'));
const teacher='10000000-0000-4000-8000-000000000001',otherTeacher='10000000-0000-4000-8000-000000000002',student='20000000-0000-4000-8000-000000000001',otherStudent='20000000-0000-4000-8000-000000000002';
await db.query(`insert into auth.users(id,email,email_confirmed_at,encrypted_password) values ($1,'teacher@example.test',now(),extensions.crypt('teacher123',extensions.gen_salt('bf',5))),($2,'otherteacher@example.test',now(),extensions.crypt('other123',extensions.gen_salt('bf',5))),($3,'student@example.test',now(),extensions.crypt('Initial123',extensions.gen_salt('bf',5))),($4,'taken@example.test',now(),extensions.crypt('Other123',extensions.gen_salt('bf',5)))`,[teacher,otherTeacher,student,otherStudent]);
await db.query(`insert into impulso_private.teachers(user_id,name) values ($1,'Teacher'),($2,'Other')`,[teacher,otherTeacher]);
const initial=(await db.query(`insert into impulso_private.students(teacher_id,name,email,user_id) values($1,'Nome Antigo','student@example.test',$2) returning id`,[teacher,student])).rows[0].id;
const team=(await db.query(`insert into impulso_private.teams(teacher_id,name) values ($1,'Grupo') returning id`,[teacher])).rows[0].id;
await db.query(`insert into impulso_private.members(team_id,student_id) values ($1,$2)`,[team,initial]);
await db.query(`insert into impulso_private.first_passwords(student_id,initial_password_hash) select $1,encrypted_password from auth.users where id=$2`,[initial,student]);
async function as(id){await db.query("select set_config('request.jwt.claim.sub',$1,false)",[id])}
async function role(r){await db.exec('set role '+r)}
async function q(sql,args=[]){return (await db.query(sql,args)).rows[0]?.result}
async function rejects(fn,label){let e=null;try{await fn()}catch(x){e=x}assert(e,label+' deveria ser negado')}
await role('authenticated');await as(student);await rejects(()=>q('select public.impulso_prepare_edit($1,$2,$3) as result',[initial,'Intruso','other@example.test']),'aluno editar a si');
await as(otherTeacher);await rejects(()=>q('select public.impulso_prepare_edit($1,$2,$3) as result',[initial,'Intruso','other@example.test']),'outro professor');
await as(teacher);
let renamed=await q('select public.impulso_prepare_edit($1,$2,$3) as result',[initial,'Nome Correto','student@example.test']);assert.equal(renamed.status,'done');
await rejects(()=>q('select public.impulso_prepare_edit($1,$2,$3) as result',[initial,'Nome Correto','taken@example.test']),'e-mail de outra conta');
let pending=await q('select public.impulso_prepare_edit($1,$2,$3) as result',[initial,'Nome Correto','correct@example.test']);assert.equal(pending.status,'pending');
let repeat=await q('select public.impulso_prepare_edit($1,$2,$3) as result',[initial,'Nome Correto','correct@example.test']);assert.equal(repeat.job_id,pending.job_id);
await rejects(()=>q('select public.impulso_prepare_edit($1,$2,$3) as result',[initial,'Diferente','another@example.test']),'alteração concorrente');
await rejects(()=>q('select public.impulso_finish_edit($1) as result',[pending.job_id]),'finalizar antes de alterar Auth');
await role('none');let originalHash=(await db.query('select encrypted_password from auth.users where id=$1',[student])).rows[0].encrypted_password;
await db.query('update auth.users set email=$1 where id=$2',['correct@example.test',student]);
await role('authenticated');await as(teacher);await rejects(()=>q('select public.impulso_cancel_edit($1) as result',[pending.job_id]),'cancelar após alterar Auth');
assert.equal((await q('select public.impulso_finish_edit($1) as result',[pending.job_id])).ok,true);assert.equal((await q('select public.impulso_finish_edit($1) as result',[pending.job_id])).ok,true);
await role('none');let current=(await db.query('select s.name,s.email,s.user_id,m.team_id,a.encrypted_password from impulso_private.students s join impulso_private.members m on m.student_id=s.id join auth.users a on a.id=s.user_id where s.id=$1',[initial])).rows[0];assert.equal(current.name,'Nome Correto');assert.equal(current.email,'correct@example.test');assert.equal(current.user_id,student);assert.equal(current.team_id,team);assert.equal(current.encrypted_password,originalHash);
await role('authenticated');await as(student);let state=await q('select public.impulso($1,$2::jsonb) as result',['load','{}']);assert.equal(state.password_change_required,true);
await as(teacher);let pending2=await q('select public.impulso_prepare_edit($1,$2,$3) as result',[initial,'Nome Correto','yet-another@example.test']);assert.equal((await q('select public.impulso_cancel_edit($1) as result',[pending2.job_id])).status,'cancelled');
await role('none');const unlinked=(await db.query("insert into impulso_private.students(teacher_id,name,email) values($1,'Sem conta','orphan@example.test') returning id",[teacher])).rows[0].id;
await role('authenticated');await as(teacher);assert.equal((await q('select public.impulso_prepare_edit($1,$2,$3) as result',[unlinked,'Sem conta corrigido','orphan-fixed@example.test'])).status,'done');await rejects(()=>q('select * from impulso_private.student_edit_jobs'),'leitura direta de dados privados');
console.log('Testes de edição, permissões, recuperação, preservação de senha e grupo passaram.');await db.close();
