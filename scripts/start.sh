#!/usr/bin/env sh

set -e

echo "Running migrations..."
bin/xq eval "XQ.Release.migrate"
echo "Starting xq..."
bin/xq start
