#!/bin/bash

set -e # stop on error
set -x # echo all commands

# We'll run things from here
DEPLOY=/tmp/deploy

# Clean up from last time
pkill -f /tmp/deploy/releases
rm -rf /tmp/deploy
rm -rf _build/prod/rel
mkdir $DEPLOY

# Build, "deploy", and start the first version
export APP_VERSION=0.0.1
export MIX_ENV=prod
mix compile --force
mix phoenix.digest
mix release --env=prod
tar xzf _build/prod/rel/distillery_experiment/releases/$APP_VERSION/distillery_experiment.tar.gz -C $DEPLOY
PORT=4000 $DEPLOY/bin/distillery_experiment start
sleep 1 # give it a chance to start

# App should now be reporting "0.0.1"
if [ "$(curl localhost:4000)" == "$APP_VERSION" ]; then
  echo "Version is correct: $APP_VERSION"
else
  echo "oops, first version isn't $APP_VERSION!"
  exit 1
fi

# Build the second version, and put its tarball in a "0.0.2" subdirectory of "releases"
export APP_VERSION=0.0.2
mix compile --force
mix phoenix.digest
mix release --env=prod --upgrade
mkdir $DEPLOY/releases/$APP_VERSION
cp _build/prod/rel/distillery_experiment/releases/$APP_VERSION/distillery_experiment.tar.gz $DEPLOY/releases/$APP_VERSION

# Perform the hot upgrade
$DEPLOY/bin/distillery_experiment upgrade $APP_VERSION

# App should now be reporting "0.0.2"
if [ "$(curl localhost:4000)" = "$APP_VERSION" ]; then
  echo "Version is correct: $APP_VERSION"
else
  echo "oops, upgraded version isn't $APP_VERSION!"
  exit 1
fi
