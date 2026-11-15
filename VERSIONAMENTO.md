# Versionamento do Impulso

## Versão inicial

A versão deste pacote é **0.1.0-alpha.5**. É uma versão preliminar: o banco real, o e-mail e a hospedagem ainda precisam ser configurados e validados. A versão oficial fica em `package.json` e `package-lock.json`; `CHANGELOG.md` descreve o que mudou. Não confunda a versão com o endereço do site ou com o histórico de commits do Git.

A tag correspondente, quando você decidir registrar esse ponto, é `v0.1.0-alpha.5`. A tag ainda não foi criada no GitHub por este pacote.

## Fluxo recomendado

1. Envie o pacote inicial ao repositório e registre o primeiro commit, por exemplo `chore: iniciar Impulso v0.1.0-alpha.1`.
2. Antes de mudar o código, crie uma branch para cada alteração, por exemplo `feat/editar-alunos` ou `fix/convite`.
3. Faça commits pequenos e descritivos, como `feat: permitir edição de alunos` ou `fix: corrigir aceite de convite`.
4. Teste a alteração, revise e faça merge na branch principal `main`. Se o Lovable estiver sincronizado com `main`, lembre-se de que a sincronização do código e a publicação do site são etapas distintas; verifique e publique conforme o fluxo do seu projeto.
5. Para disponibilizar uma versão, atualize versão em `package.json` e `package-lock.json`, registre as mudanças em `CHANGELOG.md`, execute os testes e crie uma tag Git `vX.Y.Z` apontando para o commit dessa versão.

Se for usar terminal, depois de salvar as alterações e estar na branch correta, o comando `npm version 0.1.0-alpha.2 --no-git-tag-version` atualiza os dois arquivos de versão sem criar uma tag automaticamente. Confirme o diff e atualize o changelog antes do commit e da tag. Uma tag só deve ser criada após o commit da versão e os testes correspondentes.

## Padrão de numeração

- Enquanto a solução estiver sendo preparada e testada, incremente o pré-lançamento: `0.1.0-alpha.1`, `0.1.0-alpha.2`, etc. Use `beta` quando houver uma versão mais estável para teste controlado.
- `0.1.0` pode representar a primeira versão inicial validada; `0.1.1` uma correção compatível e `0.2.0` uma funcionalidade nova. Em versões `0.x`, a API ainda pode mudar; sempre descreva incompatibilidades no changelog.
- Reserve `1.0.0` para a primeira versão estável que passe pelos critérios de segurança, operação, autenticação e implantação definidos para o projeto. A numeração por si só não é garantia de segurança.

## Banco de dados e segredos

- Guarde `supabase/schema.sql` como referência do estado inicial. Depois que um banco real for instalado, **não reexecute o arquivo completo para atualizar tabelas existentes**. Novas mudanças de estrutura precisam de scripts de migração adicionais, versionados em ordem, revisados e testados antes da aplicação no banco real, com backup e procedimento de recuperação.
- Git guarda código e scripts, não os dados do banco. Organize backups separadamente.
- Não envie `service_role`, secret key, senhas, credenciais SMTP ou dados de alunos para o GitHub. `src/config.js` pode conter somente a URL e a chave publicável/anon do Supabase, pois esses valores são expostos no navegador. Proteções reais devem estar no banco e no servidor.
- Nunca coloque arquivos `.env` com segredos no repositório. O `.gitignore` fornecido exclui arquivos `.env` locais; configure a URL e a chave publicável em `src/config.js` conforme o guia.

## Antes de uma tag

- `npm ci`, `npm test` e `npm run build`, com as variáveis públicas configuradas.
- Verificar login e confirmação de e-mail, acesso de professores e alunos, aceite/recusa, isolamento entre equipes e acesso direto à API no Supabase real.
- Revisar segurança e privacidade, inclusive LGPD, antes de usar dados reais.
- Confirmar que `CHANGELOG.md`, `package.json` e `package-lock.json` descrevem a mesma versão.
