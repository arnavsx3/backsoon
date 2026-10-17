# Deployment

The repository includes a production Rails configuration and Dockerfile. No external deployment or email delivery service has been provisioned.

## Required configuration

Set `APP_HOST` to your real hostname and provide a stable `SECRET_KEY_BASE`. Generate a secret once with `bin/rails secret` and store it in your deployment’s private environment configuration. Do not regenerate it on each startup.

Production forces HTTPS and expects an HTTPS-terminating reverse proxy. The public hostname is allowlisted; `/up` remains available for local health checks. The proxy must forward the original scheme correctly.

Mount a persistent directory at `/rails/storage` when using Docker. It holds the primary database, Solid Queue, Solid Cache, and local password-reset messages when SMTP is absent. Retain and back up this directory across container replacements.

For a single server, set `SOLID_QUEUE_IN_PUMA=1` to run queued jobs inside Puma. Alternatively, run `bin/jobs` as a separate worker with the same environment and persistent storage. Password-reset delivery uses Active Job and requires a running worker.

## Container

```sh
docker build -t backsoon .
docker volume create backsoon-storage
docker run --name backsoon \
  --env-file .env.production \
  --mount source=backsoon-storage,target=/rails/storage \
  -p 127.0.0.1:8080:80 \
  backsoon
```

Create `.env.production` privately with at least:

```text
APP_HOST=your-real-hostname.example
SECRET_KEY_BASE=your-generated-secret
BACKSOON_STORAGE=/rails/storage
SOLID_QUEUE_IN_PUMA=1
```

Put the HTTPS proxy in front of local port 8080. The entrypoint prepares production databases before starting the non-root Rails process. Image builds precompile assets using a dummy build secret; runtime signing uses your actual secret.

For source-based operation, install the locked gems, set the production environment and secret, run `bin/rails db:prepare` and `bin/rails assets:precompile`, then start Puma and the worker. See `.env.example` for configuration names.

## Password-reset delivery

Set `SMTP_ADDRESS`, `SMTP_PORT` (default 587), `SMTP_USERNAME`, `SMTP_PASSWORD`, and a verified `MAIL_FROM` address to deliver password-reset messages through your mail provider. SMTP uses STARTTLS with certificate verification.

Without SMTP configuration, reset messages remain private files under `BACKSOON_STORAGE/mail`; an administrator can retrieve them locally. This fallback does not send email. Configure SMTP for normal self-service recovery on a public installation.

Borrower contacts are never sent reminders. Account reset messages are the only application email.

## Verification and operating limits

Before release, run `make check`, `make e2e`, and a production boot with your intended environment. `/up` checks that the app boots; it is not a full database or mail-delivery probe.

SQLite is appropriate for this small, single-server app. All app instances and workers must access the same persistent local files. A multi-host deployment needs a different database/storage plan. Schema changes are versioned migrations; use a database-consistent backup procedure before applying changes to important production data.
