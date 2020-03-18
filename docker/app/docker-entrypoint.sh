#!/bin/bash

set -e
BUNDLE_IGNORE_CONFIG=1 bundle install
set CHALLENGE_API_URL="http://api:4567/json"
exec "/bin/bash"

