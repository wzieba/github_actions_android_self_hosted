# base
FROM bitriseio/docker-android

# set the github runner version
ARG RUNNER_VERSION="2.273.2"

USER root

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker-gh

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get install -y curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev

# Update git
RUN add-apt-repository ppa:git-core/ppa -y
RUN apt-get update -y
RUN apt-get install -y git

# Use ssh on git
RUN git config --global --add url."git@github.com:".insteadOf "https://github.com/"


# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker-gh && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker-gh ~docker-gh && /home/docker-gh/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY entrypoint.sh entrypoint.sh

# make the script executable
RUN chmod +x entrypoint.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker-gh

# set the entrypoint to the start.sh script
ENTRYPOINT ["./entrypoint.sh"]

