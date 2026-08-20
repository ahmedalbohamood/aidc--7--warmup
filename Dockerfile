# FROM: python:3.11-slim. It's Debian, trimmed down, with Python already
# installed. ubuntu:latest is a general-purpose OS image with no Python on
# it and a lot we don't need (docs, extra tooling) — bigger image, bigger
# attack surface, for a 40-line stdlib-only server that needs none of it.
FROM python:3.11-slim

# WORKDIR: the code lives at /app inside the container.
WORKDIR /app

# COPY requirements first so pip install is a cached layer — it only
# reruns when requirements.txt itself changes, not on every code edit.
COPY requirements.txt .
RUN pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu torch \
 && pip install --no-cache-dir -r requirements.txt

# Bake the model weights into the image at build time so the container
# runs with no network. ignore_patterns drops the ONNX exports (~1.4 GB
# of formats we never load) that this repo ships alongside the real
# weights.
ENV HF_HOME=/opt/hf
RUN python -c "from huggingface_hub import snapshot_download; \
    snapshot_download('HuggingFaceTB/SmolLM2-135M-Instruct', \
    ignore_patterns=['onnx/*'])"

# COPY: code comes last — a code change invalidates this layer and
# everything after it, but not the (expensive) model download above.
COPY . .

# CMD: start the server. List form (exec form) runs the binary directly,
# no shell in between. -u disables Python's stdout buffering so `docker
# logs` shows output as it happens instead of only at exit.
CMD ["python", "-u", "server.py"]
