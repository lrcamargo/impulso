# Atualização 0.1.0-alpha.5 — grupos e demandas

O pacote também inclui `BACKLOG.md`, com o que já foi feito e os próximos itens a planejar.

## O que muda

1. O aluno acessa **Meu grupo**, clica em **Criar grupo** e informa o nome.
2. Após salvar, pode pesquisar colegas cadastrados pelo nome ou pelo e-mail completo que já conhece, selecionar um ou mais colegas e clicar em **Enviar convites**. Os e-mails dos colegas não aparecem na tela. Também pode clicar em **Concluir depois** e voltar em **Convidar colegas**.
3. Cada colega encontra o convite ao entrar na plataforma e pode **Aceitar** ou **Recusar**. Somente após aceitar passa a participar e a ver a demanda do grupo.
4. Um integrante acessa **Adicionar demanda**, informa o **nome** e o **link** e salva. Não há campo de etapa. A professora acessa **Demandas** e complementa descrição, benefícios esperados, detalhamento, restrições, empresa, área de atuação e data de vigência.

O convite aparece dentro da plataforma; este fluxo não envia e-mail de convite. Um aluno vê somente seu próprio grupo e sua demanda, além dos convites recebidos. Uma pesquisa pode não encontrar alguém que já tem grupo ou convite pendente. Se algum convite não for enviado, os demais podem já ter sido enviados. Após uma falha de conexão, clique em **Concluir depois** e verifique os convites pendentes antes de tentar novamente.

## Antes de instalar

Faça backup dos dados e dos arquivos. Este pacote é **incremental e cumulativo**: foi preparado sobre o commit `98a1611` da alpha.2 e inclui também a edição de alunos da alpha.3 e o botão de mostrar senha da alpha.4. Confira se o repositório recebeu outras alterações depois dessa base e preserve-as, sem sobrescrevê-las. Não force o histórico.

O recurso de grupos e demandas já utiliza as funções do banco instaladas na versão inicial/alpha.2. **Ele não exige SQL novo nem nova Edge Function.** Não execute novamente `supabase/schema.sql`, pois seu banco já está em uso.

### Se a alpha.3 ainda não foi instalada

A edição de alunos incluída no pacote precisa da atualização de banco e da função de servidor da alpha.3. Siga `ATUALIZACAO_ALPHA3.md`: depois do backup, aplique uma vez `database-updates/202611130002_edit_students.sql` no projeto Supabase correto e publique a função `edit-student`, cuja URL deve terminar em `/edit-student`. Se não instalar esses componentes, o novo fluxo de grupos não depende deles, mas a edição de alunos não funcionará.

Se não souber se já instalou o SQL da alpha.3, execute esta consulta **somente de leitura** no SQL Editor:

```sql
select
  to_regprocedure('public.impulso_prepare_edit(uuid,text,text)') is not null as preparacao_instalada,
  to_regprocedure('public.impulso_finish_edit(uuid)') is not null as conclusao_instalada,
  to_regprocedure('public.impulso_cancel_edit(uuid)') is not null as cancelamento_instalado;
```

Se todas forem `true`, não execute novamente o SQL; confira também a função `edit-student`. Se todas forem `false`, siga o guia da alpha.3. Se forem mistas, pare e peça orientação.

## Atualizar os arquivos do site

Copie os arquivos do pacote para os mesmos caminhos do projeto, preservando `src/config.js` e demais arquivos existentes. O pacote não contém configuração, dados ou segredos. Não coloque senhas, chave `service_role` ou chave secreta no código do navegador. A atualização dos arquivos não altera automaticamente o Supabase nem publica a função de servidor.

## Teste antes de usar com alunos

Use contas de teste: crie um grupo, selecione dois colegas em pesquisas diferentes, envie convites e confira que ainda estão pendentes. Acesse um colega e aceite; acesse outro e recuse. Cadastre nome e link da demanda como integrante e confira que o professor consegue complementar os dados. Confirme que uma conta fora do grupo não vê grupo ou demanda. Verifique também edição de alunos e mostrar senha, se aplicáveis.

A compilação, os testes locais de banco e o navegador com respostas de rede simuladas passaram. Esta atualização **não foi aplicada nem testada no seu Supabase ou site reais**. Faça testes controlados e revisão de privacidade e segurança antes de usar dados de alunos.
