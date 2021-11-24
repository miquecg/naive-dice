# NaiveDice

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create, migrate and seed your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Heroku Deployment 

This app is prepared for heroku deployment.
Please check [the deployment guides](https://hexdocs.pm/phoenix/heroku.html).

TL;DR:
```
#/bin/bash
heroku create --buildpack hashnuke/elixir
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
heroku addons:create heroku-postgresql
heroku config:set SECRET_KEY_BASE=`mix phx.gen.secret`
git push heroku master
heroku run mix ecto.migrate
heroku run mix run priv/repo/seeds.exs
heroku open
```

Set all other env variables you need (e.g. Stripe key) via `heroku config:set`

## Learn Phoenix

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
