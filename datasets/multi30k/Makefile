#-*-makefile-*-
#
# multi30k
#


.PHONY: all
all: testsets.tsv

testsets.tsv:
	git clone https://github.com/multi30k/dataset.git
	rm -fr dataset/.git*
	for s in cs de en fr; do \
	  gunzip dataset/data/task1/raw/test_2016_flickr.$$s.gz; \
	  gunzip dataset/data/task1/raw/test_2018_flickr.$$s.gz; \
	  git add dataset/data/task1/raw/test_2016_flickr.$$s; \
	  git add dataset/data/task1/raw/test_2018_flickr.$$s; \
	done
	for s in de en fr; do \
	  gunzip dataset/data/task1/raw/test_2017_flickr.$$s.gz; \
	  gunzip dataset/data/task1/raw/test_2017_mscoco.$$s.gz; \
	  git add dataset/data/task1/raw/test_2017_flickr.$$s; \
	  git add dataset/data/task1/raw/test_2017_mscoco.$$s; \
	done
	gzip -cd dataset/data/task2/raw/test_2016.1.de.gz  > dataset/data/task2/raw/test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.2.de.gz >> dataset/data/task2/raw/test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.3.de.gz >> dataset/data/task2/raw/test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.4.de.gz >> dataset/data/task2/raw/test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.5.de.gz >> dataset/data/task2/raw/test_2016.de
	git add dataset/data/task2/raw/test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.1.en.gz  > dataset/data/task2/raw/test_2016.en
	gzip -cd dataset/data/task2/raw/test_2016.2.en.gz >> dataset/data/task2/raw/test_2016.en
	gzip -cd dataset/data/task2/raw/test_2016.3.en.gz >> dataset/data/task2/raw/test_2016.en
	gzip -cd dataset/data/task2/raw/test_2016.4.en.gz >> dataset/data/task2/raw/test_2016.en
	gzip -cd dataset/data/task2/raw/test_2016.5.en.gz >> dataset/data/task2/raw/test_2016.en
	git add dataset/data/task2/raw/test_2016.en
	for s in cs de en fr; do \
	  S=`iso639 -3 -k -n $$s`; \
	  for t in cs de en fr; do \
	    T=`iso639 -3 -k -n $$t`; \
	    if [ "$$s" != "$$t" ]; then \
	        echo "$$S	$$T	multi30k_test_2016_flickr				datasets/multi30k/dataset/data/task1/raw/test_2016_flickr.$$s	datasets/multi30k/dataset/data/task1/raw/test_2016_flickr.$$t" >> $@; \
	        echo "$$S	$$T	multi30k_test_2018_flickr				datasets/multi30k/dataset/data/task1/raw/test_2018_flickr.$$s	datasets/multi30k/dataset/data/task1/raw/test_2018_flickr.$$t" >> $@; \
	    fi \
	  done \
	done
	for s in de en fr; do \
	  S=`iso639 -3 -k -n $$s`; \
	  for t in de en fr; do \
	    T=`iso639 -3 -k -n $$t`; \
	    if [ "$$s" != "$$t" ]; then \
	        echo "$$S	$$T	multi30k_test_2017_flickr				datasets/multi30k/dataset/data/task1/raw/test_2017_flickr.$$s	datasets/multi30k/dataset/data/task1/raw/test_2017_flickr.$$t" >> $@; \
	        echo "$$S	$$T	multi30k_test_2017_mscoco				datasets/multi30k/dataset/data/task1/raw/test_2017_mscoco.$$s	datasets/multi30k/dataset/data/task1/raw/test_2017_mscoco.$$t" >> $@; \
	    fi \
	  done \
	done
	echo "eng	deu	multi30k_task2_test_2016				datasets/multi30k/dataset/data/task2/raw/test_2016.en	datasets/multi30k/dataset/data/task2/raw/test_2016.de" >> $@; \
	echo "deu	eng	multi30k_task2_test_2016				datasets/multi30k/dataset/data/task2/raw/test_2016.de	datasets/multi30k/dataset/data/task2/raw/test_2016.en" >> $@; \


