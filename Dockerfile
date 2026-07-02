FROM python:3.12-slim AS builder

ENV PIP_NO_CACHE_DIR=1 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false

WORKDIR /meilisync

RUN apt-get update \
    && apt-get install --no-install-recommends -y build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip poetry

COPY pyproject.toml poetry.lock README.md LICENSE CHANGELOG.md ./
RUN poetry install --only main -E all --no-root

COPY meilisync ./meilisync
RUN poetry install --only main -E all

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /meilisync
COPY --from=builder /usr/local /usr/local
COPY --from=builder /meilisync /meilisync

CMD ["meilisync", "start"]
