#!/bin/bash

NAME=$(grep '^name:' pubspec.yaml | cut -d':' -f2- | sed 's@ @@g')
VERSION=$(grep '^version:' pubspec.yaml | cut -d':' -f2- | sed 's@ @@g' | sed 's@\+@_@g')

DOCKER_PREFIX="docker.basjes.nl"

echo "Build docker image for web for ${NAME}:${VERSION}"

flutter build web --web-renderer canvaskit

docker build -t "${DOCKER_PREFIX}/${NAME}:${VERSION}" .
docker tag "${DOCKER_PREFIX}/${NAME}:${VERSION}" "${DOCKER_PREFIX}/${NAME}:latest"

#docker run -p8080:8080 "${DOCKER_PREFIX}/${NAME}:latest"