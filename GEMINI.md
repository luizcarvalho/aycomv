# GEMINI.md

## Project Overview

This is a Ruby on Rails application named "aycomvideos". Based on the file structure and dependencies, it appears to be a web application for managing and processing video streams.

The application uses:
- **Backend:** Ruby on Rails 8.1
- **Database:** PostgreSQL
- **Frontend:** Hotwire (Turbo and Stimulus) with importmap-rails for JavaScript management.
- **Background Jobs:** Solid Queue
- **Caching:** Solid Cache
- **Websocket:** Solid Cable
- **Deployment:** Kamal
- **Containerization:** Docker and Docker Compose

The core functionality seems to revolve around `Clients`, `Streams`, and `Videos`. There are services for capturing (`StreamCaptureService`) and compiling (`StreamCompilerService`) streams, suggesting that the application can record and process live streams into videos. Scheduled tasks are used to automate the capture and compilation process.

## Building and Running

The application is containerized using Docker and is intended to be run using Docker Compose for development.

### Development Environment

**1. Build the Docker image:**
```bash
docker compose build app
```

**2. Start the application:**
```bash
docker compose up
```
The application will be available at [http://localhost:3000](http://localhost:3000).

**3. Running commands:**
To run any command inside the application container, use `docker compose run --rm app`. For example, to open a Rails console:
```bash
docker compose run --rm app bin/rails console
```

### Running Tests

The test suite can be run using the following command:
```bash
docker compose run --rm app bin/rails test
```

System tests can be run with:
```bash
docker compose run --rm app bin/rails test:system
```

The full CI process can be run locally with:
```bash
docker compose run --rm app bin/ci
```
This will run style checks, security audits, and all tests.

### Database

The database is managed by Active Record. Migrations can be run with:
```bash
docker compose run --rm app bin/rails db:migrate
```

To seed the database:
```bash
docker compose run --rm app bin/rails db:seed
```

## Development Conventions

### Code Style

The project uses `rubocop-rails-omakase` for Ruby code styling. To check for style issues, run:
```bash
docker compose run --rm app bin/rubocop
```

### Scheduled Tasks

The application relies on two scheduled tasks for its core functionality:
- **`streams:capture`:** Captures frames from active streams. It's intended to be run frequently (e.g., every 20-30 seconds).
- **`streams:compile`:** Compiles the captured frames into videos. It's intended to be run daily.

The `README.md` file provides examples of how to set these up using cron.
