FROM lambci/lambda:build-ruby2.5
RUN yum install -y mysql-client mysql-devel
RUN gem install bundler:1.17.3
COPY ./docker/app/docker-entrypoint.sh /
RUN chmod -R 755  /docker-entrypoint.sh
RUN mkdir /app
WORKDIR /app

ENTRYPOINT ["/docker-entrypoint.sh"]
