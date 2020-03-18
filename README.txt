
how to run:

docker-compose up -d
docker-compose exec shastic_challenge bash

/app# CHALLENGE_API_URL="http://api:9980/json" bundle exec ruby -r./app.rb -e 'call'


