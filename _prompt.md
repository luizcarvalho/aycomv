## Alteracoes

- tratar erro
```
ActiveRecord::RecordNotUnique in ClientsController#update
PG::UniqueViolation: ERROR: duplicate key value violates unique constraint "index_clients_on_email"
DETAIL: Key (email)=(aycom@aycomnet.com.br) already exists.
```

- Quando vídeo for gerado contador de frames do stream deve ser zerado
