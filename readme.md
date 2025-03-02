# Prerequisites

Before running this project, you'll need to have the following tools installed:

## 1. Docker Desktop

Docker Desktop is required to run the containerized database locally.

### Installation

- **Mac**: [Download Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)
- **Windows**: [Download Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
- **Linux**: Follow the [Docker Engine installation instructions](https://docs.docker.com/engine/install/)

After installation, make sure to **start the Docker Desktop application** before running any scripts.

## 2. PostgreSQL Client (psql)

The PostgreSQL client tools are needed to interact with the database.

### Installation

- **Mac**:
  ```bash
  brew install postgresql
  ```
- **Windows**:
  - Download the installer from [PostgreSQL Downloads](https://www.postgresql.org/download/windows/)
  - During installation, only the "Command Line Tools" are required
- **Linux**:
  ```bash
  sudo apt-get install postgresql-client  # Ubuntu/Debian
  sudo yum install postgresql            # RHEL/CentOS
  ```

## Run the project locally

1. Start the Docker container:
   ```bash
   ./run_local.sh
   ```
