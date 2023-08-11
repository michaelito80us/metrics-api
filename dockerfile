FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -y nodejs sqlite3 libsqlite3-dev
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

RUN rake db:create db:migrate db:seed

EXPOSE 3001

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3001"]
