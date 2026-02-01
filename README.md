# Rails Todo

Group-based messaging app with user accounts, memberships, and message threads.
Users can create groups, join them, and post messages with optional file
attachments. Includes email-based password reset and session management.

## Requirements

* Ruby `4.0.1` (see `.ruby-version`)
* SQLite3
* Bundler (`gem install bundler`)

## Setup

```bash
bin/setup
```

## Run the app

```bash
bin/dev
```

Then visit http://localhost:3000.

## Database

```bash
bin/rails db:setup
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
