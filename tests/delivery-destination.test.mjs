import {PGlite} from '@electric-sql/pglite';
import {pgcrypto} from '@electric-sql/pglite/contrib/pgcrypto';
import {readFile} from 'node:fs/promises';
import assert from 'node:assert/strict';
const db=new PGlite({extensions:{pgcrypto}});
try {
 await db.exec(`create role anon;create role authenticated;create schema auth;create table auth.users(id uuid primary key,email text,email_confirmed_at timestamptz,encrypted_password text);create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;grant usage on schema auth to authenticated;grant execute on function auth.uid() to authenticated;create schema storage;create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);create table storage.objects(id uuid default gen_random_uuid(),bucket_id text,name text);alter table storage.objects enable row level security;grant usage on schema storage to authenticated;grant select,insert,delete on storage.objects to authenticated;`);
 for(const p of ['supabase/schema.sql',...Array.from({length:9},(_,i)=>[`database-updates/202611130001_access_requests.sql`,`database-updates/202611130002_edit_students.sql`,`database-updates/202611130003_first_access_medal.sql`,`database-updates/202611130004_profile_general_tasks.sql`,`database-updates/202611130005_activities_and_badges.sql`,`database-updates/202611130006_individual_delivery.sql`,`database-updates/202611130007_activity_points.sql`,`database-updates/202611130008_group_admin.sql`,`database-updates/202611130009_badge_images.sql`][i])])await db.exec(await readFile(p,'utf8'));
 const migration=await readFile('database-updates/202611130011_alpha13_links_e_mural.sql','utf8');await db.exec(migration);await assert.rejects(()=>db.exec(migration),/difere|já foi aplicada/i);await db.exec('rollback');
 const t='10000000-0000-4000-8000-000000000001',other='10000000-0000-4000-8000-000000000002',a='20000000-0000-4000-8000-000000000001',b='20000000-0000-4000-8000-000000000002',c='20000000-0000-4000-8000-000000000003';
 for(const [id,email] of [[t,'teacher@example.test'],[other,'other@example.test'],[a,'a@example.test'],[b,'b@example.test'],[c,'c@example.test']])await db.query('insert into auth.users(id,email,email_confirmed_at) values($1,$2,now())',[id,email]);
 for(const id of [t,other])await db.query("insert into impulso_private.teachers(user_id,name) values($1,'Responsável')",[id]);
 for(const [id,owner] of [[a,t],[b,other],[c,t]])await db.query("insert into impulso_private.students(teacher_id,name,email,user_id) select $1,'Aluno',email,id from auth.users where id=$2",[owner,id]);
 await db.exec('set role authenticated');const as=async id=>db.query("select set_config('request.jwt.claim.sub',$1,false)",[id]);const rpc=async(fn,op,data={})=>(await db.query(`select public.${fn}($1,$2::jsonb) r`,[op,JSON.stringify(data)])).rows[0].r;
 await as(a);const team=(await rpc('impulso','create_team',{name:'Equipe'})).id;await rpc('impulso','save_project',{name:'Demanda',link:'https://plataforma.gpinovacao.senai.br/plataforma/demandas-da-industria/interna/123'});const project=(await rpc('impulso','load')).projects[0].id;
 await as(b);const foreignTeam=(await rpc('impulso','create_team',{name:'Outro responsável'})).id;await as(c);const secondTeam=(await rpc('impulso','create_team',{name:'Equipe 2'})).id;
 const base={name:'Pesquisa',deadline:'2030-01-01',delivery_mode:'group',point_value:'5',project_id:project};
 await as(t);const id=(await rpc('impulso_learning','save_activity',{...base,delivery_destination_url:'https://drive.google.com/drive/folders/teste'})).id;
 let data=await rpc('impulso_learning','load');assert.equal(data.delivery_destination_supported,true);assert.equal(data.definitions.find(x=>x.id===id).delivery_destination_url,'https://drive.google.com/drive/folders/teste');
 await as(a);data=await rpc('impulso_learning','load');assert.equal(data.activities.find(x=>x.id===id&&x.team_id===team).delivery_destination_url,'https://drive.google.com/drive/folders/teste');
 await assert.rejects(()=>rpc('impulso_learning','save_activity',{...base,id,delivery_destination_url:'https://evil.test'}));await assert.rejects(()=>db.query("select public.impulso_learning_before_delivery_link('load','{}'::jsonb)"));
 await as(b);data=await rpc('impulso_learning','load');assert(!JSON.stringify(data).includes('drive.google.com/drive/folders/teste'));
 await as(other);await assert.rejects(()=>rpc('impulso_learning','save_activity',{...base,id,delivery_destination_url:'https://evil.test'}));
 await as(t);await assert.rejects(()=>rpc('impulso_learning','save_activity',{...base,id,name:'Não salvar',delivery_destination_url:'javascript:alert(1)'}));
 for(const value of ['http://example.test', 'https://evil.test\n.example', 'https://user@example.test', 'https://example.test/'+ 'a'.repeat(2048),null])await assert.rejects(()=>rpc('impulso_learning','save_activity',{...base,id,delivery_destination_url:value}));
 data=await rpc('impulso_learning','load');assert.equal(data.definitions.find(x=>x.id===id).name,'Pesquisa');assert.equal(data.definitions.find(x=>x.id===id).delivery_destination_url,'https://drive.google.com/drive/folders/teste');
 await rpc('impulso_learning','save_activity',{...base,id,name:'Pesquisa editada'});data=await rpc('impulso_learning','load');assert.equal(data.definitions.find(x=>x.id===id).delivery_destination_url,'https://drive.google.com/drive/folders/teste');
 await rpc('impulso_learning','save_activity',{...base,id,delivery_destination_url:''});data=await rpc('impulso_learning','load');assert.equal(data.definitions.find(x=>x.id===id).delivery_destination_url,'');
 // Different links for two groups and no leak of the other group's link.
 const global=(await rpc('impulso_learning','save_activity',{name:'Geral',deadline:'2030-01-01',delivery_mode:'group',point_value:'0',delivery_destination_mode:'group',delivery_group_links:{[team]:'https://drive.google.com/group-one',[secondTeam]:'https://drive.google.com/group-two'}})).id;
 let own=(await rpc('impulso_learning','load')).definitions.find(x=>x.id===global);assert.equal(own.delivery_group_links[team],'https://drive.google.com/group-one');assert.equal(own.delivery_group_links[secondTeam],'https://drive.google.com/group-two');
 await assert.rejects(()=>rpc('impulso_learning','save_activity',{name:'Geral',id:global,deadline:'2030-01-01',delivery_mode:'group',point_value:'0',delivery_destination_mode:'group',delivery_group_links:{[foreignTeam]:'https://evil.test'}}));
 await as(a);let asA=await rpc('impulso_learning','load');assert.equal(asA.activities.find(x=>x.id===global).delivery_destination_url,'https://drive.google.com/group-one');assert(!JSON.stringify(asA).includes('group-two'));assert(!JSON.stringify(asA).includes('delivery_group_links'));
 await as(c);let asC=await rpc('impulso_learning','load');assert.equal(asC.activities.find(x=>x.id===global).delivery_destination_url,'https://drive.google.com/group-two');assert(!JSON.stringify(asC).includes('group-one'));
 await as(t);await assert.rejects(()=>rpc('impulso_learning','save_activity',{...base,id,delivery_destination_mode:'group',delivery_group_links:{[secondTeam]:'https://wrong-team.test'}}));
 await db.exec('set role anon');await assert.rejects(()=>rpc('impulso_learning','load'));
 console.log('Link de destino: criação, edição, remoção, isolamento, validação e atualização única testados.');
} finally {await db.close()}
