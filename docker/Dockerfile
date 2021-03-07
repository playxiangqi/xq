# Version of alpine used by base image
ARG ALPINE_VERSION=3.11

FROM elixir:1.11.2-alpine AS build

ARG BUILD
ARG MIX_ENV
ARG SECRET_KEY_BASE

WORKDIR /opt/app

# Install dependencies and build tools
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache git yarn && \
  # apk add --no-cache git build-base yarn && \
  mix local.rebar --force && \
  mix local.hex --force

# RUN git clone https://github.com/asdf-vm/asdf.git /opt/.asdf --branch v0.8.0 && \
#   chmod +x /opt/.asdf/asdf.sh && \
#   /opt/.asdf/asdf.sh plugin add nodejs cmake && \
#   /opt/.asdf/asdf.sh install

# Set build environments
ENV BUILD=${BUILD}
ENV MIX_ENV=${MIX_ENV}
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Install mix dependencies
COPY xq_portal xq_portal
RUN cd xq_portal && mix do deps.get --only ${MIX_ENV}, deps.compile

# Build assets
COPY xq_app xq_app
RUN yarn --cwd xq_app install && yarn --cwd xq_app deploy
RUN cd xq_portal && mix phx.digest

# Install engine
COPY xq_engine xq_engine

# Compile and build release
COPY scripts/start.sh ./xq_portal/
RUN cd xq_portal && mix do compile, release

# Prepare release image
FROM alpine:3.11 AS app

ARG BUILD
ARG MIX_ENV

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /opt/app

RUN chown nobody:nogroup /opt/app

USER nobody:nogroup

COPY --from=build --chown=nobody:nogroup /opt/app/xq_portal/_build/${MIX_ENV}/rel/xq ./
COPY --from=build --chown=nobody:nogroup /opt/app/xq_portal/start.sh ./
COPY --from=build --chown=nobody:nogroup /opt/app/xq_engine/fairy-stockfish ./

RUN echo "export BUILD=${BUILD} >> .env"

ENV HOME=/opt/app

CMD ["./start.sh"]
