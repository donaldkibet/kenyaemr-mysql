# KenyaEMR 03 Pre-filled MySQL Docker Image

A MySQL 8.0 Docker image configured for KenyaEMR with automatic initialization of ETL databases and SQL dumps.

## Overview

This repository builds a MySQL container image that:
- Uses MySQL 8.0 as the base image
- Automatically creates KenyaEMR ETL databases on first run
- Supports importing SQL dumps from Google Drive
- Includes health checks for monitoring

## Nightly Builds

The Docker image is automatically built and published nightly via GitHub Actions. The workflow:
1. Downloads the latest SQL dump from Google Drive
2. Builds the Docker image with the downloaded dump
3. Publishes to Docker Hub with tags:
   - `nightly` - Latest nightly build
   - `nightly-YYYYMMDD` - Date-stamped build
   - `YYYYMMDD-{sha}` - Date-stamped with commit SHA

## Setup

### GitHub Secrets Configuration

To enable the nightly build workflow, configure the following GitHub secrets in your repository settings:

1. **GOOGLE_DRIVE_FILE_URL**: The Google Drive file URL for the SQL dump
   - How to get it: Open the file in Google Drive, share it with "Anyone with the link can view", and copy the full share link
   - Example: `https://drive.google.com/file/d/1ABC123xyz789/view?usp=sharing`
   - Or use the direct download URL format: `https://drive.google.com/uc?export=download&id=1ABC123xyz789`

2. **DOCKERHUB_USERNAME**: Your Docker Hub username

3. **DOCKERHUB_TOKEN**: Docker Hub access token
   - Generate one at: https://hub.docker.com/settings/security

The Docker image will be published as `{DOCKERHUB_USERNAME}/kenyaemr-mysql:8.0` with tags:
- `nightly` - Latest nightly build
- `nightly-YYYYMMDD` - Date-stamped build
- `YYYYMMDD-{sha}` - Date-stamped with commit SHA

### Local Development

1. **Set up environment variables** (optional):
   ```bash
   cp .env.example .env
   # Edit .env with your preferred values
   ```

2. **Build the image locally**:
   ```bash
   docker build -t kenyaemr-mysql:local .
   ```

3. **Run the container with environment file**:
   ```bash
   docker run -d \
     --name kenyaemr-mysql \
     -p 3306:3306 \
     --env-file .env \
     kenyaemr-mysql:local
   ```

   Or run with explicit environment variables:
   ```bash
   docker run -d \
     --name kenyaemr-mysql \
     -p 3306:3306 \
     -e MYSQL_ROOT_PASSWORD=your_root_password \
     -e MYSQL_DATABASE=openmrs \
     -e MYSQL_USER=openmrs \
     -e MYSQL_PASSWORD=openmrs \
     kenyaemr-mysql:local
   ```

## Environment Variables

- `MYSQL_DATABASE`: Database name (default: `openmrs`)
- `MYSQL_USER`: MySQL user (default: `openmrs`)
- `MYSQL_PASSWORD`: MySQL password (default: `openmrs`)
- `MYSQL_ROOT_PASSWORD`: Root password (default: `openmrs`)

## Database Initialization

On first startup, the container will:
1. Create the main OpenMRS database
2. Create ETL-related databases:
   - `kenyaemr_etl`
   - `kenyaemr_datatools`
   - `dwapi_etl`
3. Grant the OpenMRS user access to all ETL databases
4. Import any SQL dump files from `init-scripts/`

## Health Check

The image includes a health check that runs every 30 seconds:
```sql
mysqladmin ping -h 127.0.0.1 -u"${MYSQL_USER:-root}" -p"${MYSQL_PASSWORD}"
```


