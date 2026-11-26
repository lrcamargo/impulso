# Atualização pontual — links de entrega e mural

**Versão:** `0.1.0-alpha.13`, preparada a partir da alpha.12 revisada. Esta versão traz os links manuais e os canais do mural. O envio automático ao Google Drive foi adiado; tema, novidades e arquivamento permanecem para atualização futura e não estão incluídos aqui.

## O que muda

**Local de entrega.** Ao criar ou editar uma atividade, a professora escolhe entre um link para toda a turma ou um link por grupo. Na segunda opção, uma lista mostra cada grupo e seu campo de link; cada aluno vê somente o link do próprio grupo no Impulso. Para uma atividade vinculada a uma demanda específica, aparece apenas o grupo correspondente. Ao criar um grupo novo, edite a atividade para acrescentar o link dele.

Os links são opcionais e devem começar com `https://`. A professora cria as pastas no Google Drive. O Impulso não faz upload de arquivos, não impõe limite de tamanho e **não controla as permissões do Google**: configure os acessos de cada pasta para que os alunos possam entregar e para evitar acesso indevido entre grupos. Compartilhar o mesmo link pode permitir que quem o receba veja os arquivos da pasta, conforme as permissões definidas no Drive.

**Mural.** Na criação da mensagem, pode-se escolher todos os grupos, o próprio grupo com o professor, ou uma conversa individual entre um aluno e o professor. O professor pode escolher o aluno e responder a mensagens individuais. O histórico antigo é preservado; as mensagens privadas novas ficam separadas das antigas para evitar exposição a outros alunos. O canal de turma é visível a todos os alunos daquele professor, mesmo que ainda não tenham grupo.

## Antes de instalar

- Confirme que a versão é a alpha.12 revisada, com SQLs 008 e 009 já instalados. **Não execute novamente** o esquema inicial, 008 ou 009.
- A cópia do banco foi baixada, mas sua restauração não foi testada. Ela não inclui arquivos do Storage; o bucket existente foi informado como vazio. Se houve alterações desde a cópia, obtenha uma nova antes de instalar.
- Interrompa o uso durante a instalação e o teste. O SQL modifica funções do banco; apesar dos testes locais e da transação única, mudanças em produção têm risco.
- SQL 010 não é necessário nem está incluído nesta atualização. Nenhuma função Edge ou configuração OAuth é necessária.

## Passos depois de aprovação explícita

1. Substitua apenas `src/main.js` pelo arquivo do pacote no mesmo projeto da alpha.12. Preserve `src/config.js`, secrets e demais arquivos. Antes da atualização do banco, os novos controles ficam desabilitados para evitar que uma mensagem destinada ao professor seja publicada no canal errado.
2. No projeto Supabase correto, abra SQL Editor e execute **uma única vez**, inteiro, `database-updates/202611130011_alpha13_links_e_mural.sql`. Ele usa uma transação e verifica as funções da alpha.12 revisada. Se houver erro, não repita: peça orientação e compartilhe somente a mensagem de erro, sem senhas ou dados pessoais.
3. Publique o site pelo processo que já utiliza e atualize a página. Nenhum usuário, tabela, projeto ou arquivo de configuração deve ser excluído.
4. Com contas de teste, crie uma atividade para a turma e outra com links diferentes para dois grupos. Verifique que cada grupo recebe apenas seu link no Impulso e que as permissões das pastas no Drive estão corretas. Para grupo recém-criado, confira o campo ao editar a atividade.
5. Teste os três canais do mural. Confirme que todos veem a mensagem para a turma, apenas o grupo e o professor veem a mensagem do grupo, e somente o professor e o aluno escolhido veem a conversa individual. Use dados fictícios no teste.
6. Retome o uso após os testes. Se algo falhar, interrompa a utilização e peça ajuda antes de tentar uma restauração ou reaplicar SQL.

## Compatibilidade futura

A candidata experimental anterior de Drive e arquivamento foi preparada sobre uma base sem estes dois recursos. **Não execute a candidata antiga sobre esta atualização.** Tema, novidades, arquivamento e demais itens pedidos continuam pendentes e precisarão ser adaptados e testados com os novos links e o mural. A integração automática do Drive fica para uma etapa futura.
