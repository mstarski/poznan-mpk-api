.PHONY: start scrap build test

start:
	docker-compose up	

scrap:
	ruby utils/scrap_data.rb

build: 
	docker-compose build

test:
	bundle exec rspec --format documentation

fix:
	rubocop -x
