:: Create a random local ports for the container
@SET /a "WEBPORT = %RANDOM% * (50000 - 10000 + 1) / 32768 + 10000"
@SET /a "DBPORT = %RANDOM% * (50000 - 10000 + 1) / 32768 + 10000"

echo **** Starting Drupal Trial Test Run with ephemeral data ****
echo      Using MYSQL PORT: %DBPORT%
echo      Using HTTP  URL : http://localhost:%WEBPORT%

:: Create a network
:: docker network create --subnet=10.8.8.0/16 drupalnet

:: Run the container
docker run -it -p ${WEBPORT}:80 -p ${DBPORT}:3306 ricardoamaro/drupal8