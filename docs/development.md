# Development

## Tooling

Ruby 3.4.11 is pinned in `.ruby-version` and `mise.toml`; Rails and gems are locked in `Gemfile.lock`. SQLite and Tailwind use native gem packages where available. No JavaScript package manager is required.

If Ruby is missing, follow the [Rails installation guide](https://guides.rubyonrails.org/install_ruby_on_rails.html). With mise installed, run `mise trust` and `mise install` in this repository. On this development machine, Ruby and Rails were installed under the user account through mise.

## Common commands

| Command | Purpose |
| --- | --- |
| `make setup` | Install/check gems, build Tailwind, prepare the local database |
| `make dev` | Run Puma and the Tailwind watcher on port 3000 |
| `make check` | Run the same application checks as CI |
| `make test` | Run model and request tests |
| `make e2e` | Run Selenium/Capybara browser tests |
| `make format` | Apply Ruby and ERB formatters |
| `make build` | Precompile assets |
| `bin/rails console` | Explore models and records interactively |
| `bin/rails db:migrate` | Apply new migrations |

Prefix direct Ruby commands with `mise exec --` if Ruby is not activated in your shell. The Makefile does this automatically when mise is available.

You can change the development port with `PORT=3001 make dev`. Configure the password mailer URL separately if using a custom port. Do not run two app instances against the same development port.

## Persistence and migrations

Development uses `storage/development.sqlite3`; tests use `storage/test.sqlite3`. Keep database changes in new migrations and commit the generated `db/schema.rb`. Local database files, logs, generated assets, environment files, and credential keys are ignored by Git.

`make setup` is safe to repeat. It prepares the database without deleting existing records. `bin/setup --reset` deliberately resets development data; use it only when that is intended. There is no demo account or seeded default password.

## Password resets

In development, Action Mailer saves reset messages under `tmp/mails/`. Submit the reset form, then open the saved message locally and follow its reset link. No email is sent through an external service. Treat those files as private credentials; they are ignored and cleared with temporary files.

Production can deliver resets through SMTP, or retain messages in its private storage directory. See [deployment](deployment.md).

## Browser tests

Chrome/Chromium and its matching driver are managed by Selenium. `CHROME_BIN` can select a specific executable; the test setup applies it before Rails resolves the driver. Run:

```sh
CHROME_BIN=/path/to/chrome make e2e
```

The first run may download a browser or driver. Screenshots appear in `tmp/screenshots/`; CI uploads failure screenshots. Browser tests start their own temporary Puma listener and stop it on completion.

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `PORT` | `3000` | Development/Puma listener port |
| `APP_TIME_ZONE` | `UTC` | Calendar dates and overdue status |
| `APP_HOST` | `localhost` in production | Permitted host and reset-link hostname |
| `BACKSOON_STORAGE` | `storage` | Production SQLite and local mail storage directory |
| `SECRET_KEY_BASE` | Rails’ development secret; required for production without a master key | Session and token signing |
| `SOLID_QUEUE_IN_PUMA` | Unset | Enable the production background worker inside Puma |
| `CHROME_BIN` | Selenium discovery | Browser binary for system tests |

`.env.example` lists deployment settings. Rails does not automatically load `.env` files; supply variables through your shell, service manager, or container runtime.

## Contributing

Keep business rules in models, request handling in controllers, and presentation in helpers and ERB views. Use services only when a real operation outgrows those boundaries. Add regression tests for behavior, keep commits focused, and run `make check` plus `make e2e` before pushing changes to flows used in the browser.
