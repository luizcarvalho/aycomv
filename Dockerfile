# syntax=docker/dockerfile:1
# check=error=true

# Unified Dockerfile for both production and development
# Usage:
#   Production: docker build -t aycomv .
#   Development: docker build --target development -t aycomv-dev .
#
# Run production:
#   docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name aycomv aycomv
#
# Run development:
#   docker compose up (uses the development target)

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.8

#==============================================================================
# BASE STAGE
# Shared base with common runtime packages for both development and production
#==============================================================================
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install common runtime packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libvips \
    ffmpeg \
    postgresql-client \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Common environment
ENV BUNDLE_PATH="/usr/local/bundle"

#==============================================================================
# DEVELOPMENT STAGE
# Extends base with build tools for gem compilation during development
#==============================================================================
FROM base AS development

# Install build dependencies for native gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    libyaml-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Development environment
ENV RAILS_ENV="development" \
    BINDING="0.0.0.0"

# Copy Gemfile first for layer caching
COPY Gemfile Gemfile.lock ./
COPY vendor/ ./vendor/

# Install gems (will be cached in bundle-cache volume when using compose)
RUN bundle install

#==============================================================================
# BUILD STAGE
# Throw-away stage to build gems and precompile assets for production
#==============================================================================
FROM base AS build

# Install build dependencies (same as development)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    libyaml-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Production bundle settings
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development"

# Install application gems
COPY vendor/* ./vendor/
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

# Copy application code
COPY . .

# Precompile bootsnap and assets
RUN bundle exec bootsnap precompile -j 1 app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

#==============================================================================
# PRODUCTION STAGE
# Final minimal image for production deployment
#==============================================================================
FROM base AS production

# Enable jemalloc for reduced memory usage
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libjemalloc2 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Production environment with jemalloc
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Run as non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# Copy built artifacts from build stage
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
