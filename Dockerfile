# FROM: python:3.11-slim. It's Debian, trimmed down, with Python already
# installed. ubuntu:latest is a general-purpose OS image with no Python on
# it and a lot we don't need (docs, extra tooling) — bigger image, bigger
# attack surface, for a 40-line stdlib-only server that needs none of it.
FROM python:3.11-slim

# WORKDIR: the code lives at /app inside the container.
WORKDIR /app

# COPY: bring the whole build context (this repo) in, minus what
# .dockerignore excludes.
COPY . .

# CMD: start the server. List form (exec form) runs the binary directly,
# no shell in between. -u disables Python's stdout buffering so `docker
# logs` shows output as it happens instead of only at exit.
CMD ["python", "-u", "server.py"]
