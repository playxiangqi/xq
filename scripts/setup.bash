#!/usr/bin/env bash

# Install and setup asdf version manager
git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.8.0
chmod +x $HOME/.asdf/asdf.sh

$HOME/.asdf/asdf.sh plugin add erlang
$HOME/.asdf/asdf.sh plugin add elixir
$HOME/.asdf/asdf.sh plugin add nodejs
$HOME/.asdf/asdf.sh plugin add cmake

${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring -y

asdf install

# Build web and backend dependencies
pushd xq_app
yarn
popd

pushd xq_portal
mix setup
popd
