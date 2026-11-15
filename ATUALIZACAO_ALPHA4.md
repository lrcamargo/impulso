# Atualização 0.1.0-alpha.4 — mostrar e ocultar senhas

Esta atualização inclui um botão **Mostrar/Ocultar** nos campos de senha do login, cadastro pelo professor, primeiro acesso e alteração ou recuperação de senha. Cada campo começa oculto. O botão só muda a visualização local e não envia o formulário nem altera o armazenamento da senha. Cuidado ao mostrar a senha perto de outras pessoas ou durante compartilhamento de tela.

## Antes de instalar
O pacote é incremental e foi preparado a partir do commit `98a1611` da versão alpha.2, acrescentando as mudanças das versões alpha.3 (edição de alunos) e alpha.4 (mostrar senha). Verifique se o repositório mudou desde então; não sobrescreva modificações posteriores.

O botão de mostrar senha não requer nenhuma alteração no Supabase. **A edição de alunos da alpha.3, que também está neste pacote, requer uma atualização de banco e uma função de servidor.**

## Se a alpha.3 ainda não foi instalada
Siga `ATUALIZACAO_ALPHA3.md`: faça backup, aplique uma única vez o SQL `database-updates/202611130002_edit_students.sql` no banco já existente, publique a Edge Function `edit-student` com URL terminando exatamente em `/edit-student`, e depois atualize os arquivos do site.

## Se você não sabe se o banco da alpha.3 já foi atualizado
No SQL Editor do projeto correto, execute esta consulta somente de leitura:

```sql
select
  to_regprocedure('public.impulso_prepare_edit(uuid,text,text)') is not null as preparacao_instalada,
  to_regprocedure('public.impulso_finish_edit(uuid)') is not null as conclusao_instalada,
  to_regprocedure('public.impulso_cancel_edit(uuid)') is not null as cancelamento_instalado;
```

- Se todas forem `true`, não execute novamente o SQL da alpha.3. Verifique também se a função `edit-student` está publicada com a URL correta.
- Se todas forem `false`, consulte `ATUALIZACAO_ALPHA3.md` antes de instalar. Se houver valores mistos ou dúvidas, pare e peça orientação.

## Atualizar o site
Copie somente os arquivos do pacote para os mesmos caminhos do repositório. Preserve `src/config.js`, `.lovable/` e outros arquivos já existentes. Não use force push nem reescreva o histórico. O commit pode ser `feat: mostrar senha durante a digitação`. A versão informada é `0.1.0-alpha.4`; nenhuma tag foi criada automaticamente.

Depois de publicar, teste com contas de teste: digite uma senha e use Mostrar e Ocultar no login; repita no cadastro de um aluno e na troca da senha inicial. Confirme que os campos de confirmação podem ser alternados independentemente. Teste também edição de nome e e-mail se instalou a alpha.3.

A compilação, os testes de banco locais e o fluxo de interface simulado foram verificados. A atualização não foi aplicada ou testada no seu Supabase real nem na hospedagem. Faça backup e revisão de segurança antes de trabalhar com dados reais.
