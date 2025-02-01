#!/bin/bash

# Function to check if Docker is running
check_docker() {
  if ! docker info &>/dev/null; then
    echo "Docker is not running. Please start the Docker daemon and try again."
    exit 1
  fi
}

# Function to delete a single volume
delete_volume() {
  local volume_name=$1
  if docker volume inspect "$volume_name" &>/dev/null; then
    echo "Deleting volume: $volume_name"
    docker volume rm "$volume_name"
    if [ $? -eq 0 ]; then
      echo "Volume $volume_name deleted successfully."
    else
      echo "Failed to delete volume $volume_name."
    fi
  else
    echo "Volume $volume_name does not exist."
  fi
}

# Ensure Docker is running before proceeding
check_docker

# If no arguments are passed
if [ $# -eq 0 ]; then
  echo "WARNING: This will delete all Docker volumes."
  read -p "Are you sure you want to proceed? (y/N): " confirm

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Deleting all Docker volumes..."
    docker volume prune -f
    if [ $? -eq 0 ]; then
      echo "All unused Docker volumes have been deleted."
    else
      echo "Failed to prune volumes."
    fi
  else
    echo "Operation cancelled."
  fi

# If arguments are passed
else
  for volume in "$@"; do
    delete_volume "$volume"
  done
fi
