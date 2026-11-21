# Atualização alpha.11 — interface e organização

## Pré-requisitos e instalação

Esta atualização é **incremental**, preparada sobre a alpha.10 do repositório, commit `24d58cf`. Você confirmou que instalou os arquivos e o SQL da alpha.10. Faça backup dos arquivos e do banco; preserve alterações posteriores ou locais, especialmente `src/config.js`. Copie os arquivos deste ZIP aos mesmos caminhos do projeto. Não apague arquivos que não vierem neste pacote.

**Nenhum SQL é necessário para a alpha.11.** Não execute novamente SQLs anteriores. Recompile e atualize o site pelos procedimentos que você já utiliza. Confirme na barra lateral a versão `0.1.0-alpha.11` e a autoria.

## O que está incluído

- Filtro de demandas: aprovação e dados complementados são dimensões diferentes. Uma demanda pode estar nos dois filtros.
- Equipes: vermelho abaixo de 3 integrantes, amarelo para 3 ou 4 e verde para 5; o número acompanha a cor.
- Cards organizados por atividade, com status de entrega de grupos e alunos em cor e texto.
- `orientacoes/TEXTOS_ISSUES.md` acumula sugestões de versões anteriores e itens novos. Há itens complementares sobre assuntos semelhantes: consulte as referências e evite abrir duplicados. São sugestões, não verificamos nem alteramos as issues do GitHub.
- Documentos usam linguagem genérica. Textos históricos são registros de versões e devem ser lidos junto aos status atuais.

## Testes após instalação

1. Com uma conta responsável e demandas em situações diferentes, confira todos os filtros. Uma demanda com dados complementados pode estar aprovada, reprovada ou pendente.
2. Confira equipes com 1 ou 2, 3 ou 4 e 5 integrantes; somente membros efetivos contam, não convites pendentes.
3. Confira cards com entregas e pendências por atividade e por aluno, links, observações e tela pequena. Cores são acompanhadas de texto.
4. Confira versão e autoria na barra lateral e valide que alunos não veem dados de outros grupos.

Esses testes ainda não foram realizados no site real. **Não estão incluídos:** arquivamento de grupo/demanda, reenvio de convites e upload de imagens para medalhas. Não há exclusão de usuários, nem upload de entregas ao Drive nesta versão.

## Aviso do VS Code: `vite/client`

Na pasta do projeto, com Node.js e npm instalados, execute `npm ci`, que instala exatamente as dependências do `package-lock.json`, inclusive as de desenvolvimento. Esse comando recria `node_modules`. Depois execute `npm run build` e, no VS Code, use a paleta de comandos para executar “TypeScript: Restart TS Server” ou recarregue a janela. Confirme que abriu a pasta que contém `package.json`. Se `npm ci` falhar ou o aviso persistir, envie a mensagem completa, sem credenciais. Não coloque senhas ou chaves secretas no projeto.
