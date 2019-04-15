#!/bin/bash -e

# Create a random local ssh port for the container
export WEBPORT="$(((RANDOM % 10000)+ 50000))"
export DBPORT="$(((RANDOM % 10000)+ 51000))"

echo "**** Starting Drupal Trial Test Run with ephemeral data ****"
echo "     Using MYSQL PORT: %DBPORT%"
echo "     Using HTTP  URL : http://localhost:%WEBPORT%"

# Create a network
docker network create --subnet=10.8.8.0/16 drupalnet 2>/dev/null || true

# Run the container
docker run -it \
  --net drupalnet \
  -p %WEBPORT%:80 \
  -p %DBPORT%:3306 \
  ricardoamaro/drupal8
