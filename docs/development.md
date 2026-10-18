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

You can change the development port with `PORT=3001 make dev`. Password-reset links use the same port. Do not run two app instances against the same development port.

## Persistence and migrations

Development uses `storage/development.sqlite3`; tests use `storage/test.sqlite3`. Keep database changes in new migrations and commit the generated `db/schema.rb`. Local database files, logs, generated assets, environment files, and credential keys are ignored by Git.

`make setup` is safe to repeat. It prepares the database without deleting existing records. `bin/setup --reset` deliberately resets development data; use it only when that is intended. There is no demo account or seeded default password.

## Password resets

By default, Action Mailer saves development reset messages under `tmp/mails/`. Submit the reset form, then open the saved message locally and follow its reset link. Treat those files as private credentials; they are ignored and cleared with temporary files.

To send real password-reset emails locally, create a private `.env` file in the repository root:

```dotenv
SMTP_ADDRESS=smtp-relay.brevo.com
SMTP_PORT=587
SMTP_USERNAME=your-provider-smtp-login
SMTP_PASSWORD=your-provider-smtp-key
MAIL_FROM="Backsoon <your-verified-sender@example.com>"
```

The SMTP host above is Brevo's relay; use your provider's values. For Brevo, use the SMTP key rather than the API key or account password, and verify the sender in its dashboard. Set owner-only permissions with `chmod 600 .env`. The file is ignored by Git; keep real credentials out of tracked files.

Restart `make dev` after changing the file. Foreman loads `.env` into the web process. A nonblank `SMTP_ADDRESS` enables SMTP with STARTTLS and certificate verification, and delivery errors appear in the development log. Removing that setting restores local file delivery. Automated tests always use Rails' test delivery adapter.

Test delivery by requesting a reset for an existing account whose inbox you control. Development links point to localhost, so open them on the machine running Backsoon. SMTP sends the message; it does not expose your local app to the internet.

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

`.env.example` lists configuration names. `make dev` loads `.env` through Foreman. Direct Rails commands and production do not automatically load that file; supply variables through your shell, service manager, or container runtime.

## Contributing

Keep business rules in models, request handling in controllers, and presentation in helpers and ERB views. Use services only when a real operation outgrows those boundaries. Add regression tests for behavior, keep commits focused, and run `make check` plus `make e2e` before pushing changes to flows used in the browser.
