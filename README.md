<div align="center">
    <h1><b>Docmost</b></h1>
    <p>
        Open-source collaborative wiki and documentation software.
        <br />
        <a href="https://docmost.com"><strong>Website</strong></a> | 
        <a href="https://docmost.com/docs"><strong>Documentation</strong></a> |
        <a href="https://twitter.com/DocmostHQ"><strong>Twitter / X</strong></a>
    </p>
</div>
<br />

## Getting started

To get started with Docmost, please refer to our [documentation](https://docmost.com/docs) or try our [cloud version](https://docmost.com/pricing) .

## Features

- Real-time collaboration
- Diagrams (Draw.io, Excalidraw and Mermaid)
- Spaces
- Permissions management
- Groups
- Comments
- Page history
- Search
- File attachments
- Embeds (Airtable, Loom, Miro and more)
- Translations (10+ languages)

### Screenshots

<p align="center">
<img alt="home" src="https://docmost.com/screenshots/home.png" width="70%">
<img alt="editor" src="https://docmost.com/screenshots/editor.png" width="70%">
</p>

### License
Docmost core is licensed under the open-source AGPL 3.0 license.  
Enterprise features are available under an enterprise license (Enterprise Edition).  

All files in the following directories are licensed under the Docmost Enterprise license defined in `packages/ee/License`.
  - apps/server/src/ee
  - apps/client/src/ee
  - packages/ee

### Contributing

See the [development documentation](https://docmost.com/docs/self-hosting/development)

## Thanks
Special thanks to;

<img width="100" alt="Crowdin" src="https://github.com/user-attachments/assets/a6c3d352-e41b-448d-b6cd-3fbca3109f07" />

[Crowdin](https://crowdin.com/) for providing access to their localization platform.


<img width="48" alt="Algolia-mark-square-white" src="https://github.com/user-attachments/assets/6ccad04a-9589-4965-b6a1-d5cb1f4f9e94" />

[Algolia](https://www.algolia.com/) for providing full-text search to the docs.

## KTH DevOps Course Project

This section describes the DevOps work we added to Docmost for the KTH DevOps course. We use the existing Docmost application and Dockerfile, and focus on automating testing, image building, and deployment to AWS.

Our main changes are in:

- `.github/workflows/ci-cd.yml` — CI/CD pipeline
- `infra/` — Terraform configuration
- `docker-compose.yml` — Container configuration
- `scripts/deploy.sh` — Deployment script

### Infrastructure

We deploy Docmost on a single AWS EC2 instance using Docker Compose. Docmost, PostgreSQL, and Redis run on the same instance, with persistent data stored on a separate encrypted EBS volume.

Route 53 directs traffic for `docmost.click` to an Application Load Balancer, which handles HTTPS and forwards requests to the EC2 instance over HTTP.

The infrastructure is managed with Terraform, using the `docmost-prod` workspace in Terraform Cloud.

### Setup

The following are required before deployment:

- An AWS account with an existing public Route 53 hosted zone for `docmost.click`.
- Access to the Terraform Cloud organization `docmost-devops` and workspace `docmost-prod` under the `Docmost` project.
- AWS credentials available to the Terraform execution environment.
- Two parameters in AWS Systems Manager Parameter Store (`eu-north-1`):
  - `/docmost/app-secret`
  - `/docmost/db-password`

The two parameters must be created manually, preferably as `SecureString`. Their values should not be committed to the repository.

To provision the infrastructure, go to the `infra/` directory and run:

1. `terraform init`
2. `terraform plan`
3. `terraform apply`

After applying Terraform, set the GitHub Actions repository variable `AWS_DEPLOY_ROLE_ARN` to the value of the `github_actions_deploy_role_arn` Terraform output.

### CI/CD

The pipeline is defined in `.github/workflows/ci-cd.yml`.

For pull requests, GitHub Actions runs the frontend tests, selected backend tests, application build, Docker image build, and Trivy vulnerability scan.

When changes are pushed to `main`, the Docker image is also published to GHCR with the commit SHA as its tag. The deployment job runs only after both CI jobs have succeeded.

GitHub Actions uses OIDC to assume an AWS IAM role and sends a deployment command to the EC2 instance through AWS Systems Manager.

The deployment script downloads the Docker Compose configuration from the same commit, retrieves the application secrets from Parameter Store, and updates the containers using Docker Compose.

Infrastructure changes are applied separately through Terraform.

### Verification

CI/CD results can be checked in the repository's GitHub Actions tab.

The application can be checked at https://docmost.click. The `/api/health` endpoint checks the PostgreSQL and Redis connections.

The `.github/workflows/release.yml` file comes from the upstream Docmost project and is not part of our course deployment pipeline.