#!/bin/sh
set -e

sed -i "s|<!-- RUNTIME_CONFIG -->|<script>window.flutterConfig={apiBaseUrl:\"${API_BASE_URL:-}\"};</script>|" /srv/index.html

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
