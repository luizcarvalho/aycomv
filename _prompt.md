# Implementações

1. Ao remover um stream remover a pasta de frames e os videos gerados (nível de model) (Criar alerta para usuário que essa ação é irreversível)

2.1. Múltiplos E-mails por Cliente
Descrição: Alteração no módulo de Cadastro e Edição de Clientes para permitir a inserção de mais de um endereço de e-mail para o recebimento das notificações de vídeos gerados.

Interface (Front-end): O campo de "E-mail" atual passará a aceitar uma lista de e-mails, com a instrução visual para o usuário de que os endereços devem ser separados por vírgula (ex: email1@aycom.com, email2@aycom.com).
Validação (Back-end): Implementação de uma nova regra de validação no formulário que fará a separação (split) da string pelas vírgulas, removendo espaços em branco, e validando o formato de cada e-mail individualmente antes de salvar no banco de dados.
Estratégia de Envio (Action Mailer): O processo de envio automático (após a geração do timelapse) será reestruturado. O sistema lerá a string, separará os e-mails e enviará a notificação para todos os destinatários válidos daquela lista. O envio será otimizado (utilizando cópia oculta - BCC, ou disparos individuais assíncronos via fila do SolidQueue) para garantir que a falha em um e-mail não bloqueie a entrega para os demais.

2.2. Horário de Gravação Restrito por Stream (Janela de Captura)
Descrição: Alteração no módulo de Gerenciamento de Câmeras (Streams) para permitir a definição de uma janela de horário específica em que as capturas de frames (snapshots) devem ocorrer.

Interface (Front-end): Inclusão de dois novos campos no formulário de Criação/Edição de Streams: "Horário de Início da Captura" e "Horário de Término da Captura" (ex: das 06:00 às 18:00).
Lógica de Captura (Inalterada): O processo de captura de frames (snapshots) continuará a funcionar ininterruptamente, capturando e guardando imagens 24 horas por dia.

Lógica de Compilação e Regra de Negócio: A restrição de horário será aplicada estritamente no processo de compilação do vídeo. Após a captura de todos os frames diários, e antes de acionar o FFmpeg para unir as imagens, o sistema filtrará os arquivos com base no horário embutido no próprio nome de cada frame — uma vez que os arquivos já são salvos no formato HHMMSS.jpg. O sistema lerá o nome de cada arquivo, extrairá o horário e selecionará apenas os frames cujo horário esteja dentro da janela definida (Início–Fim). Imagens fora deste intervalo serão ignoradas na geração do vídeo. Essa abordagem elimina qualquer cálculo por índice e garante precisão mesmo em dias com falhas de câmera ou capturas irregulares.
Esse intervalo poderá ser alterado a qualquer momento, o vídeo será gerado utilizando essas configurações no horário global definido pra compilação dos vídeos na virada do dia.
