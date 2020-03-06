FROM ruby:2.6.5

RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    postgresql-client && \
    apt-get clean

RUN gem install bundler:2.1.4

RUN mkdir /app
ENV APP_ROOT /app
WORKDIR $APP_ROOT

COPY app/Gemfile $APP_ROOT/Gemfile
COPY app/Gemfile.lock $APP_ROOT/Gemfile.lock
RUN bundle install

COPY ./scripts/create_app.sh /usr/bin/
RUN chmod +x /usr/bin/create_app.sh

# Add a script to be executed every time the container starts.
COPY scripts/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]

