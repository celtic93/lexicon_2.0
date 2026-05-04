db_recreate:
	bin/rails db:drop
	bin/rails db:create
	bin/rails db:migrate
	bin/rails db:seed

lint:
	bin/brakeman --no-pager
	bin/rubocop -f github

sidekiq:
	bundle exec sidekiq -C config/sidekiq.yml
