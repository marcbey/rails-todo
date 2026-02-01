# AGENTS

Guidance for contributors and automated agents working in this repo.

## Project overview

Rails app for group-based messaging with user accounts, group memberships, and
message threads. Messages can include file attachments.

## Setup

```bash
bin/setup
```

## Run

```bash
bin/dev
```

## Tests

```bash
bin/rails test
bin/rails spec
```

## Lint and Security

```bash
bin/rubocop
bin/bundler-audit
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
```

## CI

```bash
bin/ci
```

## Repo conventions

- Keep secrets out of git (see `.gitignore`).
- Prefer `bin/*` wrappers over raw `bundle exec`.
- Add or update tests when changing behavior.
