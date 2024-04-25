FROM ruby:3.0.0 as base

RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs npm

RUN npm install -g yarn

WORKDIR /app

RUN gem install bundler

COPY Gemfile* ./

RUN bundle install

ADD . /app
