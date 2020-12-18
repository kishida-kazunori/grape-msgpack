FROM ruby:2.6.6
ENV LANG C.UTF-8
RUN gem install bundler
WORKDIR /tmp
ADD lib lib
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
ADD grape-msgpack.gemspec grape-msgpack.gemspec
RUN bundle install
RUN gem update --system
ENV APP_HOME /app
RUN mkdir -p ${APP_HOME}
WORKDIR ${APP_HOME}
ADD . ${APP_HOME}
RUN cd ${APP_HOME}