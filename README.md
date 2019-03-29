# Bludit Docker Image (Alpine based)
You can run Bludit as a Docker container. Image based in Alpine Linux 3.7, php 5.6 and latest bludit 3.8.1. 


### Run the container

```
$ docker run --name bludit -p 8000:80 -d pdacity/bludit_docker:latest
```

To get access go with your browser to http://localhost:8000

### Stop the container

```
$ docker stop bludit
```

### Delete the container

```
$ docker rm bludit
```

### Delete the image

```
$ docker rmi pdacity/bludit_docker:latest
```

### Start with docker-compose

```
version: '2.4'

services:

  bludit:
    image: pdacity/bludit_docker
    volumes:
      - html:/var/www           # Bludit home
      - nginx:/etc/nginx        #Nginx config
    restart: always
    cpu_shares: 50
    mem_limit: 64m
    memswap_limit: 64m

volumes:
  html: {}
  nginx: {}

networks:
  default:
```
