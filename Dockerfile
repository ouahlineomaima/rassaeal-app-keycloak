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

# Keycloak Admin Credentials (use env variables instead of hardcoding)
ENV KEYCLOAK_ADMIN=${KEYCLOAK_ADMIN}
ENV KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}

# Database Configuration (from environment variables)
ENV KC_DB_URL=${KC_DB_URL}
ENV KC_DB_USERNAME=${KC_DB_USERNAME}
ENV KC_DB_PASSWORD=${KC_DB_PASSWORD}


# Expose the required ports
EXPOSE 10000

# Start Keycloak with custom ports
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--http-port=10000", "--https-port=10000", "--proxy=edge"]

