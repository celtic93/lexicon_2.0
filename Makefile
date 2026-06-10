TIMESTAMP := $(shell date +"%Y-%m-%d_%H-%M-%S")

db_recreate:
	pg_dump lexicon_development > dump_$(TIMESTAMP).sql
	bin/rails db:drop
	bin/rails db:create
	bin/rails db:migrate
	bin/rails db:seed

lint:
	bin/brakeman --no-pager
	bin/rubocop -f github

sidekiq:
	bundle exec sidekiq -C config/sidekiq.yml
