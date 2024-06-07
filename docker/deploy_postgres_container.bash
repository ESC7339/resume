#!/bin/bash


#preflight 
install_docker() {
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common




    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
}






install_docker_compose() {
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}




###
# generate docker-compose file, credentials to be stored in envvars at a minimum
###


create_docker_compose_file() {
    echo "Creating Docker Compose file..."
    cat << 'EOF' > docker-compose.yml
version: '3.1'

services:
  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_USER: example
      POSTGRES_PASSWORD: example
      POSTGRES_DB: exampledb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF
}


deploy_postgres() {
    echo "Deploying PostgreSQL with Docker Compose..."
    sudo docker-compose up -d
}


echo "Starting deployment of PostgreSQL instance."


if ! [ -x "$(command -v docker)" ]; then
    install_docker
else
    echo "Docker is already installed."
fi





if ! [ -x "$(command -v docker-compose)" ]; then
    install_docker_compose
else
    echo "Docker Compose is already installed."
fi



# Create Docker Compose file and deploy PostgreSQL
create_docker_compose_file
deploy_postgres


