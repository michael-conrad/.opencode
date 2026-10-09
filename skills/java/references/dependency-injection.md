<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557; DI landscape currency-verified 2026-10-07 -->

# Java DI practice — wiring patterns

Companion detail to the `java` card. The mandate and tier table live in the
shared card under `programming-principles`; this card is the Java wiring
practice.

## Constructor injection (the default)

Every service declares its collaborators as final constructor parameters; the
container supplies them at construction.

```java
public final class OrderService {
    private final PaymentGateway payments;
    private final OrderRepository orders;

    public OrderService(PaymentGateway payments, OrderRepository orders) {
        this.payments = payments;
        this.orders = orders;
    }
}
```

- Final fields, no setters for required collaborators — the graph is immutable
  and fully visible in the signature.
- Unit tests construct the service directly with fakes — no container needed
  in tests unless testing the wiring itself.

## Spring

- Stereotype annotations mark roles (`@Service`, `@Repository`, `@Controller`);
  a single constructor is injected without annotation noise.
- `@Configuration` + `@Bean` methods for third-party types the code does not
  own; profiles for environment-specific wiring.
- Component scanning is the default discovery; keep scanning scopes narrow.

## Dagger 2

- `@Component` interfaces declare the entry points; `@Module` + `@Provides`
  (or `@Binds`) supply implementations; the graph is validated at compile time.
- Choose when reflection-free startup or build-time graph verification matters
  (CLI tools, Android via Hilt).

## Guice

- `AbstractModule` subclasses `bind()` the graph in `configure()`; runtime
  resolution. Choose when wiring-only weight is right and startup reflection is
  acceptable.

## Choosing

Driven by code analysis and the requirements — never a fixed pin. Spring when
the project is already in the Spring ecosystem; Dagger 2 when compile-time
verification or Android; Guice for lightweight runtime wiring. The shared
card's selection guidance governs; combinations are allowed where the table
documents multiple idiomatic options.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
