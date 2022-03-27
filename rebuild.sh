#!/bin/bash

echo ">>>>>[1] Updating repository step 1/2"
git fetch origin

echo ">>>>>[2] Updating repository step 2/2"
git rebase origin/main

echo ">>>>>[3] Rebuilding image"
docker build -t talkon .

echo ">>>>>[4] Stopping bot service"
sudo systemctl stop talkon

echo ">>>>>[5] Removing previous container"
docker container rm talkon

echo ">>>>>[6] Starting bot service"
sudo systemctl start talkon
