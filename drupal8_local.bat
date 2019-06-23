:: Note: LOCAL can be something else for several sites running from the console
:: eg. drupal8_local.bat LOCAL
@echo off

mkdir %1%\web 
mkdir %1%\data

:: Create a random LOCAL ports for the container
@SET /a "WEBPORT = %RANDOM% * (50000 - 10000 + 1) / 32768 + 10000"
@SET /a "DBPORT = %RANDOM% * (50000 - 10000 + 1) / 32768 + 10000"

echo **** Starting Drupal using persistence on %1%/ folder ****
echo      Using MYSQL PORT: %DBPORT%
echo      Using HTTP  URL : http://localhost:%WEBPORT%

:: Create a network
:: docker network create --subnet=10.8.8.0/16 drupalnet

:: Run the container
docker run -it --volume=%cd%\%1\data:/var/lib/mysql --volume=%cd%\%1:/var/www/html -p %WEBPORT%:80 -p %DBPORT%:3306 ricardoamaro/drupal8

