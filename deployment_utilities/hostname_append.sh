#!/bin/bash

docker_control_plane=$(sudo docker ps| awk '/control-plane/{print $NF}')
docker_node_IP=$(docker container inspect ${docker_control_plane} \
  --format '{{ .NetworkSettings.Networks.kind.IPAddress }}')
docker_hostname=$(cat /opt/helloworld/values.yaml | grep -oP "(?<=host: ).*")
if grep -q "${docker_node_IP} ${docker_hostname}" /etc/hosts; then
    echo "Entry already exists in /etc/hosts"
else
    echo "${docker_node_IP} ${docker_hostname}" >> /etc/hosts
fi
