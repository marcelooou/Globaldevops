#!/bin/bash

# --- Configurações ---
# O Resource Group que você já criou no portal
RESOURCE_GROUP="Globalsolution"
LOCATION="eastus2"

# Nomes DNS únicos para os containers
ORACLE_DNS_NAME="oracle-skillmatch-$LOCATION" # Adicionamos a localização para ser único
MONGO_DNS_NAME="mongo-skillmatch-$LOCATION"

# --- Variáveis de Senhas ---
# IMPORTANTE: Na sua Pipeline de Release, substitua estes valores
# por 'Pipeline Variables' (Variáveis de Pipeline) com o cadeado.
# (Requisito da GS, Página 35, Item 16)
ORACLE_PASSWORD="password_forte_123"
MONGO_USER="mongoadmin"
MONGO_PASS="password_forte_456"

# --- Execução ---
echo "Iniciando a criação da infraestrutura de DBs em $LOCATION..."

# 1. Cria um Container (ACI) para o banco ORACLE
# (Estamos usando uma imagem do Oracle XE)
echo "Criando ACI para Oracle XE (nome: oracle-db-container)..."
az container create \
    --resource-group $RESOURCE_GROUP \
    --name oracle-db-container \
    --image gvenzl/oracle-xe:latest \
    --ports 1521 \
    --dns-name-label $ORACLE_DNS_NAME \
    --environment-variables 'ORACLE_PASSWORD'=$ORACLE_PASSWORD \
    --cpu 1 --memory 2 \
    --location $LOCATION \
    --output none

# 2. Cria um Container (ACI) para o banco MONGODB
echo "Criando ACI para MongoDB (nome: mongo-db-container)..."
az container create \
    --resource-group $RESOURCE_GROUP \
    --name mongo-db-container \
    --image mongo:latest \
    --ports 27017 \
    --dns-name-label $MONGO_DNS_NAME \
    --environment-variables 'MONGO_INITDB_ROOT_USERNAME'=$MONGO_USER 'MONGO_INITDB_ROOT_PASSWORD'=$MONGO_PASS \
    --cpu 1 --memory 1.5 \
    --location $LOCATION \
    --output none

echo "--- Infraestrutura de containers (DBs) criada com sucesso ---"
echo "DNS do Oracle: $ORACLE_DNS_NAME.$LOCATION.azurecontainer.io"
echo "DNS do Mongo: $MONGO_DNS_NAME.$LOCATION.azurecontainer.io"