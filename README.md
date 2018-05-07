drupal8-docker-app
====================

# What is this?

This repo contains a Docker recipe for making a container
running Drupal8, using Linux, Apache, MySQL, Memcache and SSH.
You can also use it on the Drupal Contribution Sprints for quickly starting
working on your Drupal8 project.
Note that, despite what other Docker solutions do, this will deliver you a fast, one-shot
container with all necessary services, thus avoiding the need of container orchestration
and the need of installing more software.

- To just Trial Drupal 8 please [Install Docker](https://docs.docker.com/installation/).

- To use this repository as development environment, on Linux, MacOSX or Win10 make sure both bash+docker are installed.

Feel free to test and report any issues.

# Quick 3 step instructions for a Drupal 8 Trial Run:

## 1 - Install docker:

https://docs.docker.com/installation/

## 2 - Get the image and run it using port 80:

Open a terminal and run

```
docker run -i -t -p 80:80 ricardoamaro/drupal8
```

That's it!

## 3 - Now visit [http://localhost/](http://localhost/) in your browser

using user/pass: admin/admin

## Extra - Manage MySQL in your browser

[http://localhost/adminer.php](http://localhost/adminer.php)

# COMMUNITY CONTRIBUTIONS

If you want **Code and Database persistence** with Drupal8 code
on the "local/web" folder and MySQL on the "local/data" folder:

```
git clone https://github.com/ricardoamaro/drupal8-docker-app.git
cd drupal8-docker-app
./drupal8_local.sh
```

## Using `drupal8_local.sh` for local development

### Fresh install

For a fresh install or re-install of your existing code

1. Remove the any local/data/ folder
2. Create a local/web/ folder with your Drupal 8 docroot
3. Delete the sites/default/settings.php file
4. Run `drupal8_local.sh`


### Credentials (will be shown in the output)
* Drupal account-name=admin & account-pass=admin
* ROOT SSH/MYSQL PASSWORD will be on $mysql/mysql-root-pw.txt
* DRUPAL   MYSQL_PASSWORD will be on $mysql/drupal-db-pw.txt

### Stoping and starting Drupal8-docker-app

To stop and restart the installed existing site

1. Press CTRL+C on the console showing the logs
2. Run `drupal8_local.sh` on the same directory
3. Open the site URL mentioned in the console

### Example usage for testing:
Using docker exec {ID} {COMMAND}, to run your own commands.
```
~$ docker run --name mydrupal8 -i -t -p 80:80 ricardoamaro/drupal8

~$ docker exec mydrupal8  uptime
 10:02:59 up 16:41,  0 users,  load average: 1.17, 0.92, 0.76

~$ docker exec mydrupal8 drush status | head
 Drupal version         :  8.5.3
 Site URI               :  http://default
 Database driver        :  mysql
 Database hostname      :  localhost
 Database port          :  3306
 Drupal bootstrap       :  Successful
 ```

## For older Drupal versions check:
https://github.com/ricardoamaro/drupal7-docker-app
https://github.com/ricardoamaro/drupal6-docker-app

## You can also clone this repo somewhere and build it,
```
git clone https://github.com/ricardoamaro/drupal8-docker-app.git
cd drupal8-docker-app
sudo docker build -t <yourname>/drupal8 .
```
## Or build it directly from github,
```
sudo docker build -t ricardo/drupal8 https://github.com/ricardoamaro/drupal8-docker-app.git
```

Note1: you cannot have port 80 already used or the container will not start.
In that case you can start by setting: `-p 8080:80`

Note2: To run the container in the background
```
sudo docker run -d -t -p 80:80 <yourname>/drupal8
```

# More docker awesomeness

How to go back to the last docker run?

```
docker ps -al
(get the container ID)
docker start -i -a (container ID)
```

This will create an ID that you can start/stop/commit changes:
```
# sudo docker ps
ID                  IMAGE                   COMMAND               CREATED             STATUS              PORTS
538example20        <yourname>/drupal8:latest   /bin/bash /start.sh   3 minutes ago       Up 6 seconds        80->80
```

Start/Stop
```
sudo docker stop 538example20
sudo docker start 538example20
```

Commit the actual state to the image
```
sudo docker commit 538example20 <yourname>/drupal8
```

Starting again with the commited changes
```
sudo docker run -d -t -p 80:80 <yourname>/drupal8 /start.sh
```

Shipping the container image elsewhere
```
sudo docker push  <yourname>/drupal8
```

You can find more images using the [Docker Index][docker_index].

## Clean up
While i am developing i use this to rm all old instances
```
sudo docker ps -a | awk '{print $1}' | grep -v CONTAINER | xargs -n1 -I {} sudo docker rm {}
```

# Known Issues
* Warning: This is still in development and ports shouldn't
be open to the outside world.


# Contributing
Feel free to submit any bugs, requests, or fork and contribute
to this code. :)

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

Created and maintained by [Ricardo Amaro][author]
http://blog.ricardoamaro.com

## License
GPL v3

[author]:                 https://github.com/ricardoamaro
[docker_upstart_issue]:   https://github.com/dotcloud/docker/issues/223
[docker_index]:           https://index.docker.io/
