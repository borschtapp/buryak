# Note: Requires pre-built web artifacts in build/web.
# Run `flutter build web --release` before building this container image.
FROM caddy:alpine

COPY build/web /srv
COPY docker/Caddyfile /etc/caddy/Caddyfile
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
