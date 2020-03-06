# 1. create rails app

```
$ docker-compose build
$ docker-compose run --rm web create_app.sh
```

# 2. initial setup of devise

```
$ docker-compose run --rm web rails g devise:install
$ docker-compose run --rm web rails g devise_token_auth:install User auth
```
