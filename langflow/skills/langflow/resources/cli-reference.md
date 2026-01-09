# Langflow CLI Reference

This document provides a comprehensive reference for the Langflow command-line interface (CLI), environment variables, and configuration options.

## Table of Contents

- [CLI Commands](#cli-commands)
  - [langflow run](#langflow-run)
  - [langflow superuser](#langflow-superuser)
  - [langflow migration](#langflow-migration)
  - [langflow api-key](#langflow-api-key)
  - [langflow copy-db](#langflow-copy-db)
- [Environment Variables](#environment-variables)
  - [Server Configuration](#server-configuration)
  - [Authentication and Security](#authentication-and-security)
  - [Database Configuration](#database-configuration)
  - [Cache Configuration](#cache-configuration)
  - [Visual Editor and Playground](#visual-editor-and-playground)
  - [Logging](#logging)
  - [CORS Configuration](#cors-configuration)
- [Configuration File Examples](#configuration-file-examples)
- [Docker Usage](#docker-usage)

---

## CLI Commands

The Langflow CLI is automatically installed when you install the Langflow package. It can be invoked with `uv run langflow` (recommended) or `langflow` directly if installed globally.

### Universal Options

All CLI commands support the following options:

| Option | Description |
|--------|-------------|
| `--version`, `-v` | Show the version and exit |
| `--install-completion` | Install auto-completion for the current shell |
| `--show-completion` | Show the location of the auto-completion config file |
| `--help` | Print command usage information |

### Boolean Options

Boolean options have enabled and disabled forms:
- Enabled: `--option`
- Disabled: `--no-option`

---

### langflow run

Starts the Langflow server.

```bash
# Using uv (recommended)
uv run langflow run [OPTIONS]

# Direct invocation
langflow run [OPTIONS]
```

#### Options

| Option | Default | Type | Description |
|--------|---------|------|-------------|
| `--port` | `7860` | Integer | The port on which the Langflow server will run. Automatically selects a free port if specified port is in use |
| `--host` | `localhost` | String | The host on which the Langflow server will run |
| `--backend-only` | `false` | Boolean | Run only the backend service (no frontend/visual editor) |
| `--env-file` | Not set | String | Path to the `.env` file containing environment variables |
| `--workers` | `1` | Integer | Number of Langflow server worker processes |
| `--worker-timeout` | `300` | Integer | Worker timeout in seconds |
| `--components-path` | Not set | String | Path to directory containing custom components |
| `--cache` | `async` | String | Cache storage type: `async`, `redis`, `memory`, or `disk` |
| `--dev` | `false` | Boolean | Run in development mode (may contain bugs) |
| `--auto-saving` | `true` | Boolean | Enable flow auto-saving in the visual editor |
| `--auto-saving-interval` | `1000` | Integer | Auto-save interval in milliseconds |
| `--open-browser` | `false` | Boolean | Open the system web browser on startup |
| `--remove-api-keys` | `false` | Boolean | Remove API keys from flows saved in the database |
| `--log-level` | `critical` | String | Logging level: `debug`, `info`, `warning`, `error`, `critical` |
| `--log-file` | `logs/langflow.log` | String | Path to the log file |
| `--log-rotation` | Not set | String | Log rotation interval (time duration or file size) |
| `--max-file-size-upload` | `1024` | Integer | Maximum file upload size in megabytes |
| `--health-check-max-retries` | `5` | Integer | Maximum retries for health check |
| `--frontend-path` | Not set | String | Path to frontend directory (for development only) |
| `--ssl-cert-file-path` | Not set | String | Path to SSL certificate file |
| `--ssl-key-file-path` | Not set | String | Path to SSL key file |

#### Examples

```bash
# Start with default settings
uv run langflow run

# Start on custom port and host
uv run langflow run --port 8080 --host 0.0.0.0

# Start with .env file
uv run langflow run --env-file /path/to/.env

# Start backend only (headless mode)
uv run langflow run --backend-only

# Start with multiple workers
uv run langflow run --workers 4 --worker-timeout 600

# Start with custom components
uv run langflow run --components-path /path/to/components

# Start with Redis cache
uv run langflow run --cache redis

# Start with debug logging
uv run langflow run --log-level debug

# Start with SSL
uv run langflow run --ssl-cert-file-path /path/to/cert.pem --ssl-key-file-path /path/to/key.pem
```

---

### langflow superuser

Creates a superuser account with the specified username and password.

```bash
uv run langflow superuser --username [NAME] --password [PASSWORD] [OPTIONS]
```

#### Options

| Option | Default | Type | Description |
|--------|---------|------|-------------|
| `--username` | Required | String | Superuser username |
| `--password` | Required | String | Superuser password |
| `--log-level` | `error` | String | Logging level: `debug`, `info`, `warning`, `error`, `critical` |

#### Example

```bash
uv run langflow superuser --username admin --password securepassword123
```

#### Notes

- The `--username` and `--password` options are required
- This command is controlled by `LANGFLOW_ENABLE_SUPERUSER_CLI` environment variable
- Set `LANGFLOW_ENABLE_SUPERUSER_CLI=False` in production to prevent unauthorized superuser creation

---

### langflow migration

Manages Langflow database schema changes using Alembic.

```bash
# Test mode (default) - preview changes without applying
uv run langflow migration

# Fix mode - apply migrations
uv run langflow migration --fix
```

#### Modes

| Mode | Description |
|------|-------------|
| Test (default) | Checks if migrations can be applied safely without running them |
| Fix (`--fix`) | Applies the migrations to update the database schema |

#### Warning

`langflow migration --fix` is a destructive operation that can delete data. Always run `langflow migration` first to preview the changes.

---

### langflow api-key

Creates a Langflow API key. You must be a superuser to create API keys with the CLI.

```bash
uv run langflow api-key [OPTIONS]
```

#### Options

| Option | Default | Type | Description |
|--------|---------|------|-------------|
| `--log-level` | `error` | String | Logging level: `debug`, `info`, `warning`, `error`, `critical` |

#### Notes

- All API keys created with the CLI have superuser privileges
- Required when running in `--backend-only` mode (no frontend to create keys)
- API keys adopt the privileges of the user who created them

---

### langflow copy-db

Copies Langflow database files from the cache directory to the Langflow installation directory.

```bash
uv run langflow copy-db
```

#### Files Copied

- `langflow.db`: Main Langflow database
- `langflow-pre.db`: Pre-release database (if exists)

---

## Environment Variables

Environment variables configure how Langflow runs. CLI options override environment variables set in your terminal or `.env` file.

### Precedence Order

1. **CLI options** (highest priority)
2. **`.env` file**
3. **System environment variables** (lowest priority)

---

### Server Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LANGFLOW_HOST` | `localhost` | Host on which the server runs |
| `LANGFLOW_PORT` | `7860` | Port on which the server runs |
| `LANGFLOW_WORKERS` | `1` | Number of worker processes |
| `LANGFLOW_WORKER_TIMEOUT` | `300` | Worker timeout in seconds |
| `LANGFLOW_BACKEND_ONLY` | `False` | Run only the backend service |
| `LANGFLOW_DEV` | `False` | Run in development mode |
| `LANGFLOW_OPEN_BROWSER` | `False` | Open browser on startup |
| `LANGFLOW_HEALTH_CHECK_MAX_RETRIES` | `5` | Max retries for health checks |
| `LANGFLOW_SSL_CERT_FILE` | Not set | Path to SSL certificate file |
| `LANGFLOW_SSL_KEY_FILE` | Not set | Path to SSL key file |
| `LANGFLOW_COMPONENTS_PATH` | Not set | Path to custom components directory |
| `LANGFLOW_FRONTEND_PATH` | Not set | Path to frontend build files |
| `LANGFLOW_DEACTIVATE_TRACING` | `False` | Deactivate tracing functionality |
| `LANGFLOW_CELERY_ENABLED` | `False` | Enable Celery for distributed processing |

---

### Authentication and Security

| Variable | Default | Description |
|----------|---------|-------------|
| `LANGFLOW_AUTO_LOGIN` | `True` | Auto-login all users as superusers (disable for production) |
| `LANGFLOW_SUPERUSER` | `langflow` | Superuser username (required if `AUTO_LOGIN=False`) |
| `LANGFLOW_SUPERUSER_PASSWORD` | `langflow` | Superuser password (required if `AUTO_LOGIN=False`) |
| `LANGFLOW_SECRET_KEY` | Auto-generated | Secret key for encrypting sensitive data |
| `LANGFLOW_ENABLE_SUPERUSER_CLI` | `True` | Enable `langflow superuser` CLI command |
| `LANGFLOW_NEW_USER_IS_ACTIVE` | `False` | Auto-activate new user accounts |
| `LANGFLOW_REMOVE_API_KEYS` | `False` | Remove API keys from saved flows |
| `LANGFLOW_API_KEY_SOURCE` | `db` | API key validation source: `db` or `env` |
| `LANGFLOW_API_KEY` | Not set | API key (when `API_KEY_SOURCE=env`) |
| `LANGFLOW_SKIP_AUTH_AUTO_LOGIN` | `False` | Skip API authentication when auto-login is enabled |
| `LANGFLOW_DISABLE_TRACK_APIKEY_USAGE` | `False` | Disable API key usage tracking |
| `LANGFLOW_WEBHOOK_AUTH_ENABLE` | `False` | Require authentication for webhooks |

---

### Database Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LANGFLOW_DATABASE_URL` | `sqlite:///./langflow.db` | Database connection URL |
| `LANGFLOW_CONFIG_DIR` | Not set | Directory for files, logs, and database |
| `LANGFLOW_SAVE_DB_IN_CONFIG_DIR` | `False` | Save database in config directory |
| `LANGFLOW_DATABASE_CONNECTION_RETRY` | `False` | Retry database connection on failure |
| `LANGFLOW_ALEMBIC_LOG_TO_STDOUT` | `False` | Log Alembic output to stdout |

#### Database URL Examples

```bash
# SQLite (default)
LANGFLOW_DATABASE_URL=sqlite:///./langflow.db

# PostgreSQL
LANGFLOW_DATABASE_URL=postgresql://user:password@localhost:5432/langflow

# PostgreSQL with SSL
LANGFLOW_DATABASE_URL=postgresql://user:password@localhost:5432/langflow?sslmode=require
```

---

### Cache Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LANGFLOW_CACHE_TYPE` | `async` | Cache type: `async`, `memory`, `redis`, `disk` |
| `LANGFLOW_LANGCHAIN_CACHE` | `InMemoryCache` | LangChain cache implementation |
| `LANGFLOW_REDIS_HOST` | `localhost` | Redis host (when using Redis cache) |
| `LANGFLOW_REDIS_PORT` | `6379` | Redis port |
| `LANGFLOW_REDIS_DB` | `0` | Redis database number |
| `LANGFLOW_REDIS_CACHE_EXPIRE` | `3600` | Redis cache expiration in seconds |

---

### Visual Editor and Playground

| Variable | Default | Description |
|----------|---------|-------------|
| `LANGFLOW_AUTO_SAVING` | `True` | Enable flow auto-saving |
| `LANGFLOW_AUTO_SAVING_INTERVAL` | `1000` | Auto-save interval in milliseconds |
| `LANGFLOW_LOAD_FLOWS_PATH` | Not set | Path to flow JSON files to load on startup |
| `LANGFLOW_BUNDLE_URLS` | `[]` | URLs for custom bundles |
| `LANGFLOW_CREATE_STARTER_PROJECTS` | `True` | Create templates during initialization |
| `LANGFLOW_UPDATE_STARTER_PROJECTS` | `True` | Update templates on upgrade |
| `LANGFLOW_LAZY_LOAD_COMPONENTS` | `False` | Load components on demand |
| `LANGFLOW_MAX_FILE_SIZE_UPLOAD` | `1024` | Max file upload size in MB |
| `LANGFLOW_MAX_ITEMS_LENGTH` | `100` | Max items displayed in editor |
| `LANGFLOW_MAX_TEXT_LENGTH` | `1000` | Max characters displayed in editor |
| `LANGFLOW_MAX_TRANSACTIONS_TO_KEEP` | `3000` | Max transaction events in database |
| `LANGFLOW_MAX_VERTEX_BUILDS_TO_KEEP` | `3000` | Max vertex builds in database |
| `LANGFLOW_MAX_VERTEX_BUILDS_PER_VERTEX` | `2` | Max builds per vertex |
| `LANGFLOW_EVENT_DELIVERY` | `streaming` | Event delivery method: `polling`, `streaming`, `direct` |

---

### Logging

| Variable | Default | Description |
|----------|---------|-------------|
| `LANGFLOW_LOG_LEVEL` | `critical` | Logging level |
| `LANGFLOW_LOG_FILE` | `logs/langflow.log` | Path to log file |
| `LANGFLOW_LOG_ROTATION` | Not set | Log rotation interval (e.g., `10 MB`, `1 day`) |
| `LANGFLOW_LOG_ENV` | Not set | Log environment format |

---

### CORS Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LANGFLOW_CORS_ORIGINS` | `*` | Allowed CORS origins (comma-separated or `*`) |
| `LANGFLOW_CORS_ALLOW_CREDENTIALS` | `True` | Allow credentials in CORS requests |
| `LANGFLOW_CORS_ALLOW_HEADERS` | `*` | Allowed headers for CORS |
| `LANGFLOW_CORS_ALLOW_METHODS` | `*` | Allowed HTTP methods for CORS |

#### Production CORS Example

```bash
LANGFLOW_CORS_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
LANGFLOW_CORS_ALLOW_CREDENTIALS=True
LANGFLOW_CORS_ALLOW_HEADERS=Content-Type,Authorization
LANGFLOW_CORS_ALLOW_METHODS=GET,POST,PUT
```

---

### SSRF Protection

| Variable | Default | Description |
|----------|---------|-------------|
| `LANGFLOW_SSRF_PROTECTION_ENABLED` | `False` | Enable SSRF protection |
| `LANGFLOW_SSRF_ALLOWED_HOSTS` | Not set | Allowed hosts to bypass SSRF checks |

---

### Telemetry

| Variable | Default | Description |
|----------|---------|-------------|
| `DO_NOT_TRACK` | `False` | Disable telemetry |

---

## Configuration File Examples

### Basic .env File

```bash
# Server configuration
LANGFLOW_HOST=localhost
LANGFLOW_PORT=7860
LANGFLOW_WORKERS=1

# Disable auto-login for security
LANGFLOW_AUTO_LOGIN=False
LANGFLOW_SUPERUSER=admin
LANGFLOW_SUPERUSER_PASSWORD=securepassword123

# Database
LANGFLOW_DATABASE_URL=sqlite:///./langflow.db

# Logging
LANGFLOW_LOG_LEVEL=info
```

### Production .env File

```bash
# Server configuration
LANGFLOW_HOST=0.0.0.0
LANGFLOW_PORT=7860
LANGFLOW_WORKERS=4
LANGFLOW_WORKER_TIMEOUT=600

# Authentication (required for production)
LANGFLOW_AUTO_LOGIN=False
LANGFLOW_SUPERUSER=administrator
LANGFLOW_SUPERUSER_PASSWORD=your-secure-password-here
LANGFLOW_SECRET_KEY=your-generated-secret-key
LANGFLOW_NEW_USER_IS_ACTIVE=False
LANGFLOW_ENABLE_SUPERUSER_CLI=False

# PostgreSQL database
LANGFLOW_DATABASE_URL=postgresql://langflow:password@localhost:5432/langflow
LANGFLOW_SAVE_DB_IN_CONFIG_DIR=True
LANGFLOW_CONFIG_DIR=/var/lib/langflow

# Cache
LANGFLOW_CACHE_TYPE=redis
LANGFLOW_REDIS_HOST=localhost
LANGFLOW_REDIS_PORT=6379

# Logging
LANGFLOW_LOG_LEVEL=warning
LANGFLOW_LOG_FILE=/var/log/langflow/langflow.log
LANGFLOW_LOG_ROTATION=10 MB

# Security
LANGFLOW_REMOVE_API_KEYS=True
LANGFLOW_CORS_ORIGINS=https://yourdomain.com

# Telemetry
DO_NOT_TRACK=True
```

### Development .env File

```bash
# Development settings
LANGFLOW_DEV=True
LANGFLOW_AUTO_LOGIN=True
LANGFLOW_LOG_LEVEL=debug
LANGFLOW_OPEN_BROWSER=True
LANGFLOW_AUTO_SAVING=True
LANGFLOW_AUTO_SAVING_INTERVAL=500

# Local database
LANGFLOW_DATABASE_URL=sqlite:///./langflow-dev.db

# Custom components
LANGFLOW_COMPONENTS_PATH=/path/to/my/components
```

---

## Docker Usage

### Quick Start

```bash
# Run with default settings
docker run -p 7860:7860 langflowai/langflow:latest

# Run with environment variables
docker run -p 7860:7860 \
  -e LANGFLOW_AUTO_LOGIN=False \
  -e LANGFLOW_SUPERUSER=admin \
  -e LANGFLOW_SUPERUSER_PASSWORD=securepass \
  langflowai/langflow:latest

# Run with .env file
docker run -p 7860:7860 \
  --env-file .env \
  langflowai/langflow:latest

# Run with persistent volume
docker run -p 7860:7860 \
  -v langflow_data:/app/langflow \
  -e LANGFLOW_CONFIG_DIR=/app/langflow \
  langflowai/langflow:latest
```

### Docker Compose

#### Basic docker-compose.yml

```yaml
services:
  langflow:
    image: langflowai/langflow:latest
    ports:
      - "7860:7860"
    environment:
      - LANGFLOW_AUTO_LOGIN=False
      - LANGFLOW_SUPERUSER=admin
      - LANGFLOW_SUPERUSER_PASSWORD=${LANGFLOW_SUPERUSER_PASSWORD}
      - LANGFLOW_SECRET_KEY=${LANGFLOW_SECRET_KEY}
    volumes:
      - langflow_data:/app/langflow

volumes:
  langflow_data:
```

#### Production docker-compose.yml with PostgreSQL

```yaml
services:
  langflow:
    image: langflowai/langflow:latest
    ports:
      - "7860:7860"
    environment:
      - LANGFLOW_DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      - LANGFLOW_CONFIG_DIR=/app/langflow
      - LANGFLOW_AUTO_LOGIN=False
      - LANGFLOW_SUPERUSER=${LANGFLOW_SUPERUSER}
      - LANGFLOW_SUPERUSER_PASSWORD=${LANGFLOW_SUPERUSER_PASSWORD}
      - LANGFLOW_SECRET_KEY=${LANGFLOW_SECRET_KEY}
    volumes:
      - langflow_data:/app/langflow
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped

  postgres:
    image: postgres:16
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  langflow_data:
  postgres_data:
```

#### Environment file for Docker Compose (.env)

```bash
# Database credentials
POSTGRES_USER=langflow
POSTGRES_PASSWORD=your-secure-db-password
POSTGRES_DB=langflow

# Langflow configuration
LANGFLOW_SUPERUSER=admin
LANGFLOW_SUPERUSER_PASSWORD=your-secure-admin-password
LANGFLOW_SECRET_KEY=your-generated-secret-key
```

### Building Custom Images

#### Dockerfile with Custom Flow

```dockerfile
FROM langflowai/langflow:latest
RUN mkdir /app/flows
COPY ./*.json /app/flows/
ENV LANGFLOW_LOAD_FLOWS_PATH=/app/flows
```

#### Dockerfile with Custom Components

```dockerfile
FROM langflowai/langflow:latest
WORKDIR /app
COPY ./my_components /app/custom_components
ENV LANGFLOW_COMPONENTS_PATH=/app/custom_components
EXPOSE 7860
CMD ["python", "-m", "langflow", "run", "--host", "0.0.0.0", "--port", "7860"]
```

### Kubernetes Deployment

#### API Key Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: langflow-secrets
type: Opaque
stringData:
  api-key: "your-api-key"
  secret-key: "your-secret-key"
  superuser-password: "your-admin-password"
```

#### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: langflow
spec:
  replicas: 1
  selector:
    matchLabels:
      app: langflow
  template:
    metadata:
      labels:
        app: langflow
    spec:
      containers:
      - name: langflow
        image: langflowai/langflow:latest
        ports:
        - containerPort: 7860
        env:
        - name: LANGFLOW_HOST
          value: "0.0.0.0"
        - name: LANGFLOW_PORT
          value: "7860"
        - name: LANGFLOW_AUTO_LOGIN
          value: "False"
        - name: LANGFLOW_API_KEY_SOURCE
          value: "env"
        - name: LANGFLOW_API_KEY
          valueFrom:
            secretKeyRef:
              name: langflow-secrets
              key: api-key
        - name: LANGFLOW_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: langflow-secrets
              key: secret-key
        - name: LANGFLOW_SUPERUSER_PASSWORD
          valueFrom:
            secretKeyRef:
              name: langflow-secrets
              key: superuser-password
```

---

## Generating Secret Keys

Generate a secure secret key for `LANGFLOW_SECRET_KEY`:

```bash
# macOS (copy to clipboard)
python3 -c "from secrets import token_urlsafe; print(f'LANGFLOW_SECRET_KEY={token_urlsafe(32)}')" | pbcopy

# Linux (copy to clipboard)
python3 -c "from secrets import token_urlsafe; print(f'LANGFLOW_SECRET_KEY={token_urlsafe(32)}')" | xclip -selection clipboard

# Print to terminal
python3 -c "from secrets import token_urlsafe; print(f'LANGFLOW_SECRET_KEY={token_urlsafe(32)}')"
```

---

## Common Use Cases

### Starting Langflow with Authentication

```bash
# Create .env file
cat > .env << EOF
LANGFLOW_AUTO_LOGIN=False
LANGFLOW_SUPERUSER=admin
LANGFLOW_SUPERUSER_PASSWORD=securepass123
LANGFLOW_SECRET_KEY=$(python3 -c "from secrets import token_urlsafe; print(token_urlsafe(32))")
EOF

# Start Langflow
uv run langflow run --env-file .env
```

### Running in Backend-Only Mode

```bash
# Start without frontend
uv run langflow run --backend-only --port 7860

# Create API key for authentication
uv run langflow api-key
```

### Connecting to External PostgreSQL

```bash
# Set database URL
export LANGFLOW_DATABASE_URL="postgresql://user:password@db.example.com:5432/langflow"

# Run migrations
uv run langflow migration --fix

# Start Langflow
uv run langflow run
```

---

## Troubleshooting

### Port Already in Use

Langflow automatically selects a free port if the specified port is in use. To force a specific port:

```bash
# Kill process using port 7860
lsof -ti:7860 | xargs kill -9

# Start Langflow
uv run langflow run --port 7860
```

### Database Migration Issues

```bash
# Preview migration changes
uv run langflow migration

# Apply migrations (destructive)
uv run langflow migration --fix

# If issues persist, backup and reset database
cp langflow.db langflow.db.backup
rm langflow.db
uv run langflow run
```

### Authentication Issues

```bash
# Reset superuser password
uv run langflow superuser --username admin --password newpassword

# Verify authentication is disabled for testing
LANGFLOW_AUTO_LOGIN=True uv run langflow run
```
