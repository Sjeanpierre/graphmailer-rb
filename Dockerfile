from ruby:alpine

WORKDIR /app

RUN apk update


RUN apk --no-cache add \
  zlib-dev \
  build-base \
  libxml2-dev \
  libxslt-dev \
  readline-dev \
  libffi-dev \
  yaml-dev \
  zlib-dev \
  libffi-dev \
  cmake \
  bash \
  ca-certificates \
  curl \
  groff \
  less && \
  rm -rf /var/cache/apk/*


ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --jobs 20 --retry 5
COPY . /app/