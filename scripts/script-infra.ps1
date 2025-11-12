# Script de Infra (PowerShell) para a Pipeline de Release (CD)
# Foco: Criar os recursos da APLICAÇÃO (Oracle, Mongo)
# Pré-requisito: O ACR ('acrskillmatchfiap') JÁ DEVE EXISTIR.

Write-Host "Iniciando script de infraestrutura (PowerShell)..."

# --- Configurações ---
$RESOURCE_GROUP="Globalsolution"
$LOCATION="eastus2"

# Senhas (NÃO COLOQUE SENHAS REAIS AQUI - Use Variáveis da Pipeline)
$ORACLE_PWD="password_forte_123"
$MONGO_USER="mongoadmin"
$MONGO_PWD="password_forte_456"

# === 1. GARANTIR QUE O RESOURCE GROUP EXISTA (Requisito da GS, Pág 31) ===
Write-Host "Garantindo que o Resource Group '$RESOURCE_GROUP' exista..."
az group create --name $RESOURCE_GROUP --location $LOCATION --output none

# === 2. CRIAR OS BANCOS DE DADOS (Containers ACI) ===

# A. Criar o Container do Oracle
Write-Host "Iniciando deploy do 'oracle-db-container'..."
az container create --resource-group $RESOURCE_GROUP `
    --name "oracle-db-container" `
    --image "gvenzl/oracle-xe:latest" `
    --ports 1521 `
    --dns-name-label "oracle-skillmatch-eastus2" `
    --environment-variables ORACLE_PASSWORD="$ORACLE_PWD" `
    --cpu 1 --memory 2 `
    --location $LOCATION `
    --output none

# B. Criar o Container do MongoDB
Write-Host "Iniciando deploy do 'mongo-db-container'..."
az container create --resource-group $RESOURCE_GROUP `
    --name "mongo-db-container" `
    --image "mongo:latest" `
    --ports 27017 `
    --dns-name-label "mongo-skillmatch-eastus2" `
    --environment-variables MONGO_INITDB_ROOT_USERNAME="$MONGO_USER" MONGO_INITDB_ROOT_PASSWORD="$MONGO_PWD" `
    --cpu 1 --memory 1.5 `
    --location $LOCATION `
    --output none

Write-Host "Infraestrutura de containers (Bancos) criada com sucesso."
Write-Host "Oracle DNS: oracle-skillmatch-eastus2.$LOCATION.azurecontainer.io"
Write-Host "Mongo DNS: mongo-skillmatch-eastus2.$LOCATION.azurecontainer.io"


**(O seu `scripts/script-bd.sql` continua igual, não precisa de o alterar.)**

---

### Passo 2: Faça o "Upload" (Git Push) da Correção

Agora, envie esta alteração (apagar o `.sh` e adicionar o `.ps1`) para o seu GitHub.

```bash
# 1. Adiciona as alterações (o delete e o novo .ps1)
git add .

# 2. Cria o commit
git commit -m "FIX: Convertendo script de infra para PowerShell (.ps1) para agente Windows"

# 3. Envia para o GitHub
git push