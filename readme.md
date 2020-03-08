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

## 6. confirmable / reconfirmable

## 7. Sign up by email only and set password after receiving invitation.

## 8. REST API for user(s)

## 9. admin



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
