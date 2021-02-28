# Straboard

> Create your own Strava team leaderboards


## Local setup

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Deploy to Heroku

Get your Strava API keys in [developer settings page](https://www.strava.com/settings/api).

```
# Create a Heroku instance for your project
heroku apps:create my_heroku_app

# Set and add the buildpacks for your Heroku app
heroku buildpacks:add https://github.com/HashNuke/heroku-buildpack-elixir
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static

# Create a postgres db
heroku addons:create heroku-postgresql:hobby-dev

# Set environment
heroku config:set SECRET_KEY_BASE=XXXXXXXXXXXXXXXXXXXX
heroku config:set STRAVA_CLIENT_ID=XXXXXXXXXXXXXXXXXXXX
heroku config:set STRAVA_CLIENT_SECRET=XXXXXXXXXXXXXXXXXXXX

# Deploy
git push heroku master

# Migrate
heroku run "POOL_SIZE=2 mix ecto.migrate --no-compile"
```

Go to `my_heroku_app.herokuapp.com` and enjoy!
