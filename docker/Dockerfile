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

RUN git clone https://github.com/asdf-vm/asdf.git /opt/.asdf --branch v0.8.0 && \
  chmod +x /opt/.asdf/asdf.sh && \
  /opt/.asdf/asdf.sh plugin add nodejs cmake && \
  /opt/.asdf/asdf.sh install

# Set build environments
ENV MIX_ENV=${MIX_ENV}
ENV DATABASE_URL=${DATABASE_URL}
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Install mix dependencies
COPY mix.exs mix.lock ./
COPY config config

RUN mix do deps.get --only ${MIX_ENV}, deps.compile

# Build assets
COPY priv priv
COPY assets assets
RUN yarn --cwd assets deploy

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

COPY --from=build --chown=nobody:nogroup /opt/app/_build/${MIX_ENV}/rel/xq ./
COPY --from=build --chown=nobody:nogroup /opt/app/start.sh ./

ENV HOME=/opt/app

CMD ["./start.sh"]
