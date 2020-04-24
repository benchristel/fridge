.PHONY: test
test: unit functional

.PHONY: unit
unit:
	bundle exec rspec spec/unit

.PHONY: functional
functional:
	bundle exec rspec spec/functional

.PHONY: run
run:
	ruby server.rb
