FROM ruby:2.6

RUN gem install bundler

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN make scrap

CMD ["bundle", "exec", "rackup", "-p", "4567", "--host", "0.0.0.0"]
