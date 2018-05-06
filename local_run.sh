#!/bin/bash -x

mkdir -p web data

echo "**** Starting Drupal on http://localhost:8080 ****"

# Create a network
docker network create --subnet=172.10.0.0/16 drupalnet || true

# Run the container
docker run -it \
--net drupalnet \
--volume=data:/var/lib/mysql \
--volume=web:/var/www/html \
-p 8080:80 ricardoamaro/drupal8
