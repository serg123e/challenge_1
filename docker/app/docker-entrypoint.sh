#!/bin/bash

set -e
BUNDLE_IGNORE_CONFIG=1 bundle install

exec "rake db:create"
exec "rake db:migrate"

exec "/bin/bash"

