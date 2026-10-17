# Backsoon

**Remember what you lent, who has it, and when it’s coming back.**

Backsoon is a small lending tracker planned with Ruby on Rails. Keep track of books, chargers, tools, and other belongings you lend to people, without relying on your memory.

## Planned features

- Record an item, its borrower, the lending date, and the expected return date.
- Browse outstanding, overdue, and returned loans.
- Mark items returned and keep their lending history.
- Search by item or borrower.
- Sign in to manage your own items and loans.

## Planned stack

| Technology | Purpose |
| --- | --- |
| Ruby + Rails | Application logic, routing, models, and rendered pages |
| Hotwire | Interactive page updates and small browser interactions |
| Tailwind CSS | Styling and responsive layouts |
| SQLite | Persistent storage in a local database file |
| Minitest | Automated application tests |
| RuboCop + Brakeman | Ruby style checks and static security analysis |
| GitHub Actions | Continuous integration |

SQLite does not require an online database account, API key, or separate database server.

## Codebase approach

Follow standard Rails conventions: models, controllers, views, database migrations, and tests. Keep controllers focused, put business rules in the appropriate models, and enforce important invariants with database constraints. An item must not have two active loans at the same time.

Changes will use focused commits, with automated checks added as the application takes shape.

## Status

Initial repository setup. The Rails application has not been generated yet. Installation, development, and test commands will be documented alongside their implementation.
