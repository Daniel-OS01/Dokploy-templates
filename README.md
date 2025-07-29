# Dokploy Open Source Templates

This is the official repository for the Dokploy Open Source Templates.

## How to add a new template

1. Fork the repository
2. Create a new branch
3. Add the template to the `templates` folder (`docker-compose.yml`, `template.toml` or `template.yml`)
4. Add the logo to the template folder
5. Commit and push your changes
6. Create a pull request (PR)
7. Every PR will automatically deploy a preview of the template to Dokploy.
8. if anyone want to test the template before merging it, you can enter to the preview URL in the PR description, and search the template, click on the Template Card, scroll down and then copy the BASE64 value, and paste in the advanced section of your compose service, in the Import section or optional you can use the preview URL and paste in the
BASE URL when creating a template.

The `blueprints` folder contains examples of templates that you can use as a reference. The `templates` folder is where you should add your custom templates.

### Example

Let's suppose you want to add the [Grafana](https://grafana.com/) template to the repository.

1. Create a new folder inside the `templates` folder named `grafana`
2. Add the `docker-compose.yml` file to the folder

```yaml
version: "3.8"
services:
  grafana:
    image: grafana/grafana-enterprise:9.5.20
    restart: unless-stopped
    volumes:
      - grafana-storage:/var/lib/grafana
volumes:
  grafana-storage: {}
```
3. Add the `template.yml` file to the folder.

```yaml
name: Grafana
description: "Grafana is an open source platform for data visualization and monitoring."
logo: grafana.svg
services:
  grafana:
    # container_name: grafana # Optional
    # depends_on: # Optional
    #   - another_service
    # command: # Optional
    #   - --config=/etc/grafana/grafana.ini
    # volumes: # Optional
    #   - ./grafana.ini:/etc/grafana/grafana.ini
    ports:
      - 3000:3000
variables: # Optional
  - id: GF_SECURITY_ADMIN_PASSWORD
    label: Admin Password
    defaultValue: "admin"
notes: | # Optional
  - The default username is `admin` and the password is the one you set in the variables.
  - For more information, visit the [Grafana website](https://grafana.com/).
```

4. Add the logo to the folder
5. Commit and push your changes
6. Create a pull request

### `template.yml` structure

Dokploy use a defined structure for the `template.yml` file, we have 4 sections available:

1. `name`: The name of the template.
2. `description`: A short description of the template.
3. `logo`: The path to the logo file.
4. `services`: This is where we define the configuration for the template.
5. `variables`: This is where we define the variables that will be used in the `services` section.
6. `notes`: This is where we define the notes for the template.

- The `services` structure is the following:

```yaml
services:
  grafana:
    image: grafana/grafana-enterprise:9.5.20
    # container_name: grafana # Optional
    # depends_on: # Optional
    #   - another_service
    # command: # Optional
    #   - --config=/etc/grafana/grafana.ini
    # volumes: # Optional
    #   - ./grafana.ini:/etc/grafana/grafana.ini
    ports:
      - 3000:3000
```

- The `variables` structure is the following:

```yaml
variables:
  - id: GF_SECURITY_ADMIN_PASSWORD
    label: Admin Password
    defaultValue: "admin"
```

- The `notes` structure is the following:

```yaml
notes: |
  - The default username is `admin` and the password is the one you set in the variables.
  - For more information, visit the [Grafana website](https://grafana.com/).
```

### General Suggestions when creating a template

- Don't use this way in your docker compose file:

```yaml
services:
  grafana:
    image: grafana/grafana-enterprise:9.5.20
    restart: unless-stopped
    ports:
      - 3000:3000

    # Instead use this way:
    ports:
      - 3000
```

- Don't use `container_name` in your docker compose file, make sure to use the same service name as the one in the `template.yml` file:

```yaml
services:
  grafana:
    container_name: grafana # ❌ Remove this
```

- Don't use `dokploy-network` in your docker compose file, by default all the templates have this flag enabled https://docs.dokploy.com/docs/core/docker-compose/utilities#isolated-deployments, so by default they have a internal network created, so you don't to create a new one or use the `dokploy-network` name.

```yaml
services:
  grafana:
    networks:
      - dokploy-network # ❌ Remove this or any other network defined
```


- Please before submit a PR, make sure to test the template in your instance, so the maintainers don't spend time trying to figure out what's wrong.

1. Everytime you submit a PR, it will display a Preview Link.
2. Enter to the Preview Link and search the template you've submitted.
3. Click on the Template Card, and click the Copy Button in the Base64 Configuration.
4. Go to your instance, create a new Compose Service, go to Advanced Section -> Scroll Down -> Import Section -> Paste the Base64 Value -> Click on the Import Button
5. If everything is correct and set, you should see a modal with all the details (Compose File, Environment Variables, Mounts, Domains, etc)
6. Now you can click on the Deploy Button and wait for the deployment to finish, and try to access to the service, if everything is correct you should access to the service and see the template working.