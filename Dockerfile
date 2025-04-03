FROM quay.io/keycloak/keycloak:17.0.0 as builder

# Enable preview features
ENV KC_FEATURES=preview
# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure database vendor
ENV KC_DB=postgres

# Build Keycloak
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:17.0.0
COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/

WORKDIR /opt/keycloak

# Setup certificates
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore

# Keycloak Admin Credentials (use env variables instead of hardcoding)
ENV KEYCLOAK_ADMIN=${KEYCLOAK_ADMIN}
ENV KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}

# Database Configuration (from environment variables)
ENV KC_DB_URL=${KC_DB_URL}
ENV KC_DB_USERNAME=${KC_DB_USERNAME}
ENV KC_DB_PASSWORD=${KC_DB_PASSWORD}

# Set ports from environment variables (default to Render-compatible values)
ENV KC_HTTP_PORT=${KC_HTTP_PORT}
ENV KC_HTTPS_PORT=${KC_HTTPS_PORT}

# Expose the required ports
EXPOSE ${KC_HTTP_PORT}
EXPOSE ${KC_HTTPS_PORT}

# Start Keycloak with custom ports
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--http-port=${KC_HTTP_PORT}", "--https-port=${KC_HTTPS_PORT}"]

