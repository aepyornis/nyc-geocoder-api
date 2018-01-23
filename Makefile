GEOSUPPORT_PATH := geosupport
LIBPOSTAL_INSTALL_DIR ?= $(HOME)/.libpostal
LIBPOSTAL_DATA_DIR ?= $(LIBPOSTAL_INSTALL_DIR)/data

setup: $(GEOSUPPORT_PATH) $(GEOSUPPORT_PATH)/gdelx_17d.zip $(GEOSUPPORT_PATH)/version-17d_17.4

$(GEOSUPPORT_PATH):
	mkdir -v -p $(GEOSUPPORT_PATH)

$(GEOSUPPORT_PATH)/gdelx_17d.zip:
	wget http://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/gdelx_17d.zip -O $(GEOSUPPORT_PATH)/gdelx_17d.zip

$(GEOSUPPORT_PATH)/version-17d_17.4:
	cd $(GEOSUPPORT_PATH) && unzip gdelx_17d.zip

libpostal: libpostal_packages $(LIBPOSTAL_INSTALL_DIR) $(LIBPOSTAL_DATA_DIR)
	$(MAKE) $(LIBPOSTAL_INSTALL_DIR)/libpostal

$(LIBPOSTAL_INSTALL_DIR)/libpostal:
	cd $(LIBPOSTAL_INSTALL_DIR) && \
	git clone https://github.com/openvenues/libpostal && \
	cd libpostal && ./bootstrap.sh && ./configure --datadir=$(LIBPOSTAL_DATA_DIR) && \
	make && sudo make install && sudo ldconfig

libpostal_packages: 
	sudo apt install curl autoconf automake libtool pkg-config

libpostal_clean:
	rm -rf $(LIBPOSTAL_INSTALL_DIR)

$(LIBPOSTAL_INSTALL_DIR):
	mkdir -v -p $(LIBPOSTAL_INSTALL_DIR)

$(LIBPOSTAL_DATA_DIR):
	mkdir -v -p $(LIBPOSTAL_DATA_DIR)

.PHONY: setup libpostal libpostal_packages libpostal_clean
