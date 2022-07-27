#!/bin/bash

docker-compose -f loki/production/docker/docker-compose.yaml pull
docker-compose -f loki/production/docker/docker-compose.yaml up

