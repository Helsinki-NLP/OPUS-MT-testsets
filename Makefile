#-*-makefile-*-
#
# maintain various MT testsets


DATASETS = wmt tatoeba flores1 flores101

all:
	${MAKE} ${DATASETS}
	${MAKE} upgrade-2-letter-files
	${MAKE} label-files



## create default files for language labels
## (just add the language of the file as default)

TESTFILES = $(filter-out %.info,$(filter-out %.labels,${wildcard testsets/*-*/*.*}))
LABELFILES = ${patsubst %,%.labels,${TESTFILES}}

.PHONY: label-files
label-files: ${LABELFILES}
${LABELFILES}:
	for l in `seq ${shell cat $(@:.labels=) | wc -l}`; do \
	  echo ${lastword ${subst ., ,$(@:.labels=)}} >> $@; \
	done


## some sanity checking and cleaning up of files with problems

CHECKED_FILES = ${sort ${basename ${TESTFILES}}}
sanity-check: ${CHECKED_FILES}
	-rmdir testsets/* 2>/dev/null

${CHECKED_FILES}:
	@if [ `ls $@.* | grep -v '.labels' | grep -v '.info' | grep -v '.upgraded' | wc -l` -ne 2 ]; then \
	  echo "$@ does not have 2 language files"; \
	  rm -f $@.*; \
	else \
	  if [ `wc -l $@.* | grep -v total | grep -v '.info' | grep -v '.upgraded' | sed 's/^ *//' | cut -f1 -d' ' | sort -u | wc -l` -ne 1 ]; then \
	    echo "line count for $@.* does not match!"; \
	    rm -f $@.*; \
	  fi \
	fi



## copy test sets with 2-letter codes to iso-639-3 based test sets
## TODO: this is slow because of the repeated call to the slow iso639 script

2_LETTER_FILES 		= ${wildcard testsets/??-??/*.??}
2_LETTER_FILES_UPGRADED = ${patsubst %,%.upgraded,${2_LETTER_FILES}}

.PHONY: upgrade-2-letter-files
upgrade-2-letter-files: ${2_LETTER_FILES_UPGRADED}

${2_LETTER_FILES_UPGRADED}: %.upgraded: %
	@( d=$(shell iso639 -3 -p ${word 2,$(subst /, ,$<)}); \
	  l=$(shell iso639 -3 -p ${lastword 2,$(subst ., ,$<)}); \
	  if [ ! -e testsets/$$d/${basename ${notdir $<}}.$$l ]; then \
	    echo "cp $< testsets/$$d/${basename ${notdir $<}}.$$l"; \
	    mkdir -p testsets/$$d; \
	    cp $< testsets/$$d/${basename ${notdir $<}}.$$l; \
	  else \
	    echo "testsets/$$d/${basename ${notdir $<}}.$$l exists already"; \
	  fi )
#	touch $@




## add various WMT data sets

.PHONY: wmt
wmt:
	wget http://data.statmt.org/wmt21/translation-task/dev.tgz
	wget http://data.statmt.org/wmt21/translation-task/test.tgz
	tar -xzf dev.tgz
	tar -xzf test.tgz
	rm -f dev.tgz test.tgz
	${MAKE} wmt-multilingual
	${MAKE} wmt-sgm
	${MAKE} wmt-wikipedia
	${MAKE} wmt-dev-xml
	${MAKE} wmt-test-xml


## TODO: should we keep all Tatoeba test set releases
##       even if there is a large overlap between them?
## TODO: should we at least remove the ones where older ones
##       are identical?

.PHONY: tatoeba
tatoeba:
	wget https://object.pouta.csc.fi/Tatoeba-Challenge-devtest/test.tar
	tar -xf test.tar
	rm -f test.tar
	${MAKE} tatoeba-files

TATOEBA_TEST_FILES = ${wildcard data/release/test/*/*.txt.gz}
TATOEBA_TEST_CONVERTED = ${patsubst %.txt.gz,%.converted,${TATOEBA_TEST_FILES}}

.PHONY: tatoeba-files
tatoeba-files: ${TATOEBA_TEST_CONVERTED}
${TATOEBA_TEST_CONVERTED}: %.converted: %.txt.gz
	s=$(firstword $(subst -, ,$(subst .,,$(suffix ${basename $@})))); \
	t=$(lastword $(subst -, ,$(subst .,,$(suffix ${basename $@})))); \
	b=${basename ${basename $(notdir $@)}}; \
	mkdir -p testsets/$$s-$$t; \
	if [ "$$s" == "$$t" ]; then \
	  gzip -cd <  $< | cut -f3 > testsets/$$s-$$t/$$b.$${s}1; \
	  gzip -cd <  $< | cut -f4 > testsets/$$s-$$t/$$b.$${t}2; \
	  gzip -cd <  $< | cut -f1 > testsets/$$s-$$t/$$b.$${s}1.labels; \
	  gzip -cd <  $< | cut -f2 > testsets/$$s-$$t/$$b.$${t}2.labels; \
	else \
	  gzip -cd <  $< | cut -f3 > testsets/$$s-$$t/$$b.$$s; \
	  gzip -cd <  $< | cut -f4 > testsets/$$s-$$t/$$b.$$t; \
	  gzip -cd <  $< | cut -f1 > testsets/$$s-$$t/$$b.$$s.labels; \
	  gzip -cd <  $< | cut -f2 > testsets/$$s-$$t/$$b.$$t.labels; \
	  mkdir -p testsets/$$t-$$s; \
	  rsync testsets/$$s-$$t/$$b.$$s testsets/$$t-$$s/$$b.$$s; \
	  rsync testsets/$$s-$$t/$$b.$$t testsets/$$t-$$s/$$b.$$t; \
	  rsync testsets/$$s-$$t/$$b.$$s.labels testsets/$$t-$$s/$$b.$$s.labels; \
	  rsync testsets/$$s-$$t/$$b.$$t.labels testsets/$$t-$$s/$$b.$$t.labels; \
	fi
	touch $@



WMT_MULTILINGUAL_TXT = 	news-test2008 newsdev2014 \
			newssyscomb2009 newstest2009 newstest2010 \
			newstest2011 newstest2012 newstest2013

# WMT_SGM = ${sort $(subst -src,,$(subst -ref,,$(basename $(basename $(notdir $(wildcard dev/sgm/*.sgm))))))}
WMT_SGM = ${sort $(subst -src,,$(basename $(basename $(notdir $(wildcard dev/sgm/*-????-src.??.sgm)))))}

.PHONY: wmt-sgm ${WMT_SGM}
wmt-sgm: ${WMT_SGM}
${WMT_SGM}:
	( for s in $(subst .,,$(suffix $(basename ${wildcard dev/sgm/$@-src.??.sgm}))); do \
	    for t in $(subst .,,$(suffix $(basename ${wildcard dev/sgm/$@-ref.??.sgm}))); do \
	      if [ "$$s" != "$$t" ]; then \
	  	echo "make testsets/$$s-$$t/$@"; \
	  	mkdir -p testsets/$$s-$$t; \
	  	if [ ! -e testsets/$$s-$$t/$@.$$s ]; then \
	 	  scripts/input-from-sgm.perl < dev/sgm/$@-src.$$s.sgm > testsets/$$s-$$t/$@.$$s; \
	  	else \
	  	  echo "testsets/$$s-$$t/$@.$$s exists already"; \
	  	fi; \
	  	if [ ! -e testsets/$$s-$$t/$@.$$t ]; then \
	  	  scripts/input-from-sgm.perl < dev/sgm/$@-ref.$$t.sgm > testsets/$$s-$$t/$@.$$t; \
	  	else \
	  	  echo "testsets/$$s-$$t/$@.$$t exists already"; \
	  	fi; \
	      fi \
	    done \
	  done )

.PHONY: wmt-multilingual ${WMT_MULTILINGUAL_TXT}
wmt-multilingual: ${WMT_MULTILINGUAL_TXT}
${WMT_MULTILINGUAL_TXT}:
	for s in $(sort $(subst ., ,$(suffix ${notdir ${wildcard dev/sgm/$@.*}}))); do \
	  for t in $(sort $(subst ., ,$(suffix ${notdir ${wildcard dev/sgm/$@.*}}))); do \
	    if [ "$$s" != "$$t" ]; then \
		echo "do $$s-$$t for $@"; \
		mkdir -p testsets/$$s-$$t; \
		if [ ! -e testsets/$$s-$$t/$@.$$s ]; then \
		  cp dev/sgm/$@.$$s  testsets/$$s-$$t/$@.$$s; \
		else \
		  echo "testsets/$$s-$$t/$@.$$s exists already"; \
		fi; \
		if [ ! -e testsets/$$s-$$t/$@.$$t ]; then \
		  cp dev/sgm/$@.$$t  testsets/$$s-$$t/$@.$$t; \
		else \
		  echo "testsets/$$s-$$t/$@.$$t exists already"; \
		fi; \
	    fi \
	  done \
	done

wmt-wikipedia:
	mkdir -p testsets/km-en testsets/en-km
	mkdir -p testsets/ps-en testsets/en-ps
	rsync dev/sgm/wikipedia.dev.km-en.en testsets/en-km/wikipedia.dev.km-en.en
	rsync dev/sgm/wikipedia.dev.km-en.km testsets/en-km/wikipedia.dev.km-en.km
	rsync dev/sgm/wikipedia.dev.km-en.en testsets/km-en/wikipedia.dev.km-en.en
	rsync dev/sgm/wikipedia.dev.km-en.km testsets/km-en/wikipedia.dev.km-en.km
	rsync dev/sgm/wikipedia.dev.ps-en.en testsets/en-ps/wikipedia.dev.ps-en.en
	rsync dev/sgm/wikipedia.dev.ps-en.ps testsets/en-ps/wikipedia.dev.ps-en.ps
	rsync dev/sgm/wikipedia.dev.ps-en.en testsets/ps-en/wikipedia.dev.ps-en.en
	rsync dev/sgm/wikipedia.dev.ps-en.ps testsets/ps-en/wikipedia.dev.ps-en.ps
	rsync dev/sgm/wikipedia.devtest.km-en.en testsets/en-km/wikipedia.devtest.km-en.en
	rsync dev/sgm/wikipedia.devtest.km-en.km testsets/en-km/wikipedia.devtest.km-en.km
	rsync dev/sgm/wikipedia.devtest.km-en.en testsets/km-en/wikipedia.devtest.km-en.en
	rsync dev/sgm/wikipedia.devtest.km-en.km testsets/km-en/wikipedia.devtest.km-en.km
	rsync dev/sgm/wikipedia.devtest.ps-en.en testsets/en-ps/wikipedia.devtest.ps-en.en
	rsync dev/sgm/wikipedia.devtest.ps-en.ps testsets/en-ps/wikipedia.devtest.ps-en.ps
	rsync dev/sgm/wikipedia.devtest.ps-en.en testsets/ps-en/wikipedia.devtest.ps-en.en
	rsync dev/sgm/wikipedia.devtest.ps-en.ps testsets/ps-en/wikipedia.devtest.ps-en.ps


wmt-flores:
	for s in bn hi xh zu; do \
	  for t in bn hi xh zu; do \
	    if [ "$$s" != "$$t" ]; then \
		echo "make testsets/$$s-$$t/flores-dev"; \
		mkdir -p testsets/$$s-$$t; \
		scripts/input-from-sgm.perl < dev/sgm/flores-dev-$$s-src.sgm > testsets/$$s-$$t/flores-dev.$$s; \
		scripts/input-from-sgm.perl < dev/sgm/flores-dev-$$t-ref.sgm > testsets/$$s-$$t/flores-dev.$$t; \
	    fi \
	  done \
	done


WMT_DEV_XML = ${patsubst %.xml,%.converted,${wildcard dev/xml/*.xml}}

.PHONY: wmt-dev-xml
wmt-dev-xml: ${WMT_DEV_XML}
${WMT_DEV_XML}: %.converted: %.xml
	mkdir -p testsets/$(subst .,,$(suffix ${basename $<}))
	dev/xml/extract.py -o testsets/$(subst .,,$(suffix ${basename $<}))/${basename ${notdir $<}} $<
	touch $@



WMT_TEST_XML = ${patsubst %.xml,%.converted,${wildcard test/*.xml}}

.PHONY: wmt-test-xml
wmt-test-xml: ${WMT_TEST_XML}
${WMT_TEST_XML}: %.converted: %.xml
	mkdir -p testsets/$(subst .,,$(suffix ${basename $<}))
	dev/xml/extract.py -o testsets/$(subst .,,$(suffix ${basename $<}))/${basename ${notdir $<}} $< 
	touch $@



## flores101

.PHONY: flores101
flores101:
	wget https://dl.fbaipublicfiles.com/flores101/dataset/flores101_dataset.tar.gz
	tar -C testsets -xzf flores101_dataset.tar.gz
	rm -f flores101_dataset.tar.gz
	${MAKE} flores101-file-links

FLORES101_DEV_FILES = $(wildcard testsets/flores101_dataset/dev/*.dev)
FLORES101_DEVTEST_FILES = $(wildcard testsets/flores101_dataset/devtest/*.devtest)

FLORES101_DEV_LABELS = ${patsubst %.dev,%.labels,$(FLORES101_DEV_FILES)}
FLORES101_DEVTEST_LABELS = ${patsubst %.devtest,%.labels,$(FLORES101_DEVTEST_FILES)}

## make symbolic links for all language combinations

.PHONY: flores101-file-links
flores101-file-links: ${FLORES101_DEV_LABELS} ${FLORES101_DEVTEST_LABELS}
	-for s in ${basename ${notdir ${FLORES101_DEV_LABELS}}}; do \
	  for t in ${basename ${notdir ${FLORES101_DEV_LABELS}}}; do \
	    if [ "$$s" != "$$t" ]; then \
		echo "create links for $$s-$$t/flores101"; \
		mkdir -p testsets/$$s-$$t; \
		ln -s ../flores101_dataset/dev/$$s.dev testsets/$$s-$$t/flores101-dev.$$s; \
		ln -s ../flores101_dataset/dev/$$s.labels testsets/$$s-$$t/flores101-dev.$$s.labels; \
		ln -s ../flores101_dataset/dev/$$t.dev testsets/$$s-$$t/flores101-dev.$$t; \
		ln -s ../flores101_dataset/dev/$$t.labels testsets/$$s-$$t/flores101-dev.$$t.labels; \
		ln -s ../flores101_dataset/devtest/$$s.devtest testsets/$$s-$$t/flores101-devtest.$$s; \
		ln -s ../flores101_dataset/devtest/$$s.labels testsets/$$s-$$t/flores101-devtest.$$s.labels; \
		ln -s ../flores101_dataset/devtest/$$t.devtest testsets/$$s-$$t/flores101-devtest.$$t; \
		ln -s ../flores101_dataset/devtest/$$t.labels testsets/$$s-$$t/flores101-devtest.$$t.labels; \
	    fi \
	  done \
	done

## language labels
## TODO: do we really need those?

.PHONY: flores101-dev-labels
flores101-dev-labels: ${FLORES101_DEV_LABELS}
${FLORES101_DEV_LABELS}: %.labels: %.dev
	for l in `seq ${shell cat $< | wc -l}`; do \
	  echo ${basename ${notdir $@}} >> $@; \
	done

.PHONY: flores101-devtest-labels
flores101-devtest-labels: ${FLORES101_DEVTEST_LABELS}
${FLORES101_DEVTEST_LABELS}: %.labels: %.devtest
	for l in `seq ${shell cat $< | wc -l}`; do \
	  echo ${basename ${notdir $@}} >> $@; \
	done





.PHONY: flores1
flores1:
	wget -O flores_test_sets.tgz https://github.com/facebookresearch/flores/blob/main/floresv1/data/flores_test_sets.tgz?raw=true
	tar -xzf flores_test_sets.tgz
	rm -f flores_test_sets.tgz
	for s in km ne ps si; do \
	  mkdir -p testsets/$$s-en testsets/en-$$s; \
	  rsync flores_test_sets/wikipedia.dev.$$s-en.en testsets/en-$$s/wikipedia.dev.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.dev.$$s-en.$$s testsets/en-$$s/wikipedia.dev.$$s-en.$$s; \
	  rsync flores_test_sets/wikipedia.devtest.$$s-en.en testsets/en-$$s/wikipedia.devtest.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.devtest.$$s-en.$$s testsets/en-$$s/wikipedia.devtest.$$s-en.$$s; \
	  rsync flores_test_sets/wikipedia.dev.$$s-en.en testsets/$$s-en/wikipedia.dev.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.dev.$$s-en.$$s testsets/$$s-en/wikipedia.dev.$$s-en.$$s; \
	  rsync flores_test_sets/wikipedia.devtest.$$s-en.en testsets/$$s-en/wikipedia.devtest.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.devtest.$$s-en.$$s testsets/$$s-en/wikipedia.devtest.$$s-en.$$s; \
	done
	for s in ne si; do \
	  mkdir -p testsets/$$s-en testsets/en-$$s; \
	  rsync flores_test_sets/wikipedia.test.$$s-en.en testsets/en-$$s/wikipedia.test.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.test.$$s-en.$$s testsets/en-$$s/wikipedia.test.$$s-en.$$s; \
	  rsync flores_test_sets/wikipedia.test.$$s-en.en testsets/$$s-en/wikipedia.test.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.test.$$s-en.$$s testsets/$$s-en/wikipedia.test.$$s-en.$$s; \
	done



