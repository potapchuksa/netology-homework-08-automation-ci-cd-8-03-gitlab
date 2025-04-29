#!/bin/bash

docker run -ti --rm \
  --name gitlab-runner2 \
  --network host \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest \
  register \
  --non-interactive \
  --url "$GITLAB_URL" \
  --registration-token "$GITLAB_REGISTRATION_TOKEN" \
  --executor "docker" \
  --docker-image "golang:1.17" \
  --description "Docker Runner" \
  --tag-list "docker,linux" \
