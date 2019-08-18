FROM ruby:2.6

RUN gem install bundler:2.0.2

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN make scrap

CMD ["ruby", "main.rb"]
