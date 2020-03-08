# development flow


## 1. create rails app

```
$ docker-compose build
$ docker-compose run --rm web bash -c "cat \`which create_app.sh\`"
#!/bin/sh

gem i -v 6.0.2.1 rails
cd $APP_ROOT/..
rails new app --api -d postgresql --skip-test
$ docker-compose run --rm web create_app.sh
```

## 2. initial setup of devise

```
: add `gem 'devise_token_auth'` to Gemfile
$ docker-compose run --rm web bundle install
$ docker-compose run --rm web rails g devise_token_auth:install User auth
```

## 3. edit migration and models/user.rb

1. add admin field to user table
2. enable confirmable in user model
3. run migration

# testing

- mailcatcher
- https://remonote.jp/rails-letter-opener-web-mail
- https://easyramble.com/test-action-mailer-with-rspec.html
- http://uraway.hatenablog.com/entry/2019/01/02/170541
- https://whatsupguys.net/programming-school-dive-into-code-learning-48/
- https://easyramble.com/customize-mail-template-of-devise.html
