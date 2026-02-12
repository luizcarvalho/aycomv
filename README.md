# README

This README would normally document whatever steps are necessary to get the application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

## Scheduled Tasks (Cron)

To enable the timelapse video generation, you need to set up two scheduled tasks.

### 1. Capture Snapshots (Every ~24 seconds)

This task captures a frame from each active stream. It should run frequently.

```cron
* * * * * /path/to/project/bin/rails streams:capture
* * * * * slightly_delayed_capture... (if you need higher frequency than 1 min, use a loop or sleep in a wrapper script)
```

**Recommended Wrapper Script for High Frequency (e.g., every 20s):**
```bash
#!/bin/bash
cd /path/to/project
/usr/local/bin/docker compose exec -T app bundle exec rake streams:capture
sleep 20
/usr/local/bin/docker compose exec -T app bundle exec rake streams:capture
sleep 20
/usr/local/bin/docker compose exec -T app bundle exec rake streams:capture
```

### 2. Compile Videos (Daily at 00:30)

This task stitches the day's snapshots into a video file.

```cron
30 0 * * * cd /path/to/project && /usr/local/bin/docker compose exec -T app bundle exec rake streams:compile
```
