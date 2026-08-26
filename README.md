# Nic Tracker

A small Rails app that tracks daily domain registrations published by [nic.ar](https://nic.ar) (Argentina's national domain registry) and checks whether each registered domain actually resolves.

For a given date, it imports that day's registration list, then checks each domain's DNS status (online / offline) in the background. A stats page aggregates online vs. offline counts by date.

## Status

This is a personal learning project built to practice Ruby and Rails — not intended for production use.

## Stack

- Ruby 4.0.5, Rails 8.1
- SQLite
- Solid Queue for background jobs (import + DNS checks)
- Tailwind CSS

## Setup

```bash
git clone https://github.com/felix-sastre/nic_tracker.git
cd nic_tracker
bundle install
bin/rails db:prepare
```

Run everything (web server, Tailwind watcher, and the job worker) with:

```bash
bin/dev
```

Then visit `http://localhost:3000`.

The job worker (`bin/jobs`) matters here: importing a new date and checking a domain's DNS status both happen asynchronously. On the first request for a given date, the page renders immediately with a "still processing" state — reload a few seconds later to see the results.

## Tests

```bash
bin/rails test
```

## License

[MIT](LICENSE)
