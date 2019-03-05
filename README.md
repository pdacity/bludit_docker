# Bludit Docker Image (Alpine based)
You can run Bludit as a Docker container.

[![Docker Hub](https://img.shields.io/badge/Docker-Hub-blue.svg)](https://hub.docker.com/r/bludit/docker/)


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

