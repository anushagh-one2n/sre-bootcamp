# Build stage
FROM gradle:8.14.3-jdk21-alpine AS builder

WORKDIR /workspace/app

COPY build.gradle.kts settings.gradle.kts gradlew ./
COPY gradle ./gradle

RUN ./gradlew dependencies --no-daemon || true


COPY src ./src


RUN ./gradlew bootJar --no-daemon


# Runtime stage
FROM eclipse-temurin:21-jre-alpine

# Create non-root user
ENV APP_USER=spring
RUN addgroup -S ${APP_USER} && adduser -S ${APP_USER} -G ${APP_USER}

WORKDIR /app

# Copy built jar from builder stage
COPY --from=builder /workspace/app/build/libs/*.jar app.jar

RUN chown ${APP_USER}:${APP_USER} app.jar

USER ${APP_USER}

EXPOSE 8080

# Default env vars (overridable at runtime)
ENV SERVER_PORT=8080
ENV DB_URL=""
ENV DB_USERNAME=""
ENV DB_PASSWORD=""

ENTRYPOINT ["java", "-jar", "app.jar"]
