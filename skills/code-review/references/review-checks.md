# Focused review checks

Use only the checks relevant to the changed behavior. Establish an execution path before reporting a defect. Do not request tests for every line or propose changes based on style alone.

## Behavior and regression

- Check conditions, boundaries, null handling, transformations, state transitions, defaults, error propagation, and unintended side effects.
- Compare changed interfaces, callers, serialization, configuration, integrations, and error contracts with previous behavior. Compilation alone does not establish compatibility.
- Look for incomplete implementation and tests that pass without exercising the changed behavior.

## Data and security

- For persisted or business-critical data, check transaction boundaries, partial updates, retries, idempotency, lost or duplicate writes, migrations, mapping, precision, ordering, and failure recovery. Treat realistic data loss or corruption as high priority.
- At external trust boundaries, check authentication, authorization and ownership, input validation, injection, path traversal, secret or sensitive-data exposure, deserialization, and privilege changes. Explain the attack or failure path; avoid speculative security claims.

## Concurrency and lifecycle

- Check shared mutable state, races, stale state, synchronization, ordering, retry behavior, idempotency, and distributed consistency where relevant.
- Check disposal and cancellation of connections, transactions, streams, sockets, async tasks, and background work. Note pool pressure, unbounded work, and resources held longer than necessary.

## Performance

- Identify the affected operation and plausible workload before calling a change slow. Inspect query counts and N+1 patterns, batching, pagination, large in-memory filtering or loading, repeated computation or serialization, blocking I/O, sequential independent I/O, algorithms on large inputs, allocation or copying of large objects, caching, lock duration, transaction duration, and unbounded concurrency or memory.
- For regressions, compare the changed path with prior behavior and state the resource cost and scale at which it matters. Prefer existing benchmarks, profiles, query plans, tests, or telemetry when practical; do not build elaborate benchmarks for speculative comments.
- Use `[Perf]` for visible, meaningful optimization opportunities on plausibly sensitive paths when the remedy is proportionate. Do not report trivial allocations, known-small complexity, unsupported caching proposals, or concurrency suggestions with doubtful benefit.

## Tests and validation

- Look for missing regression, boundary, failure, authorization, transaction, concurrency, or integration coverage only when it protects an important changed behavior. Verify whether existing tests already cover it.
- Run targeted existing checks when cheap and useful. Report what ran and any limits; do not infer correctness solely from a green result.
