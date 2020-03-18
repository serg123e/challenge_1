#!/bin/bash

set -e
BUNDLE_IGNORE_CONFIG=1 bundle install

rake db:create
rake db:migrate

exec "/bin/bash"

