

2LETTER_DIRS  = ${wildcard ??-??} ${wildcard ??_??-??} ${wildcard ??-??_??} ${wildcard ??_??-??_??} ${wildcard ??-??-??}
2LETTER_FILES = ${sort ${wildcard */*.??} ${wildcard */*.??_??} ${wildcard */*.??-??}}

TXT = $(patsubst %.sgm,%,${wildcard *.sgm})

all: ${TXT}




## Tatoeba challenge data

TATOEBA_VERSION = v2020-07-28
TATOEBA_DOWNLAOD = https://object.pouta.csc.fi/Tatoeba-Challenge/test-${TATOEBA_VERSION}.tar

.PHONY: tatoeba tatoeba-fetch tatoeba-convert tatoeba-cleanup
tatoeba:
	${MAKE} tatoeba-fetch
	${MAKE} tatoeba-convert
	${MAKE} tatoeba-cleanup

tatoeba-fetch:
	mkdir -p tmp-tatoeba
	wget -O tmp-tatoeba/test-${TATOEBA_VERSION}.tar ${TATOEBA_DOWNLAOD}
	tar -C tmp-tatoeba -xf tmp-tatoeba/test-${TATOEBA_VERSION}.tar

TATOEBA_TEST = ${wildcard tmp-tatoeba/data/test-${TATOEBA_VERSION}/*/test.txt}
TATOEBA_BASE = ${patsubst tmp-tatoeba/data/test-${TATOEBA_VERSION}/%/test.txt,%/tatoeba-test-${TATOEBA_VERSION},${TATOEBA_TEST}}

tatoeba-convert: ${TATOEBA_BASE}

tatoeba-cleanup:
	rm -fr tmp-tatoeba

tatoeba-print:
	@echo ${TATOEBA_BASE}

${TATOEBA_BASE}: %/tatoeba-test-${TATOEBA_VERSION}: tmp-tatoeba/data/test-${TATOEBA_VERSION}/%/test.txt
	mkdir -p ${dir $@}
	cut -f1 $< > $@.$(firstword $(subst -, ,${patsubst %/tatoeba-test-${TATOEBA_VERSION},%,$@})).labels
	cut -f2 $< > $@.$(lastword $(subst -, ,${patsubst %/tatoeba-test-${TATOEBA_VERSION},%,$@})).labels
	cut -f3 $< > $@.$(firstword $(subst -, ,${patsubst %/tatoeba-test-${TATOEBA_VERSION},%,$@}))
	cut -f4 $< > $@.$(lastword $(subst -, ,${patsubst %/tatoeba-test-${TATOEBA_VERSION},%,$@}))




## TICO-19 translation benchmark
## from https://tico-19.github.io/index.html

TICO19_TEST = ${patsubst tico19-testset/test/test.%.tsv,%/tico19-test.en,${wildcard tico19-testset/test/*.tsv}}

.PHONY: tico19 tico19-fetch tico19-convert tico19-cleanup
tico19:
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

${TICO19_TEST}: %/tico19-test.en: tico19-testset/test/test.%.tsv
	mkdir -p ${dir $@}
	cut -f1 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > $@.labels
	cut -f2 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > ${@:en=${patsubst en-%/,%,$(dir $@)}}.labels
	cut -f3 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > $@
	cut -f4 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > ${@:en=${patsubst en-%/,%,$(dir $@)}}
	cut -f5- $< | tail -n +2 | sed 's/^ *//;s/ *$$//' > $@.info




list-files:
	@echo "${2LETTER_FILES}" | tr ' ' "\n"

missing-files:
	for f in ${2LETTER_FILES}; do \
	  d=`dirname $$f`; \
	  b=`basename $$f`; \
	  s=`echo "$$d" | cut -f1 -d '-'`; \
	  t=`echo "$$d" | cut -f2 -d '-'`; \
	  S=`echo $$b | sed "s/.\(..\)/.$$s/"`; \
	  T=`echo $$b | sed "s/.\(..\)/.$$t/"`; \
	  if [ ! -e $$d/$$S ]; then \
	    echo "not found: $$d/$$S"; \
	    if [ -e $$t-$$s/$$S ]; then \
	      echo "but found: $$t-$$s/$$S ... copying"; \
	      cp $$t-$$s/$$S $$d/$$S; \
	    fi \
	  fi; \
	  if [ ! -e $$d/$$T ]; then \
	    echo "not found: $$d/$$T"; \
	    if [ -e $$t-$$s/$$T ]; then \
	      echo "but found: $$t-$$s/$$T ... copying"; \
	      cp $$t-$$s/$$T $$d/$$T; \
	    fi \
	  fi; \
	done



## link iso639-1 codes to iso-639-3 codes (using macro-languages)
## this is very slow but only needs to be done once ....
iso-codes:
	for f in ${2LETTER_FILES}; do \
	  l=`echo $$f | sed 's/^.*\.\(..\)$$/\1/;s/^.*\.\(..\)[-?]\(..\)$$/\1_\2/'`; \
	  L=`iso639 -m -n $$l`; \
	  F=`echo $$f | sed "s/\.\(..\)$$/.$$L/;s/\.\(..\)[-?]\(..\)$$/.$$L/"`; \
	  d=`dirname $$f`; \
	  D=`iso639 -m -n -p $$d`; \
	  B=`basename $$F`; \
	  if [ ! -e $$D/$$B ]; then \
	    echo "make $$D/$$B"; \
	    mkdir -p $$D; \
	    cp $$f $$D/$$B; \
	  fi \
	done

iso-code-dirs:
	for d in ${2LETTER_DIRS}; do \
	  l=`iso639 -p -m -n $$d`; \
	  if [ ! -e $$l ]; then \
	    echo "make $$l"; \
	    ln -s $$d $$l; \
	  fi \
	done


${TXT}: %: %.sgm
	grep '</seg>' $< |\
	sed 's/<[^>]*>//g' |\
	sed 's/^ *//' |\
	sed 's/ *$$//' |\
	sed 's/  */ /g' |\
	sed	-e 's/&quot;/"/g' \
		-e 's/&gt;/>/g' \
		-e 's/&lt;/</g' \
		-e 's/&amp;/&/g' \
		-e "s/&apos;/'/g" > $@


fix:
	for s in ${wildcard *-src*}; do \
	  mv $$s `echo $$s | sed 's/-src//'`; \
	done
	for s in ${wildcard *-ref*}; do \
	  mv $$s `echo $$s | sed 's/-ref//'`; \
	done


