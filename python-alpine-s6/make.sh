#!/usr/bin/env bash


registry=ivonet
image=alpine-python-s6
version=3.15-3.9.12-3.1.0.1

DOCKER_BUILDKIT=1
docker buildx create --name multibuilder --use
docker buildx inspect --bootstrap
docker buildx build --platform=linux/amd64 --push -f Dockerfile.amd64 -t $registry/$image .
docker buildx build --platform=linux/amd64 --push -f Dockerfile.amd64 -t $registry/$image:$version .

docker buildx build --platform=linux/arm64/v8 --push -f Dockerfile.arm64 -t $registry/$image .
docker buildx build --platform=linux/arm64/v8 --push -f Dockerfile.arm64 -t $registry/$image:$version .
docker buildx rm -f multibuilder
docker pull $registry/$image:$version


