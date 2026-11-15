# Plano: novidades para alunos ao acessar

**Status:** planejamento; ainda não implementado.

## Experiência proposta

1. Após o login e a troca obrigatória de senha, mostrar uma janela curta de **Novidades do Impulso** apenas quando houver uma novidade publicada que o aluno ainda não viu.
2. Apresentar título, resumo simples e botão **Entendi**. Evitar mostrar dados privados ou prometer funções ainda não publicadas.
3. Registrar individualmente a versão ou identificação da novidade que o aluno marcou como lida. Se ele fechar sem confirmar, perguntar novamente no próximo acesso.
4. Manter uma página **Novidades** acessível depois, com o histórico das notas publicadas.
5. Se houver mais de uma novidade não lida, mostrar a mais recente e oferecer acesso à lista completa, evitando uma sequência longa de janelas.

## Publicação e segurança

- Inicialmente, as notas podem acompanhar as versões do código, com identificadores fixos e conteúdo revisado pela professora. No futuro, pode existir uma tela administrativa para publicar e retirar avisos.
- O registro de leitura deve ser salvo no banco por usuário autenticado, sem depender somente do navegador. Cada aluno só pode consultar/alterar seu próprio registro; a professora decide se precisa de algum relatório agregado.
- Não mostrar avisos antes da troca obrigatória de senha. Tratar falha de rede sem bloquear o uso da plataforma e sem marcar como lido automaticamente.
- Evitar coleta de informações desnecessárias; registrar apenas identificador da novidade, usuário e momento da confirmação, se esse horário for útil.

## Antes de implementar

Confirmar se o aviso será para todos os usuários ou apenas alunos, se as notas serão escritas pela professora no sistema e se ela precisa saber quem leu. Implementar testes de primeiro acesso, múltiplos dispositivos, privacidade e falhas de rede.
