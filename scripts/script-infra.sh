#!/bin/bash
# Script de Infra (ACI) para a Pipeline de Release (CD)
# Foco: Criar os recursos da APLICAÇÃO (Oracle, Mongo)
# Pré-requisito: O ACR ('acrskillmatchfiap') JÁ DEVE EXISTIR.

# --- Configurações ---
RESOURCE_GROUP="Globalsolution"
LOCATION="eastus2"

# Senhas (NÃO COLOQUE SENHAS REAIS AQUI - Use Variáveis da Pipeline)
ORACLE_PWD="password_forte_123"
MONGO_USER="mongoadmin"
MONGO_PWD="password_forte_456"

# === 1. GARANTIR QUE O RESOURCE GROUP EXISTA (Requisito da GS, Pág 31) ===
# Este comando é "idempotente": ele cria o RG se não existir,
# ou apenas continua se ele JÁ existir (como no seu caso).
echo "Garantindo que o Resource Group '$RESOURCE_GROUP' exista..."
az group create --name $RESOURCE_GROUP --location $LOCATION --output none

# === 2. CRIAR OS BANCOS DE DADOS (Containers ACI) ===

# A. Criar o Container do Oracle
echo "Iniciando deploy do 'oracle-db-container'..."
az container create \
    --resource-group $RESOURCE_GROUP \
    --name oracle-db-container \
    --image gvenzl/oracle-xe:latest \
    --ports 1521 \
    --dns-name-label oracle-skillmatch-eastus2 \
    --environment-variables 'ORACLE_PASSWORD'=$ORACLE_PWD \
    --cpu 1 --memory 2 \
    --location $LOCATION \
    --output none

# B. Criar o Container do MongoDB
echo "Iniciando deploy do 'mongo-db-container'..."
az container create \
    --resource-group $RESOURCE_GROUP \
    --name mongo-db-container \
    --image mongo:latest \
    --ports 27017 \
    --dns-name-label mongo-skillmatch-eastus2 \
    --environment-variables 'MONGO_INITDB_ROOT_USERNAME'=$MONGO_USER 'MONGO_INITDB_ROOT_PASSWORD'=$MONGO_PWD \
    --cpu 1 --memory 1.5 \
    --location $LOCATION \
    --output none

echo "Infraestrutura de containers (Bancos) criada com sucesso."
echo "Oracle DNS: oracle-skillmatch-eastus2.$LOCATION.azurecontainer.io"
echo "Mongo DNS: mongo-skillmatch-eastus2.$LOCATION.azurecontainer.io"