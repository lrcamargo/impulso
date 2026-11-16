# Plano — envio de arquivos ao Google Drive

**Status: não implementado na alpha.8.** A conexão de Google Drive ativada nesta conversa permite operações do assistente durante a conversa; ela não fornece automaticamente autorização permanente ao site dos alunos. Nenhum arquivo foi enviado ou pasta alterada.

## Decisões da professora

- Uma **pasta por atividade**: todos os grupos enviam os arquivos daquela atividade para a pasta escolhida pela professora.
- Nome padronizado **grupo + atividade + data/hora**, mantendo a extensão. Acrescentar identificador curto gerado pelo sistema para evitar colisão em envios simultâneos. Exemplo ilustrativo: `Equipe-A_Pesquisa_2027-03-15_143012_a1b2c3.pdf`.
- Os arquivos e fotos ficam no Google Drive, não dentro do banco de dados. O banco pode guardar apenas metadados mínimos da entrega, como identificador do arquivo, nome, grupo, atividade, autor, tamanho, situação e data, necessários para acompanhamento.

## Arquitetura proposta — precisa ser configurada e validada

1. A professora conecta a conta Google à aplicação por uma autorização própria e controlada; uma alternativa é uma conta de serviço apenas se existir um Drive compartilhado institucional compatível. A opção apropriada depende do tipo de conta e das políticas da instituição. Não enviar senhas, chaves ou tokens na conversa, no GitHub ou no navegador.
2. A professora vincula uma pasta autorizada a cada atividade. O servidor valida que a pasta existe e está autorizada. O aluno não escolhe um destino arbitrário.
3. O servidor verifica login, grupo, atividade, prazo e permissões; impõe tipos e tamanho permitidos; renomeia o arquivo; faz upload diretamente ao Drive ou inicia uma sessão de upload restrita e registra o resultado. Não confiar em nome, grupo ou destino enviados pelo navegador.
4. Restringir leitura e listagem: como a pasta é compartilhada por todos os grupos, conceder acesso direto à pasta aos alunos pode expor trabalhos de outros grupos. Avaliar acesso mediado pelo servidor ou permissões restritas por arquivo. A professora precisa conseguir acessar os arquivos.
5. Definir validação de tipo e conteúdo, segurança contra arquivos maliciosos, políticas de retenção/exclusão, tratamento de quotas e upload interrompido, idempotência e reconciliação quando o upload termina mas o registro falha. Revisar privacidade/LGPD e configurações institucionais.
6. Testar com uma pasta de teste e dados fictícios, inclusive grupo A tentando acessar arquivos do grupo B. Não abrir pastas ao público para contornar problemas de permissão.

Contas de serviço não têm cota própria para ser proprietárias de arquivos: Google orienta usar Drive compartilhado ou autorização OAuth 2.0 em nome de uma pessoa. Fonte: https://developers.google.com/workspace/drive/api/guides/about-shareddrives . O acesso e as permissões variam conforme a conta e a instituição.

## Decisões ainda necessárias antes da integração

- Conta Google pessoal ou institucional e disponibilidade de Drive compartilhado.
- Tipos e tamanhos máximos, quantidade de arquivos por entrega e política de versões.
- Se alunos poderão visualizar/baixar suas próprias entregas no Impulso e quem pode excluir/substituir arquivos.
- Como a professora escolherá a pasta e como a autorização será administrada/revogada com segurança.

A alpha.8 continua aceitando links de entrega; não possui botão de upload e não afirma integração ativa.
