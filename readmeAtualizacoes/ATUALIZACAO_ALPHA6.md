# Atualização alpha.6 — medalha de primeiro acesso

## O que muda

O aluno que concluir a troca obrigatória da senha inicial recebe a medalha **Primeiro Acesso**, exibida na sua visão geral. A medalha é individual e não acrescenta pontos. A troca da senha e o registro da conquista são confirmados juntos no banco.

A alpha.6 também inclui as melhorias da alpha.5 para grupos e demandas. Os arquivos `BACKLOG.md`, `TEXTOS_ISSUES.md` e `MENSAGEM_CLASSROOM.md` estão no pacote para consulta e uso pelo professor.

## Limitação da retroatividade

A versão anterior não guardava o histórico da troca de senha: ela apagava o registro pendente ao concluir. Por isso, **a ausência da pendência, sozinha, não prova que alguém trocou a senha**. Ao instalar esta versão, a medalha é concedida automaticamente aos alunos anteriores para os quais há indícios recuperáveis: solicitação aprovada para a mesmo professor e e-mail antes do cadastro, conta vinculada e confirmada e nenhuma troca pendente. Isso é uma inferência, não uma data de conquista histórica.

Alunos cadastrados diretamente, alunos antigos e alguns que mudaram o e-mail podem não ser identificáveis automaticamente, mesmo se já tiverem trocado a senha. Eles não recebem automaticamente uma medalha não comprovada; o professor poderá conferir os casos e, se necessário, pedir orientação para registrá-los manualmente. Todos que concluírem a troca obrigatória após instalar a alpha.6 recebem a medalha automaticamente. O registro não expõe dados de outros alunos.

### Conferir um caso anterior manualmente

Depois de instalar a alpha.6, caso um aluno antigo informe que já trocou a senha e não receba a medalha, confirme essa informação com ele por um canal seguro. A base anterior não consegue comprová-la sozinha. Só então você pode registrar a medalha para **um aluno de cada vez** no SQL Editor. Primeiro, substitua `EMAIL_EXATO_DO_ALUNO` pelo e-mail de login, conservando as aspas, e confira nome e situação retornados:

```sql
select s.name, s.email, s.user_id is not null as conta_vinculada,
       u.email_confirmed_at is not null as email_confirmado,
       exists(select 1 from impulso_private.first_passwords f where f.student_id=s.id) as troca_pendente,
       exists(select 1 from impulso_private.first_access_medals m where m.student_id=s.id) as medalha_registrada
from impulso_private.students s left join auth.users u on u.id=s.user_id
where s.email=lower(trim('EMAIL_EXATO_DO_ALUNO'));
```

Se não retornar exatamente o aluno correto, se a conta não estiver vinculada/confirmada ou se a troca estiver pendente, não continue. Se a troca anterior foi confirmada, substitua o mesmo e-mail neste comando para registrar a medalha:

```sql
insert into impulso_private.first_access_medals(student_id,source)
select s.id,'teacher_verified' from impulso_private.students s
join auth.users u on u.id=s.user_id
where s.email=lower(trim('EMAIL_EXATO_DO_ALUNO'))
  and lower(u.email)=s.email and u.email_confirmed_at is not null
  and not exists(select 1 from impulso_private.first_passwords f where f.student_id=s.id)
on conflict(student_id) do nothing
returning student_id;
```

Se não inserir uma linha, pode ser que já exista a medalha ou que as condições não tenham sido atendidas; confira antes de tentar novamente. O aluno pode precisar recarregar a página. Nunca peça ao aluno a senha pessoal para fazer essa conferência.

## Antes de instalar

Faça backup dos dados e arquivos. O pacote é incremental sobre o commit `06888a4` do repositório, que contém os arquivos da alpha.5; antes de copiar, confirme se o repositório recebeu mudanças posteriores e preserve-as. Não sobrescreva alterações novas nem reescreva o histórico.

A alpha.2 precisa estar instalada no banco, inclusive as funções de senha inicial. A alpha.3 é necessária apenas para a edição de alunos: se ainda não aplicou seu SQL e não publicou `edit-student`, consulte `ATUALIZACAO_ALPHA3.md`. Verifique também se `create-student` continua publicada. Não aplique novamente SQL já instalado e **não execute `supabase/schema.sql` no banco em uso**.

## Instalar a medalha no Supabase

1. No projeto correto, abra o SQL Editor e execute esta consulta de verificação, que apenas lê as funções:

```sql
select
  to_regprocedure('public.impulso_finish_password(text)') is not null as troca_atual,
  to_regprocedure('public.impulso_finish_password_alpha2(text)') is not null as troca_renomeada,
  to_regprocedure('public.impulso_first_access_medal()') is not null as medalha_instalada;
```

2. Se o resultado for `true, false, false`, aplique **uma única vez**, após o backup, o arquivo `database-updates/202611130003_first_access_medal.sql` no SQL Editor. Ele não apaga alunos ou grupos. Se for `true, true, true`, a atualização parece já instalada: não a reaplique. Para qualquer combinação diferente, pare e peça orientação.
3. Confira se a consulta passou a retornar `true, true, true`.
4. Copie os arquivos do pacote para os mesmos caminhos do projeto, sem substituir `src/config.js` nem configurações próprias. Nunca coloque senha, `service_role` ou chave secreta no código do navegador. O SQL precisa ser aplicado no Supabase: o envio dos arquivos não o executa automaticamente.

## Verificar antes de divulgar

- Com um aluno de teste recém-cadastrado, entre com a senha inicial e confirme que a medalha só aparece depois de criar e confirmar uma nova senha pessoal.
- Recarregue a página e acesse novamente: a conquista deve continuar visível. O professor não recebe essa medalha.
- Teste um aluno antigo e observe a limitação da retroatividade acima. Confira que outro aluno não consegue consultar a conquista de terceiros.
- Teste criação de grupo, convites, aceite/recusa e cadastro/complementação de demanda. Se aplicável, teste também edição de aluno.
- O arquivo `MENSAGEM_CLASSROOM.md` é um rascunho para usar **depois** de instalar e testar; preencha o link real e as orientações antes de publicar.

Os testes de banco e navegador foram locais (navegador com rede simulada). Esta atualização não foi aplicada nem testada no Supabase ou site reais. Revise segurança, privacidade e o processo de backup antes do uso com alunos.
