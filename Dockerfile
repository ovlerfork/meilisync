FROM python:3.12-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_SYSTEM_PYTHON=1

WORKDIR /meilisync

COPY --from=ghcr.io/astral-sh/uv:0.11.26 /uv /uvx /bin/

RUN apt-get update \
    && apt-get install --no-install-recommends -y build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml README.md LICENSE CHANGELOG.md ./
COPY meilisync ./meilisync
RUN uv pip install --no-cache .[all]

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /meilisync
COPY --from=builder /usr/local /usr/local
COPY --from=builder /meilisync /meilisync

CMD ["meilisync", "start"]
