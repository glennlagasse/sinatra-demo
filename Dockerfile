FROM ruby:3.2.1-slim as base

RUN apt-get update -qq \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
  # Needed for healthcheck
  curl \
  # Needed for certain gems
  build-essential \
  # Needed for postgres gem
  libpq-dev \
  # The following are used to trim down the size of the image by removing unneeded data
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
  /var/lib/apt \
  /var/lib/dpkg \
  /var/lib/cache \
  /var/lib/log

# Changes localtime to Singapore
RUN cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

FROM base as dependencies

COPY Gemfile ./

RUN bundle config set without "development test" && \
  bundle install --jobs=3 --retry=3

FROM base

RUN useradd -s /bin/false -d /app app

USER app

WORKDIR /app

# Copy over gems from the dependencies stage
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

#COPY --chown=app . ./
COPY . ./

EXPOSE 4567

# Launch the server
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
