## Requirements

* ruby
* bundler `(gem install bundler)`
* docker

## Install gems

```bash
bundle install
```

## Start db with docker compose

```bash
docker-compose up
```

## Setup initial db

```bash
rails db:create
rails db:migrate
```

## Start rails server

```bash
./bin/dev
```
Open http://localhost:3000 in your browser.
