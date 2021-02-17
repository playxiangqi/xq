# Version of alpine used by base image
ARG ALPINE_VERSION=3.11

FROM elixir:1.11.2-alpine AS build

ARG MIX_ENV
ARG DATABASE_URL
ARG SECRET_KEY_BASE

WORKDIR /opt/app

# Install dependencies and build tools
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache git build-base yarn && \
  mix local.rebar --force && \
  mix local.hex --force

# Set build environments
ENV MIX_ENV=${MIX_ENV}
ENV DATABASE_URL=${DATABASE_URL}
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Install mix dependencies
COPY mix.exs mix.lock ./
COPY config config

RUN mix do deps.get --only ${MIX_ENV}, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# Compile and build release
COPY lib lib
COPY scripts/start.sh ./

RUN mix do compile, release

# Prepare release image
FROM alpine:3.11 AS app

ARG MIX_ENV

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /opt/app

RUN chown nobody:nogroup /opt/app

USER nobody:nogroup

COPY --from=build --chown=nobody:nogroup /opt/app/_build/${MIX_ENV}/rel/xq_archive ./
COPY --from=build --chown=nobody:nogroup /opt/app/start.sh ./

ENV HOME=/opt/app

CMD ["./start.sh"]
