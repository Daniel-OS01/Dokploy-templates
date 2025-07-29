# System Prompt Instructions for Adapting Docker Compose to Dokploy Templates

This document provides instructions for an AI LLM on how to adapt any `docker-compose.yml` file to the Dokploy template structure.

## 1. Understand the Goal

The primary goal is to convert a standard `docker-compose.yml` file into a Dokploy template, which consists of a `docker-compose.yml` file and a `template.yml` file. The `template.yml` file provides metadata and configuration options for the template.

## 2. Analyze the `docker-compose.yml` File

- **Services**: Identify all the services defined in the `docker-compose.yml` file.
- **Images**: Note the image used for each service.
- **Ports**: Identify the port mappings for each service.
- **Volumes**: Identify the volume mappings for each service.
- **Environment Variables**: Identify the environment variables for each service.
- **Dependencies**: Note any dependencies between services (`depends_on`).
- **Commands**: Note any custom commands (`command`).

## 3. Create the `template.yml` File

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

### 3.1. `name`, `description`, and `logo`

- **`name`**: A user-friendly name for the template (e.g., "WordPress", "Ghost").
- **`description`**: A brief, user-friendly description of the application.
- **`logo`**: The filename of the logo image (e.g., `logo.png`, `logo.svg`).

### 3.2. `services`

- For each service in the `docker-compose.yml` file, create a corresponding entry under `services` in the `template.yml` file.
- The service name in `template.yml` **must** match the service name in `docker-compose.yml`.
- Include the following information for each service, if applicable:
    - `image`: The Docker image.
    - `command`: The command to run.
    - `volumes`: The volume mappings.
    - `ports`: The port mappings.
    - `depends_on`: The service dependencies.

### 3.3. `variables`

- Identify which environment variables in the `docker-compose.yml` file should be user-configurable. These are typically things like database passwords, API keys, and domain names.
- For each configurable environment variable, create a corresponding entry under `variables` in the `template.yml` file.
- **`id`**: The name of the environment variable (e.g., `WORDPRESS_DB_PASSWORD`).
- **`label`**: A user-friendly label for the variable (e.g., "WordPress Database Password").
- **`defaultValue`**: A default value for the variable. You can use helpers like `${password:16}` to generate a random password.

### 3.4. `notes`

- Provide any important information or instructions for the user in the `notes` section. This could include:
    - Default login credentials.
    - Links to documentation.
    - Any post-installation steps.

## 4. Review and Refine

- **Consistency**: Ensure that service names, volume names, and environment variable names are consistent between the `docker-compose.yml` and `template.yml` files.
- **Clarity**: The `template.yml` file should be easy for users to understand and configure. Use clear and descriptive labels for variables.
- **Simplicity**: Only expose the most important and frequently changed options as variables. Avoid overwhelming the user with too many choices.
- **Security**: Use secure defaults for passwords and other sensitive information. Use helpers like `${password:16}` to generate random values.
- **Best Practices**: Follow the general suggestions in the main `README.md` file, such as not using `container_name` or `dokploy-network`.

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
    image: mysql:8.0
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${WORDPRESS_DB_PASSWORD}
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - 80
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}
      WORDPRESS_DB_NAME: wordpress
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
    image: mysql:8.0
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
