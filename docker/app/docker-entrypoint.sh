#!/bin/bash

set -e
# BUNDLE_IGNORE_CONFIG=1 bundle install

# rake db:create
# rake db:migrate
rm -rf /app/lib
rm -rf /app/vendor

bundle config --local build.mysql2 --with-mysql2-config=/usr/lib64/mysql/mysql_config
bundle config --local silence_root_warning true
bundle install --path vendor/bundle
mkdir -p /app/lib
cp -a /usr/lib64/mysql/*.so.* /app/lib/

exec "/bin/bash"

