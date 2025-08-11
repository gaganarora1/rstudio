RStudio (Rocker) + PostgreSQL Support — Docker Setup

This repository provides a lightweight Docker image for RStudio Server (via Rocker’s tidyverse image) with PostgreSQL client libraries and R DB drivers preinstalled. It’s ideal for data science work that needs tidyverse + DBI + RPostgres/RPostgreSQL, and can run locally or on platforms like Railway.

⸻

What’s inside
	•	Base: rocker/tidyverse:latest (R, RStudio Server, tidyverse, dev tools)
	•	System libs: libpq-dev (PostgreSQL client headers)
	•	R packages: DBI, RPostgres, RPostgreSQL
	•	User: rstudio (home at /home/rstudio)
	•	Port: 8787 (RStudio Server)
	•	Auth: can be disabled via DISABLE_AUTH=true (headless dev, not for production)

⸻

Quick start (Docker Desktop)

1) Build

docker build -t rstudio-pg .

2) Run (ephemeral)

docker run --rm -p 8787:8787 \
  -e DISABLE_AUTH=true \
  --name rstudio rstudio-pg

Open http://localhost:8787 in your browser.

3) Run with persistence (recommended)

docker run --rm -p 8787:8787 \
  -e DISABLE_AUTH=true \
  -v $(pwd)/workspace:/home/rstudio \
  --name rstudio rstudio-pg

Your work will be saved in ./workspace.

Production note: Avoid DISABLE_AUTH=true in production. Use a password (see below).

⸻

Authentication options
	•	No auth (dev only):
	•	DISABLE_AUTH=true
	•	Access RStudio without a login prompt.
	•	Password auth (recommended):
	•	Omit DISABLE_AUTH (or set to false)
	•	Set a password for the rstudio user:

docker run --rm -p 8787:8787 \
  -e PASSWORD="strong_password_here" \
  --name rstudio rstudio-pg


	•	Login: username: rstudio  |  password: your PASSWORD.

⸻

Connecting to PostgreSQL from R

Using RPostgres (preferred)

library(DBI)
library(RPostgres)

con <- dbConnect(
  Postgres(),
  host = Sys.getenv("PGHOST", "localhost"),
  port = as.integer(Sys.getenv("PGPORT", "5432")),
  dbname = Sys.getenv("PGDATABASE", "postgres"),
  user = Sys.getenv("PGUSER", "postgres"),
  password = Sys.getenv("PGPASSWORD", "")
)

dbListTables(con)
dbDisconnect(con)

Optional: Centralize credentials with .Renviron

Create /home/rstudio/.Renviron:

PGHOST=your-db-host
PGPORT=5432
PGDATABASE=your-db-name
PGUSER=your-db-user
PGPASSWORD=your-secret

Restart R session in RStudio so Sys.getenv() picks them up.

⸻

Installing additional R packages

You already have install2.r available (from Rocker). To bake more packages into the image:

RUN install2.r --error --skipinstalled \
    arrow data.table odbc janitor

Or install at runtime from within RStudio:

install.packages(c("arrow", "data.table", "odbc", "janitor"))


⸻

File locations & permissions
	•	User home: /home/rstudio
	•	Projects (if you mounted a volume): /home/rstudio maps to ./workspace on your host
	•	The Dockerfile sets ownership to rstudio:rstudio and 755 perms so the IDE works smoothly.

⸻

Deploying to Railway

Railway typically assigns a dynamic $PORT. RStudio defaults to 8787. You have two options:
	1.	Use 8787 directly
Keep your service as a plain Docker deployment. Railway will map the container’s EXPOSE 8787 automatically.
	2.	Adapt to $PORT (if required by your setup)
Some setups prefer aligning RStudio with $PORT. You can pass:
	•	-e RSTUDIO_HTTP_PORT=$PORT (RStudio respects www-port, but behavior may vary by base image)
	•	Or run behind a reverse proxy that maps $PORT → 8787.

Environment suggestions on Railway:
	•	Dev/test: DISABLE_AUTH=true
	•	Prod: set PASSWORD and omit DISABLE_AUTH
	•	Add your DB env vars (PGHOST, PGPORT, etc.) in Railway variables

Command: The base image launches via /init (s6). No change needed unless you add a proxy.

⸻

Security notes
	•	Never use DISABLE_AUTH=true on a public URL.
	•	Use strong, rotated passwords for DB and RStudio.
	•	Prefer environment variables or secret stores for credentials (avoid committing .Renviron to Git).

⸻

Troubleshooting
	•	RStudio doesn’t load: confirm the container is running and -p 8787:8787 is mapped; check logs:

docker logs rstudio


	•	Auth keeps prompting: ensure you passed -e PASSWORD=... or -e DISABLE_AUTH=true.
	•	Can’t connect to PostgreSQL: confirm DB host/network allow connections from your container; validate with:

apt-get update && apt-get install -y postgresql-client && psql -h $PGHOST -U $PGUSER -d $PGDATABASE -p $PGPORT -c "\dt"

(Run interactively with docker exec -it rstudio bash)

⸻

Make it your own
	•	Add team packages to the Dockerfile using install2.r.
	•	Pre-seed templates or snippets into /home/rstudio.
	•	Compose with other services (e.g., Postgres) using docker-compose.yml.

⸻

Summary
	•	Run RStudio Server quickly with tidyverse + PostgreSQL support.
	•	Local dev: docker run -p 8787:8787 -e DISABLE_AUTH=true ...
	•	Prod: use PASSWORD, mount a volume, and secure your DB.
	•	Railway: deploy as Docker, expose 8787 (or map $PORT), keep secrets as env vars.

Happy analyzing!
