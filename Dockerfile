# Build Stage
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copiar pom.xml
COPY pom.xml .

# Baixar dependências (com mais tempo)
RUN mvn dependency:resolve dependency:resolve-plugins -q

# Copiar código-fonte
COPY src ./src

# Build do projeto (com mais memória)
RUN mvn clean package -DskipTests -q \
    -Dmaven.compiler.source=17 \
    -Dmaven.compiler.target=17

# Runtime Stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copiar JAR do builder
COPY --from=builder /app/target/skillmatch-ai-1.0.0.jar app.jar

# Criar diretório de logs
RUN mkdir -p /app/logs

EXPOSE 8080

ENV SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS="-Xms256m -Xmx512m"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]