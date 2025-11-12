#!/bin/bash

# ===============================================
# SCRIPT DE INFRA (Bash) - Pipeline de Release (CD)
# Requisitos: Idempotente, Seguro, Sem Hardcode
# ===============================================

set -e  # Para o script se qualquer comando falhar

echo "INICIANDO SCRIPT DE INFRAESTRUTURA (Bash)..." | tee -a /tmp/infra.log

# --- CONFIGURAÇÕES ---
RESOURCE_GROUP="Globalsolution"
LOCATION="eastus2"
UID="marcelo01-$(date +%H%M%S)"

# --- VARIÁVEIS DE AMBIENTE OBRIGATÓRIAS (NUNCA HARDCODE!) ---
ORACLE_PWD="${ORACLE_PWD:?ERRO: ORACLE_PWD não definida na pipeline!}"
MONGO_USER="${MONGO_USER:?ERRO: MONGO_USER não definida na pipeline!}"
MONGO_PWD="${MONGO_PWD:?ERRO: MONGO_PWD não definida na pipeline!}"

# === 1. GARANTIR RESOURCE GROUP (IDEMPOTENTE) ===
echo "1. Verificando Resource Group '$RESOURCE_GROUP'..." | tee -a /tmp/infra.log
if ! az group show --name "$RESOURCE_GROUP" &>/dev/null; then
    echo "Criando Resource Group..." | tee -a /tmp/infra.log
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
else
    echo "Resource Group já existe!" | tee -a /tmp/infra.log
fi

# === 2. CRIAR ORACLE XE (IDEMPOTENTE) ===
ORACLE_NAME="oracle-db-container"
ORACLE_DNS="oracle-skillmatch-$UID"

echo "2. Verificando Oracle Container '$ORACLE_NAME'..." | tee -a /tmp/infra.log
if ! az container show --resource-group "$RESOURCE_GROUP" --name "$ORACLE_NAME" &>/dev/null; then
    echo "Criando Oracle Container..." | tee -a /tmp/infra.log
    az container create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$ORACLE_NAME" \
        --image "gvenzl/oracle-xe:latest" \
        --os-type Linux \
        --dns-name-label "$ORACLE_DNS" \
        --ports 1521 \
        --environment-variables "ORACLE_PASSWORD=$ORACLE_PWD" \
        --cpu 2 --memory 3.5 \
        --location "$LOCATION" \
        --restart-policy Always \
        --output none
else
    echo "Oracle Container já existe!" | tee -a /tmp/infra.log
fi

ORACLE_FQDN="$ORACLE_DNS.$LOCATION.azurecontainer.io"
echo "Oracle DNS: $ORACLE_FQDN" | tee -a /tmp/infra.log

# === 3. CRIAR MONGODB (IDEMPOTENTE) ===
MONGO_NAME="mongo-db-container"
MONGO_DNS="mongo-skillmatch-$UID"

echo "3. Verificando MongoDB Container '$MONGO_NAME'..." | tee -a /tmp/infra.log
if ! az container show --resource-group "$RESOURCE_GROUP" --name "$MONGO_NAME" &>/dev/null; then
    echo "Criando MongoDB Container..." | tee -a /tmp/infra.log
    az container create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$MONGO_NAME" \
        --image "mongo:latest" \
        --os-type Linux \
        --dns-name-label "$MONGO_DNS" \
        --ports 27017 \
        --environment-variables \
            "MONGO_INITDB_ROOT_USERNAME=$MONGO_USER" \
            "MONGO_INITDB_ROOT_PASSWORD=$MONGO_PWD" \
        --cpu 1 --memory 1.5 \
        --location "$LOCATION" \
        --restart-policy Always \
        --output none
else
    echo "MongoDB Container já existe!" | tee -a /tmp/infra.log
fi

MONGO_FQDN="$MONGO_DNS.$LOCATION.azurecontainer.io"
echo "Mongo DNS: $MONGO_FQDN" | tee -a /tmp/infra.log

# === 4. AGUARDAR ORACLE PRONTO (MÁX 15 MIN) ===
echo "4. Aguardando Oracle ficar pronto..." | tee -a /tmp/infra.log
timeout=900
elapsed=0
until [ "$(az container show --resource-group "$RESOURCE_GROUP" --name "$ORACLE_NAME" --query "containers[0].instanceView.currentState.state" --output tsv 2>/dev/null)" = "Running" ] || [ $elapsed -ge $timeout ]; do
    sleep 30
    elapsed=$((elapsed + 30))
    echo "Oracle: Aguardando... ($((elapsed/60)) min)" | tee -a /tmp/infra.log
done

if [ $elapsed -ge $timeout ]; then
    echo "ERRO: Timeout ao aguardar Oracle!" | tee -a /tmp/infra.log
    exit 1
fi
echo "ORACLE PRONTO!" | tee -a /tmp/infra.log

# === 5. AGUARDAR MONGODB PRONTO (MÁX 5 MIN) ===
echo "5. Aguardando MongoDB ficar pronto..." | tee -a /tmp/infra.log
timeout=300
elapsed=0
until [ "$(az container show --resource-group "$RESOURCE_GROUP" --name "$MONGO_NAME" --query "containers[0].instanceView.currentState.state" --output tsv 2>/dev/null)" = "Running" ] || [ $elapsed -ge $timeout ]; do
    sleep 10
    elapsed=$((elapsed + 10))
done

if [ $elapsed -ge $timeout ]; then
    echo "AVISO: MongoDB demorou, mas pode estar subindo..." | tee -a /tmp/infra.log
else
    echo "MONGODB PRONTO!" | tee -a /tmp/infra.log
fi

# === 6. EXPORTAR VARIÁVEIS PARA A PRÓXIMA TASK ===
ORACLE_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ORACLE_NAME" --query "ipAddress.ip" --output tsv)
MONGO_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$MONGO_NAME" --query "ipAddress.ip" --output tsv)

echo "ORACLE_IP: $ORACLE_IP" | tee -a /tmp/infra.log
echo "MONGO_IP: $MONGO_IP" | tee -a /tmp/infra.log

# Exporta para Azure DevOps
echo "##vso[task.setvariable variable=ORACLE_IP;isOutput=true]$ORACLE_IP"
echo "##vso[task.setvariable variable=MONGO_IP;isOutput=true]$MONGO_IP"
echo "##vso[task.setvariable variable=ORACLE_FQDN;isOutput=true]$ORACLE_FQDN"
echo "##vso[task.setvariable variable=MONGO_FQDN;isOutput=true]$MONGO_FQDN"

echo "INFRAESTRUTURA CRIADA COM SUCESSO!" | tee -a /tmp/infra.log