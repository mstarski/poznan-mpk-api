.PHONY: start scrap build

start:
	docker-compose up	

scrap:
	ruby utils/scrap_data.rb

build: 
	docker-compose build
