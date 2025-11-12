# ===============================================
# BUILD STAGE
# ===============================================
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copia apenas o pom.xml para cache de dependências
COPY pom.xml .

# Baixa dependências (cache eficiente)
RUN mvn dependency:go-offline -q

# Copia código-fonte
COPY src ./src

# Build com testes (CI roda, mas local pode pular)
RUN mvn clean package -DskipTests -q \
    -Dmaven.compiler.source=17 \
    -Dmaven.compiler.target=17

# ===============================================
# RUNTIME STAGE (IMAGEM LEVE)
# ===============================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copia o JAR gerado
COPY --from=builder /app/target/skillmatch-ai-1.0.0.jar app.jar

# Cria diretório de logs
RUN mkdir -p /app/logs && \
    addgroup -g 1001 appuser && \
    adduser -D -u 1001 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

# Variáveis de ambiente (padrão PROD)
ENV SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"

# Entrypoint flexível
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]