#-*-makefile-*-
#
# maintain various MT testsets


DATASETS = wmt tatoeba flores1 flores101 multi30k tico19

TESTSET_TSVS := $(shell find datasets -name testsets.tsv)


all: testsets.tsv benchmarks.tsv langpairs.tsv langpair2benchmark.tsv benchmark2langpair.tsv


all-old:
	${MAKE} ${DATASETS}
	${MAKE} upgrade-2-letter-files
	${MAKE} check-label-files


index.txt: testsets
	find testsets -type f | \
	grep -v '.labels$$' | grep -v '.info$$' | \
	xargs wc > $@

testsets.tsv: ${TESTSET_TSVS}
	find datasets -name testsets.tsv -exec cat {} \; |\
	sort -u > $@

benchmarks.tsv: testsets.tsv
	cut -f3 $< | sort -u > $@

langpairs.tsv: testsets.tsv
	cut -f1,2 $< | sort -u > $@

langpair2benchmark.tsv: testsets.tsv
	scripts/langpair_benchmarks.pl < $< > $@

benchmark2langpair.tsv: testsets.tsv
	scripts/benchmark_langpairs.pl < $< > $@


## check whether we really need the language-label file
## (remove the ones that have only one language,
##  which is the same as the language of the test set)

CHECK_LABELFILES = ${patsubst %.labels,%.check,${wildcard testsets/*-*/*.labels}}

check-label-files: ${CHECK_LABELFILES}
${CHECK_LABELFILES}: %.check: %.labels
	@if [ -e $< ]; then \
	  if [ ${shell sort -u $< | wc -l} -eq 1 ]; then \
	    if [ "${shell sort -u $<}" == "$(subst .,,$(suffix ${basename $<}))" ]; then \
		echo "rm -f $<"; \
		rm -f $<; \
	    else \
		echo "language label is different from the the language file in $<"; \
	    fi \
	  else \
	    echo "more than one language label in $<"; \
	  fi \
	fi



## some sanity checking and cleaning up of files with problems

TESTFILES = $(filter-out %.info,$(filter-out %.labels,${wildcard testsets/*-*/*.*}))
CHECKED_FILES = ${sort ${basename ${TESTFILES}}}
sanity-check: ${CHECKED_FILES}
	-rmdir testsets/* 2>/dev/null

${CHECKED_FILES}:
	@if [ `ls $@.* | grep -v '.labels' | grep -v '.info' | wc -l` -ne 2 ]; then \
	  echo "$@ does not have 2 language files"; \
	  rm -f $@.*; \
	else \
	  if [ `wc -l $@.* | grep -v total | grep -v '.info' | sed 's/^ *//' | cut -f1 -d' ' | sort -u | wc -l` -ne 1 ]; then \
	    echo "line count for $@.* does not match!"; \
	    rm -f $@.*; \
	  fi \
	fi



## copy test sets with 2-letter codes to iso-639-3 based test sets
## TODO: this is slow because of the repeated call to the slow iso639 script

2_LETTER_FILES 		= ${wildcard testsets/??-??/*.??}
2_LETTER_FILES_UPGRADED = ${patsubst testsets/%,log/%.upgraded,${2_LETTER_FILES}}

.PHONY: upgrade-2-letter-files
upgrade-2-letter-files: ${2_LETTER_FILES_UPGRADED}

${2_LETTER_FILES_UPGRADED}: log/%.upgraded: testsets/%
	@( d=$(shell iso639 -3 -p ${word 2,$(subst /, ,$<)}); \
	  l=$(shell iso639 -3 -p ${lastword 2,$(subst ., ,$<)}); \
	  if [ ! -e testsets/$$d/${basename ${notdir $<}}.$$l ]; then \
	    echo "cp $< testsets/$$d/${basename ${notdir $<}}.$$l"; \
	    mkdir -p testsets/$$d; \
	    cp $< testsets/$$d/${basename ${notdir $<}}.$$l; \
	  else \
	    echo "testsets/$$d/${basename ${notdir $<}}.$$l exists already"; \
	  fi )
	mkdir -p ${dir $@}
	touch $@



find-broken-links:
	find testsets -type l -exec test ! -e {} \; -print

remove-broken-links:
	find testsets -type l -exec test ! -e {} \; -print | xargs rm -f


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
	${MAKE} tatoeba-remove-identicals

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
	  rm -f testsets/$$s-$$t/$$b.$${s}1 testsets/$$s-$$t/$$b.$${t}2; \
	  rm -f testsets/$$s-$$t/$$b.$${s}1.labels testsets/$$s-$$t/$$b.$${t}2.labels; \
	  gzip -cd <  $< | cut -f3 > testsets/$$s-$$t/$$b.$${s}1; \
	  gzip -cd <  $< | cut -f4 > testsets/$$s-$$t/$$b.$${t}2; \
	  gzip -cd <  $< | cut -f1 > testsets/$$s-$$t/$$b.$${s}1.labels; \
	  gzip -cd <  $< | cut -f2 > testsets/$$s-$$t/$$b.$${t}2.labels; \
	else \
	  rm -f testsets/$$s-$$t/$$b.$$s testsets/$$s-$$t/$$b.$$t; \
	  rm -f testsets/$$s-$$t/$$b.$$s.labels testsets/$$s-$$t/$$b.$$t.labels; \
	  gzip -cd <  $< | cut -f3 > testsets/$$s-$$t/$$b.$$s; \
	  gzip -cd <  $< | cut -f4 > testsets/$$s-$$t/$$b.$$t; \
	  gzip -cd <  $< | cut -f1 > testsets/$$s-$$t/$$b.$$s.labels; \
	  gzip -cd <  $< | cut -f2 > testsets/$$s-$$t/$$b.$$t.labels; \
	  if [ ! -e testsets/$$t-$$s/$$b.$$s ] && [ ! -e testsets/$$t-$$s/$$b.$$t ]; then \
	    mkdir -p testsets/$$t-$$s; \
	    cd testsets/$$t-$$s; \
	    ln -s ../$$s-$$t/$$b.$$s .; \
	    ln -s ../$$s-$$t/$$b.$$t .; \
	    ln -s ../$$s-$$t/$$b.$$s.labels .; \
	    ln -s ../$$s-$$t/$$b.$$t.labels .; \
	    cd ../..; \
	  fi \
	fi
	touch $@

## OLD: make physical copies, NEW: just symbolic links (see above)
##
#	  rsync testsets/$$s-$$t/$$b.$$s testsets/$$t-$$s/$$b.$$s; \
#	  rsync testsets/$$s-$$t/$$b.$$t testsets/$$t-$$s/$$b.$$t; \
#	  rsync testsets/$$s-$$t/$$b.$$s.labels testsets/$$t-$$s/$$b.$$s.labels; \
#	  rsync testsets/$$s-$$t/$$b.$$t.labels testsets/$$t-$$s/$$b.$$t.labels;

TATOEBA_LANGPAIRS = ${sort ${dir ${wildcard testsets/*/tatoeba-test-*}}}

## remove testsets that are identical
## TODO: we now also do sorting because some releases are shuffled
##  ---> is that a problem? (not really I guess)
tatoeba-remove-identicals:
	for d in ${TATOEBA_LANGPAIRS}; do \
	  echo "check $$d and remove identical tatoeba files"; \
	  s=`echo $$d | cut -f2 -d/ | cut -f1 -d-`; \
	  t=`echo $$d | cut -f2 -d/ | cut -f2 -d-`; \
	  if [ $$s == $$t ]; then \
	    s="$${s}1"; t="$${t}2"; \
	  fi; \
	  S=`ls $$d/tatoeba-test-*.$$s | tail -1`; \
	  T=`ls $$d/tatoeba-test-*.$$t | tail -1`; \
	  if [ -e $$S ] && [ -e $$T ]; then \
	    sort $$S > $$S.sorted; \
	    sort $$T > $$T.sorted; \
	    for a in `ls $$d/tatoeba-test-*.$$s | sed '$$d'`; do \
	      b=`echo "$$a" | sed "s/\.$$s$$/\.$$t/"`; \
	      if [ -e $$a ] && [ -e $$b ]; then \
	        sort $$a > $$a.sorted; \
	        sort $$b > $$b.sorted; \
	        if [ `diff $$S.sorted $$a.sorted | wc -l` -eq 0 ]; then \
	          if [ `diff $$T.sorted $$b.sorted | wc -l` -eq 0 ]; then \
	             echo "rm -f $$a $$b"; \
	             rm -f $$a $$b $$a.labels $$b.labels; \
	          fi; \
	        fi; \
	        rm -f $$a.sorted $$b.sorted; \
	      else \
	        rm -f $$a $$b $$a.labels $$b.labels; \
	      fi \
	    done; \
	    rm -f $$S.sorted $$T.sorted; \
	  fi \
	done



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
	${MAKE} wmt-remove-duplicates
	${MAKE} wmt-wikipedia
	${MAKE} wmt-dev-xml
	${MAKE} wmt-test-xml
	${MAKE} wmt21-ml
	${MAKE} wmt-remove-langpair-id


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

## remove those accidental duplicates from some news test sets
## (this is super slow because of the iso639 script)
wmt-remove-duplicates:
	for f in ${wildcard testsets/*/news*-????.*}; do \
	  S=`echo $$f | cut -f2 -d/ | cut -f1 -d-`; \
	  T=`echo $$f | cut -f2 -d/ | cut -f2 -d-`; \
	  s=`iso639 -2 $$S`; \
	  t=`iso639 -2 $$T`; \
	  b=`echo $$f | cut -f1,2 -d-`; \
	  if [ -e $$b-$$s$$t.$$S ] && [ -e $$b-$$t$$s.$$S ]; then \
	    if [ -e $$b-$$s$$t.$$T ] && [ -e $$b-$$t$$s.$$T ]; then \
	      if [ `diff $$b-$$s$$t.$$S $$b-$$t$$s.$$S | wc -l` -eq 0 ]; then \
	        if [ `diff $$b-$$s$$t.$$T $$b-$$t$$s.$$T | wc -l` -eq 0 ]; then \
	          echo "$$b-$$s$$t $$b-$$t$$s are the same"; \
	 	  echo "rm $$b-$$t$$s.$$S $$b-$$t$$s.$$T"; \
	 	  rm -f $$b-$$t$$s.$$S $$b-$$t$$s.$$T; \
		fi \
	      fi \
	    fi \
	  fi \
	done

wmt-remove-langpair-ids:
	@for f in ${wildcard testsets/*/news*-????.*}; do \
	  n=`echo $$f | sed 's#\(\/news.*\)-....\(\..*\)#\1\2#'`; \
	  if [ -e $$n ]; then \
	    if [ `diff $$f $$n | wc -l` -eq 0 ]; then \
	      echo "git rm $$f"; \
	      git rm $$f; \
	    else \
	      if [ `cat $$f | wc -l` -eq `cat $$n | wc -l` ]; then \
	        echo "git rm $$f"; \
	        git rm $$f; \
	      else \
	        echo "cannot mv $$f $$n"; \
	      fi \
	    fi \
	  else \
	    echo "git mv $$f $$n"; \
	    git mv $$f $$n; \
	  fi \
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


.PHONY: wmt21-ml
wmt21-ml:
	tar xf testsets/wm21ml.tar.gz
	mkdir -p testsets/is-no testsets/is-sv
	grep -v '^<' europeana/test/europeana.test.is.xml    > testsets/is-no/europeana2021.is
	grep -v '^<' europeana/test/europeana.test.is_NO.xml > testsets/is-no/europeana2021.no
	grep -v '^<' europeana/test/europeana.test.is.xml    > testsets/is-sv/europeana2021.is
	grep -v '^<' europeana/test/europeana.test.is_SV.xml > testsets/is-sv/europeana2021.sv
	mkdir -p testsets/nb-is testsets/nb-sv
	grep -v '^<' europeana/test/europeana.test.nb.xml    > testsets/nb-is/europeana2021.nb
	grep -v '^<' europeana/test/europeana.test.nb_IS.xml > testsets/nb-is/europeana2021.is
	grep -v '^<' europeana/test/europeana.test.nb.xml    > testsets/nb-sv/europeana2021.nb
	grep -v '^<' europeana/test/europeana.test.nb_SV.xml > testsets/nb-sv/europeana2021.sv
	mkdir -p testsets/sv-is testsets/sv-nb
	grep -v '^<' europeana/test/europeana.test.sv.xml    > testsets/sv-is/europeana2021.sv
	grep -v '^<' europeana/test/europeana.test.sv_IS.xml > testsets/sv-is/europeana2021.is
	grep -v '^<' europeana/test/europeana.test.sv.xml    > testsets/sv-nb/europeana2021.sv
	grep -v '^<' europeana/test/europeana.test.sv_NB.xml > testsets/sv-nb/europeana2021.nb
	for s in ca it oc ro; do \
	  for t in ca it oc ro; do \
	    if [ "$$s" != "$$t" ]; then \
		mkdir -p testsets/$$s-$$t; \
		grep -v '^<' wikipedia/test/wp.test.$$s.xml > testsets/$$s-$$t/wmt21-ml-wp.$$s; \
		grep -v '^<' wikipedia/test/wp.test.$$t.xml > testsets/$$s-$$t/wmt21-ml-wp.$$t; \
	    fi \
	  done \
	done
	rm -fr europeana wikipedia


## flores101

.PHONY: flores101
flores101:
	wget https://dl.fbaipublicfiles.com/flores101/dataset/flores101_dataset.tar.gz
	tar -C testsets -xzf flores101_dataset.tar.gz
	rm -f flores101_dataset.tar.gz
	mv testsets/flores101_dataset/dev/zho_simpl.dev testsets/flores101_dataset/dev/cmn_Hans.dev
	mv testsets/flores101_dataset/dev/zho_trad.dev testsets/flores101_dataset/dev/cmn_Hant.dev
	mv testsets/flores101_dataset/devtest/zho_simpl.devtest testsets/flores101_dataset/devtest/cmn_Hans.devtest
	mv testsets/flores101_dataset/devtest/zho_trad.devtest testsets/flores101_dataset/devtest/cmn_Hant.devtest
	mv testsets/flores101_dataset/dev/srp.dev testsets/flores101_dataset/dev/srp_Cyrl.dev
	mv testsets/flores101_dataset/devtest/srp.devtest testsets/flores101_dataset/devtest/srp_Cyrl.devtest
	${MAKE} flores101-file-links

FLORES101_DEV_FILES := $(wildcard testsets/flores101_dataset/dev/*.dev)
FLORES101_DEVTEST_FILES := $(wildcard testsets/flores101_dataset/devtest/*.devtest)

## make symbolic links for all language combinations

.PHONY: flores101-file-links
flores101-file-links: ${FLORES101_DEV_FILES} ${FLORES101_DEVTEST_FILES}
	-for s in ${basename ${notdir ${FLORES101_DEV_FILES}}}; do \
	  for t in ${basename ${notdir ${FLORES101_DEV_FILES}}}; do \
	    if [ "$$s" != "$$t" ]; then \
		echo "create links for $$s-$$t/flores101"; \
		mkdir -p testsets/$$s-$$t; \
		ln -s ../flores101_dataset/dev/$$s.dev testsets/$$s-$$t/flores101-dev.$$s; \
		ln -s ../flores101_dataset/dev/$$t.dev testsets/$$s-$$t/flores101-dev.$$t; \
		ln -s ../flores101_dataset/devtest/$$s.devtest testsets/$$s-$$t/flores101-devtest.$$s; \
		ln -s ../flores101_dataset/devtest/$$t.devtest testsets/$$s-$$t/flores101-devtest.$$t; \
	    fi \
	  done \
	done


.PHONY: flores200
flores200:
	wget -O flores200_dataset.tar.gz --trust-server-names https://tinyurl.com/flores200dataset
	tar -C testsets -xzf flores200_dataset.tar.gz
	rm -f flores200_dataset.tar.gz
	${MAKE} flores200-fixes
	${MAKE} flores200-file-links



FLORES200_WITHOUT_VARIANTS := ${shell ls testsets/flores200_dataset/dev | cut -f1 -d_ | sort | uniq -c | grep ' 1 ' | rev | cut -f1 -d' ' | rev}

# remove script extension for languages without variants
# but keep Cyrl for Serbian as there can be Latn as well
# use Mandarin instead of Chinese
# use both msa and zsm

flores200-fixes:
	-mv testsets/flores200_dataset/dev/zho_Hans.dev testsets/flores200_dataset/dev/cmn_Hans.dev
	-mv testsets/flores200_dataset/dev/zho_Hant.dev testsets/flores200_dataset/dev/cmn_Hant.dev
	-mv testsets/flores200_dataset/devtest/zho_Hans.devtest testsets/flores200_dataset/devtest/cmn_Hans.devtest
	-mv testsets/flores200_dataset/devtest/zho_Hant.devtest testsets/flores200_dataset/devtest/cmn_Hant.devtest
	-for l in ${FLORES200_WITHOUT_VARIANTS}; do \
	  mv testsets/flores200_dataset/dev/$${l}_*.dev testsets/flores200_dataset/dev/$$l.dev; \
	  mv testsets/flores200_dataset/devtest/$${l}_*.devtest testsets/flores200_dataset/devtest/$$l.devtest; \
	done
	-mv testsets/flores200_dataset/dev/srp.dev testsets/flores200_dataset/dev/srp_Cyrl.dev
	-mv testsets/flores200_dataset/devtest/srp.devtest testsets/flores200_dataset/devtest/srp_Cyrl.devtest
	-mv testsets/flores200_dataset/dev/arb_Arab.dev testsets/flores200_dataset/dev/ara.dev
	-mv testsets/flores200_dataset/dev/arb_Latn.dev testsets/flores200_dataset/dev/ara_Latn.dev
	-mv testsets/flores200_dataset/devtest/arb_Arab.devtest testsets/flores200_dataset/devtest/ara.devtest
	-mv testsets/flores200_dataset/devtest/arb_Latn.devtest testsets/flores200_dataset/devtest/ara_Latn.devtest
	-cd testsets/flores200_dataset/dev && ln -s zsm.dev msa.dev
	-cd testsets/flores200_dataset/devtest && ln -s zsm.devtest msa.devtest


FLORES200_DEV_FILES := $(wildcard testsets/flores200_dataset/dev/*.dev)
FLORES200_DEVTEST_FILES := $(wildcard testsets/flores200_dataset/devtest/*.devtest)

## make symbolic links for all language combinations

.PHONY: flores200-file-links
flores200-file-links: ${FLORES200_DEV_FILES} ${FLORES200_DEVTEST_FILES}
	-for s in ${basename ${notdir ${FLORES200_DEV_FILES}}}; do \
	  for t in ${basename ${notdir ${FLORES200_DEV_FILES}}}; do \
	    if [ "$$s" != "$$t" ]; then \
		echo "create links for $$s-$$t/flores200"; \
		mkdir -p testsets/$$s-$$t; \
		ln -s ../flores200_dataset/dev/$$s.dev testsets/$$s-$$t/flores200-dev.$$s; \
		ln -s ../flores200_dataset/dev/$$t.dev testsets/$$s-$$t/flores200-dev.$$t; \
		ln -s ../flores200_dataset/devtest/$$s.devtest testsets/$$s-$$t/flores200-devtest.$$s; \
		ln -s ../flores200_dataset/devtest/$$t.devtest testsets/$$s-$$t/flores200-devtest.$$t; \
	    fi \
	  done \
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


.PHONY: multi30k
multi30k:
	git clone https://github.com/multi30k/dataset.git
	for s in cs de en fr; do \
	  for t in cs de en fr; do \
	    if [ "$$s" != "$$t" ]; then \
		mkdir -p testsets/$$s-$$t; \
		gzip -cd dataset/data/task1/raw/test_2016_flickr.$$s.gz > testsets/$$s-$$t/multi30k_test_2016_flickr.$$s; \
		gzip -cd dataset/data/task1/raw/test_2016_flickr.$$t.gz > testsets/$$s-$$t/multi30k_test_2016_flickr.$$t; \
		gzip -cd dataset/data/task1/raw/test_2018_flickr.$$s.gz > testsets/$$s-$$t/multi30k_test_2018_flickr.$$s; \
		gzip -cd dataset/data/task1/raw/test_2018_flickr.$$t.gz > testsets/$$s-$$t/multi30k_test_2018_flickr.$$t; \
	    fi \
	  done \
	done
	for s in de en fr; do \
	  for t in de en fr; do \
	    if [ "$$s" != "$$t" ]; then \
		mkdir -p testsets/$$s-$$t; \
		gzip -cd dataset/data/task1/raw/test_2017_flickr.$$s.gz > testsets/$$s-$$t/multi30k_test_2017_flickr.$$s; \
		gzip -cd dataset/data/task1/raw/test_2017_flickr.$$t.gz > testsets/$$s-$$t/multi30k_test_2017_flickr.$$t; \
		gzip -cd dataset/data/task1/raw/test_2017_mscoco.$$s.gz > testsets/$$s-$$t/multi30k_test_2017_mscoco.$$s; \
		gzip -cd dataset/data/task1/raw/test_2017_mscoco.$$t.gz > testsets/$$s-$$t/multi30k_test_2017_mscoco.$$t; \
	    fi \
	  done \
	done
	mkdir -p testsets/de-en testsets/en-de
	gzip -cd dataset/data/task2/raw/test_2016.1.de.gz  > testsets/de-en/multi30k_task2_test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.2.de.gz >> testsets/de-en/multi30k_task2_test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.3.de.gz >> testsets/de-en/multi30k_task2_test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.4.de.gz >> testsets/de-en/multi30k_task2_test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.5.de.gz >> testsets/de-en/multi30k_task2_test_2016.de
	gzip -cd dataset/data/task2/raw/test_2016.1.en.gz  > testsets/de-en/multi30k_task2_test_2016.en
	gzip -cd dataset/data/task2/raw/test_2016.2.en.gz >> testsets/de-en/multi30k_task2_test_2016.en
	gzip -cd dataset/data/task2/raw/test_2016.3.en.gz >> testsets/de-en/multi30k_task2_test_2016.en
	gzip -cd dataset/data/task2/raw/test_2016.4.en.gz >> testsets/de-en/multi30k_task2_test_2016.en
	gzip -cd dataset/data/task2/raw/test_2016.5.en.gz >> testsets/de-en/multi30k_task2_test_2016.en
	cp testsets/de-en/multi30k_task2_test_2016.de testsets/en-de/multi30k_task2_test_2016.de
	cp testsets/de-en/multi30k_task2_test_2016.en testsets/en-de/multi30k_task2_test_2016.en
	rm -fr dataset


## TICO-19 translation benchmark
## from https://tico-19.github.io/index.html

TICO19_TEST = ${patsubst tico19-testset/test/test.%.tsv,testsets/%/tico19-test.en,${wildcard tico19-testset/test/*.tsv}}

.PHONY: tico19 tico19-fetch tico19-convert tico19-cleanup
tico19:
	${MAKE} tico19-fetch
	${MAKE} tico19-convert
	${MAKE} tico19-reverse
	${MAKE} tico19-cleanup

tico19-fetch:
	wget https://tico-19.github.io/data/tico19-testset.zip
	unzip tico19-testset.zip
	rm -f tico19-testset.zip

tico19-cleanup:
	rm -fr __MACOSX
	rm -fr tico19-testset

tico19-convert: ${TICO19_TEST}

tico19-reverse:
	for l in ${wildcard testsets/*/tico19-test.*}; do \
	  s=`echo $$l | cut -f2 -d'/' | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'/' | cut -f2 -d'-'`; \
	  f=`basename $$l`; \
	  if [ ! -e testsets/$$t-$$s/$$f ]; then \
		echo "link $$f to $$t-$$s"; \
		mkdir -p testsets/$$t-$$s; \
		cd testsets/$$t-$$s; \
		ln -s ../$$s-$$t/$$f .; \
		cd ../.. ; \
	  fi \
	done

${TICO19_TEST}: testsets/%/tico19-test.en: tico19-testset/test/test.%.tsv
	mkdir -p ${dir $@}
	cut -f1 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' | tr "-" "_" > $@.labels
	cut -f2 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' | tr "-" "_" > ${@:en=${patsubst testsets/en-%/,%,$(dir $@)}}.labels
	cut -f3 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > $@
	cut -f4 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > ${@:en=${patsubst testsets/en-%/,%,$(dir $@)}}
	cut -f5- $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > $@.info
