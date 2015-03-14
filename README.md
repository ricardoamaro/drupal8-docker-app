drupal8-docker-app
==================

This repo contains a recipe for making a Docker container running Drupal8, using Linux, Apache, MySQL, Memcache and SSH.
To use it, make sure you first [Install Docker](https://docs.docker.com/installation/).

#Quick 3 step instructions:

## 1 - Install docker:
https://docs.docker.com/installation/

## 2 - Get the image and run it using port 80:
```
sudo docker run -i -t -p 80:80 ricardoamaro/drupal8
```
That's it!
## 3 - Visit [http://localhost/](http://localhost/) in your browser
using user/pass: admin/admin

### Credentials:
* Drupal account-name=admin & account-pass=admin
* ROOT SSH/MYSQL PASSWORD will be on /mysql-root-pw.txt
* DRUPAL   MYSQL_PASSWORD will be on /drupal-db-pw.txt

## How to go back to the last docker run?
```
sudo docker ps -al
(get the container ID)
sudo docker start -i -a (container ID)
```

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

## More docker awesomeness

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

### Clean up
While i am developing i use this to rm all old instances
```
sudo docker ps -a | awk '{print $1}' | grep -v CONTAINER | xargs -n1 -I {} sudo docker rm {}
```

### Known Issues
* Warning: This is still in development and ports shouldn't be open to the outside world.


## Contributing
Feel free to submit any bugs, requests, or fork and contribute to this code. :)

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

