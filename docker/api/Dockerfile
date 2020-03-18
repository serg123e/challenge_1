FROM ruby:2.5.5
COPY ./docker/api/docker-entrypoint.sh /
RUN chmod -R 755  /docker-entrypoint.sh
RUN mkdir /app
WORKDIR /app

ENTRYPOINT ["/docker-entrypoint.sh"]
