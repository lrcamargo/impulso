# Atualização alpha.12 — alunos, convites e medalhas

## Pré-requisitos e segurança

Preparada sobre o repositório alpha.11 `910246a`. Você confirmou a instalação da alpha.11 e do SQL alpha.10. Faça backup do projeto e do banco; preserve alterações locais e `src/config.js`. Interrompa o uso durante a atualização. Não reexecute o schema inicial nem SQL antigo. Esta atualização requer dois SQLs novos, na ordem abaixo.

## Pré-checagem no SQL Editor

Execute esta consulta somente de leitura:

```sql
select
  to_regprocedure('public.impulso_learning_v9(text,jsonb)') is not null as pontos_alpha10,
  to_regprocedure('public.impulso_group_admin(text,jsonb)') is not null as grupos_alpha12,
  to_regprocedure('public.impulso_learning_v10(text,jsonb)') is not null as imagens_alpha12,
  exists(select 1 from information_schema.columns where table_schema='impulso_private' and table_name='invites' and column_name='reminded_at') as coluna_lembrete,
  exists(select 1 from information_schema.columns where table_schema='impulso_private' and table_name='learning_badges' and column_name='image_path') as coluna_imagem,
  exists(select 1 from storage.buckets where id='impulso-medalhas') as bucket_existente;
```

Antes da primeira instalação, espere **true, false, false, false, false, false**. Se houver outra combinação ou erro, pare e peça orientação, especialmente se o bucket já existir. Não reaplique versões anteriores.

Confira se já há alguma equipe acima do limite. A migração não remove integrantes existentes, mas bloqueia novas entradas acima de cinco:

```sql
select t.name, count(m.student_id) as integrantes
from impulso_private.teams t join impulso_private.members m on m.team_id=t.id
group by t.id, t.name having count(m.student_id)>5;
```

Confira também políticas preexistentes no Storage, que podem conceder acesso mais amplo por se somarem às novas políticas:

```sql
select policyname, roles, cmd, qual, with_check
from pg_policies where schemaname='storage' and tablename='objects';
```

Se aparecerem políticas existentes e você não tiver certeza de que elas não permitem acesso indevido ao novo bucket, pare e peça revisão antes de aplicar o SQL de imagens. Não compartilhe credenciais.

## Instalação

1. Com os resultados conferidos e backup feito, execute uma vez `database-updates/202611130008_group_admin.sql`.
2. Em seguida, execute uma vez `database-updates/202611130009_badge_images.sql`. O segundo SQL cria o bucket público `impulso-medalhas` e suas regras de upload, com tamanho por arquivo de até 2 MiB. Ele não coloca imagens no banco. O limite global do seu projeto Storage também precisa permitir esse tamanho.
3. Se qualquer SQL der erro, **pare** e guarde a mensagem. O primeiro pode já ter sido aplicado; não repita ambos às cegas. Consulte a pré-checagem e peça orientação.
4. Copie os arquivos do pacote aos mesmos caminhos, preservando configuração e trabalho local. Recompile e atualize o site pelo procedimento habitual. Confira `0.1.0-alpha.12` na barra lateral.

## O que mudou

- Filtros de demanda em botões arredondados; contagem das equipes simplificada e autoria centralizada.
- O responsável pesquisa alunos por nome, e-mail ou equipe, pesquisa equipes por nome ou integrante, filtra alunos sem grupo e pode alocá-los diretamente. A lista indica convites pendentes quando os dados estão disponíveis. Convites pendentes desse aluno são cancelados; o servidor impede mais de cinco integrantes. A entrada reflete as regras atuais de pontos, atividades e medalhas da equipe.
- Convites pendentes de equipe podem receber um **lembrete dentro da plataforma**, sem duplicação ou e-mail. O aluno ainda precisa aceitar ou recusar. Lembrete de acesso pode ser copiado e enviado manualmente; não contém senha nem é enviado automaticamente.
- As quatro medalhas fixas aparecem na tela de medalhas, com seus nomes e critérios; suas regras e artes não são editáveis nesta versão. Medalhas criadas podem ser listadas, editadas e atribuídas, com ícone ou imagem PNG, JPEG ou WebP. A exclusão de medalhas ainda não foi implementada.
- Imagens de medalhas são **públicas**, acessíveis a quem tiver o link. Não use fotos de alunos, documentos ou informações pessoais. O upload é limitado aos responsáveis autorizados; revise as políticas existentes do Storage. Substituir imagem não apaga a anterior automaticamente; falhas podem deixar arquivos sem uso, que exigem revisão antes de limpeza.

## Teste controlado

Use contas e imagens de teste. Confira os botões e filtros, as quatro medalhas de marco, e crie/edite uma medalha primeiro com ícone, depois com imagem. Atribua-a e confira no perfil do aluno. Verifique limite de tamanho/tipo e que alunos ou outro responsável não conseguem enviar ou alterar imagens pela API. Confirme que a imagem é pública pelo link e não contém dados pessoais.

Na lista de alunos, pesquise por nome, e-mail e equipe; na tela de equipes, pesquise equipe e integrante. Filtre alunos sem grupo, confira convites pendentes e aloque um aluno; confira cancelamento de convites anteriores e o efeito nos pontos. Teste tentativas de exceder cinco integrantes, inclusive aceite de convite após o grupo ficar cheio. Reenvie um lembrete de grupo e confira a marcação na conta do convidado; verifique que não é e-mail. Teste copiar o lembrete de acesso.

Os testes foram locais, com banco simulado e rede de navegador simulada; Storage, políticas, concorrência e site reais ainda precisam de validação. Arquivamento seguro de equipes e demandas **não foi implementado**. A exclusão dos usuários de teste e o envio de entregas ao Drive continuam pendentes.

A revisão das issues reais e a lista de verificações para encerramento estão em `ISSUES_GITHUB_ALPHA12.md`.
