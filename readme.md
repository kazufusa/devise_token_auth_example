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

## 3. db migration

add below to migration file

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

```
$ docker-compose up -d db
: fix app/models/user.rb
: https://github.com/lynndylanhurley/devise_token_auth/issues/1276
$ docker-compose run --rm web rails db:setup
$ docker-compose run --rm web rails db:migration
```

## 4. test with curl

### sign up

```
curl localhost:3000/auth -X POST -i \
  -d '{"email":"example@example.com", "password":"password"}' \
  -H "content-type:application/json"

HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
access-token: qXTz3dHpIivk9y2-Ixgyng
token-type: Bearer
client: v4z54dkrqyRH8cfVu-8Zmw
expiry: 1584856137
uid: example@example.com
Content-Type: application/json; charset=utf-8
ETag: W/"7c5144a53c34c450a25de652d3a90428"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 68aa8246-479d-433d-87a5-43f9fdc909da
X-Runtime: 0.721965
Transfer-Encoding: chunked

{"status":"success","data":{"uid":"example@example.com","id":1,"email":"example@example.com","provider":"email","allow_password_change":false,"name":null,"nickname":null,"image":null,"created_at":"2020-03-08T05:48:57.187Z","updated_at":"2020-03-08T05:48:57.369Z"}}%
```

### sign in

```
curl localhost:3000/auth/sign_in -X POST -i \
  -d '{"email":"example@example.com", "password":"password"}' \
  -H "content-type:application/json"
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Content-Type: application/json; charset=utf-8
access-token: zBP485qfcQmJIOKnYX2v7A
token-type: Bearer
client: 4TMilZbTdmki45kpZ2Dpdw
expiry: 1584856223
uid: example@example.com
ETag: W/"0b844d681927a23677ff78329b4c7409"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: e701d328-597a-443e-a579-cc1ff9e88b30
X-Runtime: 0.441844
Transfer-Encoding: chunked

{"data":{"id":1,"email":"example@example.com","provider":"email","uid":"example@example.com","allow_password_change":false,"name":null,"nickname":null,"image":null}}%
```

### sign out

```
curl localhost:3000/auth/sign_out -X DELETE -i \
  -H "content-type:application/json" \
  -H "access-token: zBP485qfcQmJIOKnYX2v7A" \
  -H "client: 4TMilZbTdmki45kpZ2Dpdw" \
  -H "uid: example@example.com"

HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Content-Type: application/json; charset=utf-8
ETag: W/"c955e57777ec0d73639dca6748560d00"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 3237608b-57d5-4b0c-b173-582c799b5e62
X-Runtime: 0.176288
Transfer-Encoding: chunked

{"success":true}% 
```

## 5. rspec

add rspec-rails to Gemfile

```ruby
group :development, :test do
  # Note that rspec-rails 4.0 is still a beta release
  gem 'rspec-rails', '~> 3.9.0'
end
```

```bash
$ docker-compose run --rm web bundle install
$ docker-compose run --rm web rails g rspec:install
Starting devise_token_auth_example_db_1 ... done
        Running via Spring preloader in process 22
      create  .rspec
      create  spec
      create  spec/spec_helper.rb
      create  spec/rails_helper.rb
```

### refs

- https://devise-token-auth.gitbook.io/devise-token-auth/usage/testing
- https://relishapp.com/rspec/rspec-rails/docs/generators

```bash
$ docker-compose run --rm web rails g factory_bot:user
$ docker-compose run --rm web rails g rspec:request authentication
: implement test
$ docker-compose exec web rspec

Sign up
  POST /auth
    gives you an new user

Whether access is ocurring properly
  general authentication via API,
    gives you an authentication code if you are an existing user and you satisfy the password
    gives you a status 200 on signing in

Whether access is ocurring improperly
  general authentication via API,
    gives you no authentication code if you do not satisfy the password
    gives you a status 401 on failing to sign in

Finished in 2.54 seconds (files took 7.82 seconds to load)
5 examples, 0 failures
```

## 6. confirmable / reconfirmable

### create new user

```
$ curl localhost:3000/auth -X POST -i \
  -d '{"email":"example@example.com", "password":"password", "confirm_success_url":"https://confirm"}' \
  -H "content-type:application/json"
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Content-Type: application/json; charset=utf-8
ETag: W/"25acf033c3277330c95019ba448bf19e"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 7c749535-55b4-4bdb-b370-35b52381793e
X-Runtime: 0.279289
Transfer-Encoding: chunked

{"status":"success","data":{"id":16,"provider":"email","uid":"example@example.com","allow_password_change":false,"name":null,"nickname":null,"image":null,"email":"example@example.com","created_at":"2020-03-10T13:40:36.534Z","updated_at":"2020-03-10T13:40:36.534Z"}}%
```

### invitation mail

```
Date: Tue, 10 Mar 2020 13:40:36 +0000
From: development@development.com
To: example@example.com
Message-ID: <5e6798d486941_12b2807a2eaa4391da@f543b09345a6.mail>
Subject: Confirmation instructions
Mime-Version: 1.0
Content-Type: text/html;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
client-config: default
redirect-url: https://confirm

<p>Welcome example@example.com!</p>

<p>You can confirm your account email through the link below: </p>

<p><a href="http:///auth/confirmation?config=default&confirmation_token=jGwUcMAjwC1JgbF3EU-A&redirect_url=https%3A%2F%2Fconfirm">Confirm my account</a></p>
```

### confirm

```
$ curl -X GET -i "localhost:3000/auth/confirmation?config=default&confirmation_token=jGwUcMAjwC1JgbF3EU-A&redirect_url=https%3A%2F%2Fconfirm"
HTTP/1.1 302 Found
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Location: https://confirm?account_confirmation_success=true
Content-Type: text/html; charset=utf-8
Cache-Control: no-cache
X-Request-Id: f97683dd-5aea-4d55-94ce-02f3f478ca0e
X-Runtime: 0.120693
Transfer-Encoding: chunked

<html><body>You are being <a href="https://confirm?account_confirmation_success=true">redirected</a>.</body></html>% 
```

### sign in

```
curl localhost:3000/auth/sign_in -X POST -i \
  -d '{"email":"example@example.com", "password":"password"}' \
  -H "content-type:application/json"

HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Content-Type: application/json; charset=utf-8
access-token: o-kO5J1wc1-A37LkLTs2TA
token-type: Bearer
client: KmfkCCJm6bBDuEH76a0oCA
expiry: 1585057508
uid: example@example.com
ETag: W/"fa6c9937d8979965c65f3f0057f4009f"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 81fd6e37-b611-4ab7-828d-4f138d1a4d7c
X-Runtime: 0.462255
Transfer-Encoding: chunked

{"data":{"id":16,"email":"example@example.com","provider":"email","uid":"example@example.com","allow_password_change":false,"name":null,"nickname":null,"image":null}}% 
```

## 6.1 confirmation_with

## 7. Sign up by email only and set password after receiving invitation.

### flow without password

1. sign up with only email
2. send mail including confirmation link with confirmation_token
3. click link and redirect to some url with reset_password_token
3. patch/put user_password_path with reset_password_token, password, password_confirmation
4. user is enabled to login with email and password

## 8. REST API for user(s)

```
$ docker-compose run --rm web rails g scaffold_controller Users
```

install active_model_serializers

```
$ docker-compose run --rm web rails g serializer User
```

```
$ curl -s localhost:3000/users | jq .
[
  {
    "id": 17,
    "name": null,
    "email": "example@example.com",
    "is_confirmed": false
  },
  {
    "id": 18,
    "name": null,
    "email": "examplee@example.com",
    "is_confirmed": false
  },
  {
    "id": 19,
    "name": null,
    "email": "exampleee@example.com",
    "is_confirmed": false
  },
  {
    "id": 20,
    "name": null,
    "email": "exampleeee@example.com",
    "is_confirmed": false
  }
]
```

## 9. lock

### user model

1. add failed_attempts and locked_at to users
2. lock strategy is :failed_attempts
3. unlock strategy is none (self implementation)

### user control

1. add lock/unlock method

## 10 confirmation mails

# notify account lock/unlock by user controller

```bash
$ docker-compose run web rails g mailer NotificationMailer # for lock/unlock
```

# notify password reset instruction

```bash
curl localhost:3000/auth/password -X POST -i \
  -d '{"email":"example@example.com", "redirect_url":"localhost:3000/"}' \
  -H "content-type:application/json"
```

## 11. admin and user


### admin

- sign up user
- user lock/unlock
- creat password reset
- delete user

### user

- change name
- change password
- confirmation via mail
- reset password via mail

## X.

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
