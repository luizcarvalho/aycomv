- Adicionar modulo Eventos (campos: modulo, rotulo, valor, metadata)
aplicar em todas ações relevantes do projeto

- Notificação enviada
- Qualquer erro no processamento
- Logs de warnings e errors
- frames utilizados na criação do video
- Thumb atualizada

Exemplo:

```ruby
Event.create!(modulo: "video", rotulo: "video_created", valor: video.id, metadata: { title: video.title, frames: 10 })
```