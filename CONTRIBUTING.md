# Contributing

Read [development](docs/development.md) and [architecture](docs/architecture.md). Follow Rails’ normal directory structure and naming conventions.

Keep request handling in controllers, business rules in models, and display concerns in helpers and views. Preserve both application validation and database constraints when changing lending rules.

Run `make format`, `make check`, and `make e2e` for browser-visible changes. Keep migrations reversible where possible, update schema files, and add tests for meaningful behavior. Never commit local databases, generated assets, credentials, or mail files.

Use focused commits that describe the resulting behavior. Push each complete, verified chunk.
