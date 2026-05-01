# Stage 1: build Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS builder

ARG API_BASE_URL
ARG BUILD_NAME=0.0.0
ARG BUILD_NUMBER=0

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN dart run build_runner build --delete-conflicting-outputs
RUN flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL} \
    --build-name=${BUILD_NAME} \
    --build-number=${BUILD_NUMBER}

# Stage 2: serve with Caddy
FROM caddy:alpine

COPY --from=builder /app/build/web /srv
COPY docker/Caddyfile /etc/caddy/Caddyfile
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
