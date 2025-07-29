# System Prompt Instructions for Adapting Docker Compose to Dokploy Templates

This document provides instructions for an AI LLM on how to adapt any `docker-compose.yml` file to the Dokploy template structure.

## 1. Understand the Goal

The primary goal is to convert a standard `docker-compose.yml` file into a Dokploy template, which consists of four outputs:

1.  **Docker Compose File**: A `docker-compose.yml` file optimized for Dokploy.
2.  **Default Compose Command**: A single-line bash command to set up and run the template.
3.  **Template Configuration (Base64)**: A Base64-encoded `template.toml` file.
4.  **`template.yml`**: A YAML file containing the template's metadata.

## 2. Analyze the `docker-compose.yml` File

- **Services**: Identify all the services defined in the `docker-compose.yml` file.
- **Images**: Note the image used for each service.
- **Ports**: Identify the port mappings for each service.
- **Volumes**: Identify the volume mappings for each service.
- **Environment Variables**: Identify the environment variables for each service.
- **Dependencies**: Note any dependencies between services (`depends_on`).
- **Commands**: Note any custom commands (`command`).
- **Healthchecks**: Add a comprehensive healthcheck for every service.

## 3. Create the Dokploy Template Files

### 3.1. `docker-compose.yml`

-   **No `container_name`**: Remove all `container_name` properties.
-   **No explicit networks**: Do not define any networks (e.g., `dokploy-network`).
-   **Proper port exposure**: Use the format `"4000"` instead of `"4000:4000"`.
-   **`restart: unless-stopped`**: All services must have this restart policy.
-   **Use Alpine images**: Use Alpine-based images whenever possible.
-   **Add healthchecks**: Add a comprehensive healthcheck for every service.

### 3.2. `template.yml`

Create a `template.yml` file with the following structure:

```yaml
name: <template_name>
description: <template_description>
logo: <logo_filename>
services:
  <service_name_1>:
    # ...
  <service_name_2>:
    # ...
variables:
  - id: <variable_id>
    label: <variable_label>
    defaultValue: <variable_defaultValue>
notes: |
  - <note_1>
  - <note_2>
```

### 3.3. `template.toml`

Create a `template.toml` file with the following sections:

-   **`variables`**: Define all the variables used in the template.
-   **`config.domains`**: Define the domains for the services.
-   **`config.env`**: Define the environment variables for the services.
-   **`config.mounts`**: Define the volume mounts for the services.

### 3.4. Default Compose Command

Provide a single-line bash command that does the following:

-   Exports all necessary environment variables with demo values.
-   Validates the `docker-compose.yml` file using `docker compose config`.
-   Starts the services using `docker compose up -d`.
-   Verifies the status of the services using `docker compose ps`.

**Example:**

```bash
export MAIN_DOMAIN="servicename.example.com" REDIS_PASSWORD="$(openssl rand -base64 24)" && docker compose --file docker-compose.yml config && docker compose up -d && docker compose ps
```

## 4. Review and Refine

- **Consistency**: Ensure that service names, volume names, and environment variable names are consistent between the `docker-compose.yml`, `template.yml` and `template.toml` files.
- **Clarity**: The `template.yml` file should be easy for users to understand and configure. Use clear and descriptive labels for variables.
- **Simplicity**: Only expose the most important and frequently changed options as variables. Avoid overwhelming the user with too many choices.
- **Security**: Use secure defaults for passwords and other sensitive information. Use helpers like `${password:16}` to generate random values.
- **Best Practices**: Follow the general suggestions in the main `README.md` file.
- **Logo**: Ensure a logo is included for the template and referenced correctly in the `template.yml` file.
- **Service Names**: Make sure the service names in the `docker-compose.yml` file match the service names in the `template.yml` and `template.toml` files.

## Example: Converting a `docker-compose.yml` for WordPress

**Original `docker-compose.yml`:**

```yaml
version: '3.8'
services:
  db:
    image: mysql:8.0
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: not-a-secure-password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: not-a-secure-password
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - 8080:80
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: not-a-secure-password
      WORDPRESS_DB_NAME: wordpress
volumes:
    db_data: {}
```

**Adapted `docker-compose.yml`:**

```yaml
version: '3.8'
services:
  db:
    image: mysql:8.0-alpine
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${WORDPRESS_DB_PASSWORD}
    healthcheck:
      test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]
      timeout: 20s
      retries: 10
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - 80
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}
      WORDPRESS_DB_NAME: wordpress
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 5
volumes:
    db_data: {}
```

**New `template.yml`:**

```yaml
name: WordPress
description: "WordPress is a free and open-source content management system written in PHP and paired with a MySQL or MariaDB database."
logo: logo.svg
services:
  db:
    image: mysql:8.0-alpine
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - 80
variables:
  - id: MYSQL_ROOT_PASSWORD
    label: MySQL Root Password
    defaultValue: "${password:16}"
  - id: WORDPRESS_DB_PASSWORD
    label: WordPress Database Password
    defaultValue: "${password:16}"
notes: |
  - After installation, navigate to the provided URL to complete the WordPress setup.
  - The default database name is `wordpress` and the user is `wordpress`.
```

**New `template.toml`:**

```toml
[variables]
main_domain = "${domain}"
mysql_root_password = "${password:32}"
wordpress_db_password = "${password:32}"

[config]
[[config.domains]]
serviceName = "wordpress"
port = 80
host = "${main_domain}"

[[config.env]]
serviceName = "db"
env = [
    "MYSQL_ROOT_PASSWORD=${mysql_root_password}",
    "WORDPRESS_DB_PASSWORD=${wordpress_db_password}"
]
```

**Default Compose Command:**

```bash
export MAIN_DOMAIN="wordpress.example.com" MYSQL_ROOT_PASSWORD="$(openssl rand -base64 24)" WORDPRESS_DB_PASSWORD="$(openssl rand -base64 24)" && docker compose --file docker-compose.yml config && docker compose up -d && docker compose ps
```
