# NaiveDice

### Key points
- To model the life cycle of a purchase I've decided to use the Erlang behaviour `gen_statem`. It offers a simple way of representing state transitions. Each state machine is a process that runs concurrently but also backed by the DB, achieving an auditable log of transactions. We could further improve this allowing orders to recover from failed states. This log is also nice for BI
- `tickets` is now a table just for storing data about the ticket itself and not the purchase
- `EventBooker` is the orchestrator. It holds the **current** number of tickets available, creates orders and monitors them; but interaction and transitions happen within the orders. It could be possible to refine this architecture to support high load with more than one `EventBooker` and sharding events.
- Separation of concerns: web layer access domain layer through a well defined API. For that reason I've avoided exposing internal structures to the web part
- I didn't intend to cover all possible cases of a payment (refunds, payment rejected, idempotency, ...). Focus was more on solving the challenge of correct ticket allocation
- Some table indexes are not in place just because sample data is very small. Obviously, very common and important queries must be optimized on a real scenario

There's an instance of this app running on [Gigalixir](https://naive-dice.gigalixirapp.com/)
