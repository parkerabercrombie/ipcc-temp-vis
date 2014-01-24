#####################################################
# Makefile for GE510 Project.
####################################################

-include cera.auth

KML_DIR=ipcc_projections
KML_FILE=$(KML_DIR)/doc.kml
KMZ_FILE=$(KML_DIR).kmz
IMG_DIR=$(KML_DIR)/images

DATA_DIR=data

JBLOB_VERSION=2.0.10
JBLOB_URL=http://cera-www.dkrz.de/jblob/Jblob-$(JBLOB_VERSION).zip
JBLOB_DIR=Jblob-$(JBLOB_VERSION)

jblob=java -mx100m -classpath "$(JBLOB_DIR)/Jblob.jar:$(JBLOB_DIR)/commons-codec-1.4.jar" \
    de.dkrz.cera.applications.JblobClient --dataset $1 --dir $(DATA_DIR) \
     --username $(CERA_USERNAME) --password $(CERA_PASSWORD)


# To extract one day from GRIB to text (one val per line)
# ./wgrib -s -4yr NCCCSM_SRA2_1_G_pr_1-1200.grb | grep "d=2095101612" | ./wgrib -i -o out.txt -text -h  NCCCSM_SRA2_1_G_pr_1-1200.grb 

all: kml

data: NCCCSM_SRA2_1_G_pr NCCCSM_SRA2_1_G_tas NCCCSM_SRA1B_1_G_tas

$(DATA_DIR):
	mkdir -p data

NCCCSM_SRA2_1_G_pr: Jblob-$(JBLOB_VERSION).zip $(DATA_DIR)
	$(call jblob,$@)

NCCCSM_SRA2_1_G_tas: Jblob-$(JBLOB_VERSION).zip $(DATA_DIR)
	$(call jblob,$@)

NCCCSM_SRA1B_1_G_tas: Jblob-$(JBLOB_VERSION).zip $(DATA_DIR)
	$(call jblob,$@)

$(KML_DIR):
	mkdir -p $(KML_DIR)
	mkdir -p $(IMG_DIR)

images: $(KML_DIR)
	./create_heatmap_images.R
	./world_population.R a1b
	./world_population.R a2
	./world_population.R b1

kml: images
	python build_kml.py images > $(KML_FILE)

kmz: kml
	cd $(KML_DIR) && zip -r ../$(KMZ_FILE) *

clean:
	rm -rf ipcc_projections/
	rm ipcc_projections.kmz *~

.PHONY: data images