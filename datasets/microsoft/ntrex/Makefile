#-*-makefile-*-
#
# the NTREX devtest
#


.PHONY: all
all: testsets.tsv

testsets.tsv: ntrex128.tsv ntrex128-multiling.tsv
	sort -u  $^ > $@

NTREX_LANGS = $(patsubst newstest2019-ref.%.txt,%,$(notdir $(wildcard NTREX/NTREX-128/newstest2019-ref.*)))

NTREX:
	git clone https://github.com/MicrosoftTranslator/NTREX.git
	cd NTREX/NTREX-128 && mv newstest2019-ref.zho-CN.txt newstest2019-ref.zho_Hans.txt
	cd NTREX/NTREX-128 && mv newstest2019-ref.zho-TW.txt newstest2019-ref.zho_Hant.txt
	rm -fr NTREX/.git*
	git add NTREX/NTREX-128/*.txt

ntrex128.tsv:
	for l in ${NTREX_LANGS}; do \
	  L=`echo $$l | tr '-' '_'`; \
	  if [ $$l == spa ]; then \
	    echo "eng	$$L	ntrex128				datasets/microsoft/NTREX/NTREX-128/newstest2019-src.eng.txt	datasets/microsoft/NTREX/NTREX-128/newstest2019-ref.$$l.txt	datasets/microsoft/NTREX/NTREX-128/newstest2019-ref-2.$$l.txt" >> $@; \
	  else \
	    echo "eng	$$L	ntrex128				datasets/microsoft/NTREX/NTREX-128/newstest2019-src.eng.txt	datasets/microsoft/NTREX/NTREX-128/newstest2019-ref.$$l.txt" >> $@; \
	  fi; \
	  echo "$$L	eng	ntrex128				datasets/microsoft/NTREX/NTREX-128/newstest2019-ref.$$l.txt	datasets/microsoft/NTREX/NTREX-128/newstest2019-src.eng.txt" >> $@; \
	done

ntrex128-multiling.tsv:
	for s in ${NTREX_LANGS}; do \
	  S=`echo $$s | tr '-' '_'`; \
	  echo "add $$S"; \
	  for t in ${NTREX_LANGS}; do \
	    if [ $$s != $$t ]; then \
	      T=`echo $$t | tr '-' '_'`; \
	      echo "$$S	$$T	ntrex128				datasets/microsoft/NTREX/NTREX-128/newstest2019-ref.$$s.txt	datasets/microsoft/NTREX/NTREX-128/newstest2019-ref.$$t.txt" >> $@; \
	    fi \
	  done \
	done
