.PHONY: start scrap

start:
	docker-compose up	

scrap:
	ruby scripts/scrap_data.rb
