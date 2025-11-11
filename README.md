# SkillMatch AI - Plataforma de Reskilling e Match de Vagas

Uma plataforma híbrida de matching de habilidades que conecta trabalhadores a oportunidades de emprego baseado em análise inteligente de competências, com recomendações de trilhas de aprendizado para desenvolvimento profissional contínuo.

## Arquitetura da Solução

### Componentes Principais

1. **Motor de Match (Oracle PL/SQL)**: Calcula o percentual de compatibilidade entre trabalhador e vaga
2. **Repositório de Conteúdo (MongoDB)**: Armazena trilhas de aprendizado detalhadas
3. **Backend de Integração (Java/Spring Boot)**: API RESTful que orquestra todo o sistema

## Tecnologias Utilizadas

- **Java 17** com Spring Boot 3.2.0
- **Oracle Database** para dados relacionais
- **MongoDB** para conteúdo de aprendizado
- **Spring Data JPA** para persistência relacional
- **Spring Data MongoDB** para persistência NoSQL
- **Spring Security** com JWT para autenticação
- **Micrometer/Prometheus** para observabilidade
- **JUnit 5 e Mockito** para testes
- **Docker e Docker Compose** para containerização

## Pré-requisitos

- Java 17+
- Maven 3.9+
- Docker e Docker Compose
- Git

## Instalação e Execução

### 1. Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/skillmatch-ai.git
cd skillmatch-ai
```

### 2. Executar com Docker Compose

```bash
docker-compose up -d
```

Isso iniciará:
- Oracle Database (porta 1521)
- MongoDB (porta 27017)
- Aplicação Spring Boot (porta 8080)

### 3. Executar Localmente (sem Docker)

#### Configurar Banco de Dados

Antes de executar, configure as variáveis de ambiente:

```bash
export DB_USERNAME=system
export DB_PASSWORD=oracle
export MONGO_HOST=localhost
export MONGO_PORT=27017
export MONGO_USERNAME=root
export MONGO_PASSWORD=password
```

#### Build e Execução

```bash
mvn clean install
mvn spring-boot:run
```

## Estrutura do Projeto

```
skillmatch-ai/
├── src/
│   ├── main/
│   │   ├── java/com/skillmatch/
│   │   │   ├── controller/        # Controllers REST
│   │   │   ├── service/           # Lógica de negócio
│   │   │   ├── entity/            # Entidades JPA (Oracle)
│   │   │   ├── document/          # Documentos MongoDB
│   │   │   ├── repository/        # Repositórios
│   │   │   ├── dto/               # Data Transfer Objects
│   │   │   └── SkillMatchAiApplication.java
│   │   └── resources/
│   │       └── application.yml    # Configurações
│   └── test/
│       └── java/com/skillmatch/   # Testes unitários
├── pom.xml                        # Dependências Maven
├── Dockerfile                     # Imagem Docker
├── docker-compose.yml             # Orquestração de containers
└── README.md
```

## API Endpoints

### Versão: v1

#### Trabalhadores

- `POST /api/v1/trabalhadores` - Criar trabalhador
- `GET /api/v1/trabalhadores` - Listar todos
- `GET /api/v1/trabalhadores/{id}` - Obter por ID
- `GET /api/v1/trabalhadores/ativos` - Listar ativos
- `PUT /api/v1/trabalhadores/{id}` - Atualizar
- `DELETE /api/v1/trabalhadores/{id}` - Deletar

#### Vagas

- `POST /api/v1/vagas` - Criar vaga
- `GET /api/v1/vagas` - Listar todas
- `GET /api/v1/vagas/{id}` - Obter por ID
- `GET /api/v1/vagas/empresa/{idEmpresa}` - Listar por empresa
- `PUT /api/v1/vagas/{id}` - Atualizar
- `DELETE /api/v1/vagas/{id}` - Deletar

#### Match (Motor de Compatibilidade)

- `GET /api/v1/match/compatibilidade/{idTrabalhador}/{idVaga}` - Calcular compatibilidade
- `GET /api/v1/match/vagas-compativeis/{idTrabalhador}` - Listar vagas compatíveis

## Documentação da API

Acesse a documentação interativa em:

```
http://localhost:8080/api/swagger-ui.html
```

## Monitoramento e Observabilidade

### Health Check

```
GET http://localhost:8080/api/actuator/health
```

### Métricas Prometheus

```
GET http://localhost:8080/api/actuator/prometheus
```

### Logs

Os logs são salvos em `logs/skillmatch-ai.log` e também exibidos no console.

## Testes

### Executar Testes Unitários

```bash
mvn test
```

### Executar com Cobertura

```bash
mvn clean test jacoco:report
```

Relatório de cobertura: `target/site/jacoco/index.html`

## CI/CD no Azure DevOps

### Pipeline de Build (CI)

1. Restauração de dependências
2. Compilação do projeto
3. Execução de testes
4. Publicação de artefatos

### Pipeline de Release (CD)

1. Download do artefato
2. Deploy no Azure App Service
3. Validação de saúde da aplicação

## Configuração de Segurança

### JWT (JSON Web Token)

A autenticação é feita via JWT. Configure a chave secreta:

```bash
export JWT_SECRET=sua-chave-secreta-aqui
```

### HTTPS

Em produção, sempre use HTTPS. Configure o certificado SSL no Azure App Service.

## Troubleshooting

### Erro de Conexão com Oracle

Verifique se o container Oracle está rodando:

```bash
docker ps | grep oracle
```

### Erro de Conexão com MongoDB

Verifique a URI de conexão e credenciais:

```bash
docker logs skillmatch-mongodb
```

### Erro ao Iniciar a Aplicação

Verifique os logs:

```bash
docker logs skillmatch-api
```

## Contribuindo

1. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
2. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
3. Push para a branch (`git push origin feature/AmazingFeature`)
4. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT.

## Contato

Para dúvidas ou sugestões, entre em contato com o time de desenvolvimento.

---

**Desenvolvido para a Global Solution 2025 - FIAP**
