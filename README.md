# Dokploy Open Source Templates

This is the official repository for creating Dokploy templates.

## Folder Structure

The repository is organized into two main folders:

-   `blueprints`: This folder contains examples of templates that you can use as a reference.
-   `templates`: This is where you should add your custom templates.

Each template has its own directory within the `templates` folder, and the directory name should be the name of the application (e.g., `wordpress`, `ghost`).

## How to Create a Dokploy Template: A Step-by-Step Guide

To create a new Dokploy template, follow these steps:

### Step 1: Create a New Template Directory

Create a new directory inside the `templates` folder. The name of the directory should be the name of the application you are creating a template for (e.g., `wordpress`).

### Step 2: Create the `docker-compose.yml` File

Inside your new template directory, create a `docker-compose.yml` file. This file should be optimized for Dokploy and follow these requirements:

-   **No `container_name`**: Remove all `container_name` properties.
-   **No explicit networks**: Do not define any networks (e.g., `dokploy-network`).
-   **Proper port exposure**: Use the format `"4000"` instead of `"4000:4000"`.
-   **`restart: unless-stopped`**: All services must have this restart policy.
-   **Use Alpine images**: Use Alpine-based images whenever possible.
-   **Add healthchecks**: Add a comprehensive healthcheck for every service.

### Step 3: Create the `template.yml` File

Create a `template.yml` file in the same directory. This file contains the metadata for your template.

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

### Step 4: Create the `template.toml` File

Create a `template.toml` file in the same directory. This file defines the variables and configuration for your template.

```toml
[variables]
main_domain = "${domain}"
postgres_password = "${password:32}"

[config]
[[config.domains]]
serviceName = "litellm"
port = 4000
host = "${main_domain}"

[[config.env]]
serviceName = "db"
env = [
    "POSTGRES_PASSWORD=${postgres_password}"
]
```

### Step 5: Generate the Base64-Encoded `template.toml`

Encode the `template.toml` file in Base64. You can use the following command:

```bash
cat template.toml | base64
```

### Step 6: Create the Default Compose Command

Create a single-line bash command that does the following:

-   Exports all necessary environment variables with demo values.
-   Validates the `docker-compose.yml` file using `docker compose config`.
-   Starts the services using `docker compose up -d`.
-   Verifies the status of the services using `docker compose ps`.

**Example:**

```bash
export MAIN_DOMAIN="servicename.example.com" REDIS_PASSWORD="$(openssl rand -base64 24)" && docker compose --file docker-compose.yml config && docker compose up -d && docker compose ps
```

### Step 7: Add a Logo

Add a logo for your application to the template directory. The logo should be referenced in the `template.yml` file.

### Step 8: Create a Pull Request

Once you have created all the necessary files, create a pull request to have your template reviewed and added to the repository.