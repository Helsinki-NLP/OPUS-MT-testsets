#-*-makefile-*-
#
# the TICO-19 test set
#


.PHONY: all
all: testsets.tsv

testsets.tsv: testsets
	${MAKE} tico19.tsv tico19-reverse.tsv tico19-multi.tsv
	cat tico19.tsv tico19-reverse.tsv tico19-multi.tsv | sort > $@


## TICO-19 translation benchmark
## from https://tico-19.github.io/index.html

TICO19_TEST = ${patsubst tico19-testset/test/test.%.tsv,testsets/%/tico19-test.en,${wildcard tico19-testset/test/*.tsv}}

.PHONY: tico19-fetch tico19-convert tico19-cleanup
testsets:
	${MAKE} tico19-fetch
	${MAKE} tico19-convert
	${MAKE} tico19-cleanup

tico19-fetch:
	wget https://tico-19.github.io/data/tico19-testset.zip
	unzip tico19-testset.zip
	rm -f tico19-testset.zip

tico19-cleanup:
	rm -fr __MACOSX
	rm -fr tico19-testset

tico19-convert: ${TICO19_TEST}
	mv testsets/en-es-LA testsets/en-es_LA
	mv testsets/en-es_LA/tico19-test.es-LA testsets/en-es_LA/tico19-test.es_LA
	mv testsets/en-es_LA/tico19-test.es-LA.labels testsets/en-es_LA/tico19-test.es_LA.labels
	mv testsets/en-pt-BR testsets/en-pt_BR
	mv testsets/en-pt_BR/tico19-test.pt-BR testsets/en-pt_BR/tico19-test.pt_BR
	mv testsets/en-pt_BR/tico19-test.pt-BR.labels testsets/en-pt_BR/tico19-test.pt_BR.labels


${TICO19_TEST}: testsets/%/tico19-test.en: tico19-testset/test/test.%.tsv
	mkdir -p ${dir $@}
	cut -f1 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' | tr "-" "_" > $@.labels
	cut -f2 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' | tr "-" "_" > ${@:en=${patsubst testsets/en-%/,%,$(dir $@)}}.labels
	cut -f3 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > $@
	cut -f4 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > ${@:en=${patsubst testsets/en-%/,%,$(dir $@)}}
	cut -f5- $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > $@.info


TICO19_LANGS := $(sort $(shell ls testsets | cut -f2 -d-))

tico19.tsv:
	for l in ${TICO19_LANGS}; do \
	  L=`iso639 -3 -k -n $$l`; \
	  echo "eng	$$L	tico19-test				datasets/tioc19/tico19-test.en	datasets/tioc19/tico19-test.$$l" >> $@; \
	done

tico19-reverse.tsv:
	for l in ${TICO19_LANGS}; do \
	  L=`iso639 -3 -k -n $$l`; \
	  echo "$$L	eng	tico19-test			 	datasets/tioc19/tico19-test.$$l	datasets/tioc19/tico19-test.en" >> $@; \
	done

tico19-multi.tsv:
	for s in ${TICO19_LANGS}; do \
	  S=`iso639 -3 -k -n $$s`; \
	  echo "add $$S"; \
	  for t in ${TICO19_LANGS}; do \
	    if [ $$s != $$t ]; then \
	      T=`iso639 -3 -k -n $$t`; \
	      echo "$$S	$$T	tico19-test			 	datasets/tioc19/tico19-test.$$s	datasets/tioc19/tico19-test.$$t" >> $@; \
	    fi \
	  done \
	done
