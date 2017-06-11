GEOSUPPORT_PATH := geosupport

setup: geosupport gdelx_17a.zip version-17a_17.1

geosupport:
	mkdir -v -p geosupport

gdelx_17a.zip:
	wget http://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/gdelx_17a.zip -O $(GEOSUPPORT_PATH)/gdelx_17a.zip

version-17a_17.1: 
	cd $(GEOSUPPORT_PATH) && unzip gdelx_17a.zip

.PHONY: download
