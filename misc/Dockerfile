FROM ruby:2.6.4-slim-buster

RUN mkdir -p /opt/pikebubbles
RUN gem install bundler:2.0.2
ENV BUNDLER_VERSION 2.0.2
ENV HOME /opt/pikebubbles
WORKDIR /opt/pikebubbles

COPY _Gemfile /opt/pikebubbles/Gemfile
COPY _Gemfile.lock /opt/pikebubbles/Gemfile.lock
RUN bundle install --deployment --path ./vendor/bundle

CMD ["bundle", "exec", "pikebubbles"]
