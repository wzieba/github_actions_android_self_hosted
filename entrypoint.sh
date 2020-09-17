#!/bin/bash

REPO=$REPO
ORGANIZATION=$ORGANIZATION
RUNNER_TOKEN=$RUNNER_TOKEN

#REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker-gh/actions-runner

./config.sh --url https://github.com/${ORGANIZATION}/${REPO} --token ${RUNNER_TOKEN}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${RUNNER_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!

