#!/bin/bash

# Function to check if Docker is running
check_docker() {
  if ! docker info &>/dev/null; then
    echo "Docker is not running. Please start the Docker daemon and try again."
    exit 1
  fi
}

# Function to delete all Docker containers, volumes, and data
delete_all_docker_data() {
  echo "WARNING: This will delete all Docker containers, volumes, networks, and images."
  read -p "Are you sure you want to proceed? (y/N): " confirm

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Stopping and deleting all Docker containers..."
    docker container stop $(docker container ls -aq) &>/dev/null
    docker container rm $(docker container ls -aq) &>/dev/null

    echo "Removing all Docker volumes..."
    docker volume rm $(docker volume ls -q) &>/dev/null

    echo "Removing all Docker networks..."
    docker network rm $(docker network ls -q) &>/dev/null

    echo "Removing all Docker images..."
    docker image rm $(docker image ls -aq) --force &>/dev/null

    echo "Pruning unused Docker data..."
    docker system prune -af --volumes &>/dev/null

    echo "All Docker containers, volumes, networks, and images have been deleted."
  else
    echo "Operation cancelled."
  fi
}

# Ensure Docker is running before proceeding
check_docker

# Execute the delete operation
delete_all_docker_data
