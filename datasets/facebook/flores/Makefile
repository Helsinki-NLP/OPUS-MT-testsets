#-*-makefile-*-
#
# the FLORES devtest
#


.PHONY: all
all: testsets.tsv

testsets.tsv: flores101 flores200
	cat flores101.tsv flores200.tsv >$@


##--------------------
## flores101
##--------------------

.PHONY: flores101
flores101: flores101_dataset
	${MAKE} flores101.tsv


flores101_dataset:
	wget https://dl.fbaipublicfiles.com/flores101/dataset/flores101_dataset.tar.gz
	tar -xzf flores101_dataset.tar.gz
	rm -f flores101_dataset.tar.gz
	rm -fr flores101_dataset/dev
	cd flores101_dataset/devtest && ln -s zho_simpl.devtest cmn_Hans.devtest
	cd flores101_dataset/devtest && ln -s zho_trad.devtest cmn_Hant.devtest
	cd flores101_dataset/devtest && ln -s srp.devtest srp_Cyrl.devtest


FLORES101_LANGS := $(sort $(basename $(notdir $(wildcard flores101_dataset/devtest/*.devtest))))

flores101.tsv: flores101_dataset
	@for s in ${FLORES101_LANGS}; do \
	  echo "add $$s"; \
	  for t in ${FLORES101_LANGS}; do \
	    if [ "$$s" != "$$t" ]; then \
	      echo "$$s	$$t	flores101-devtest				datasets/facebook/flores/flores101_dataset/devtest/$$s.devtest	datasets/facebook/flores/flores101_dataset/devtest/$$t.devtest" >> $@; \
	    fi \
	  done \
	done


.PHONY: flores200
flores200: flores200_dataset
	${MAKE} flores200.tsv


flores200_dataset:
	wget -O flores200_dataset.tar.gz --trust-server-names https://tinyurl.com/flores200dataset
	tar -xzf flores200_dataset.tar.gz
	rm -f flores200_dataset.tar.gz
	rm -fr flores200_dataset/dev
	cd flores200_dataset/devtest && ln -s arb_Arab.devtest ara.devtest
	cd flores200_dataset/devtest && ln -s arb_Latn.devtest ara_Latn.devtest
	cd flores200_dataset/devtest && ln -s zho_Hans.devtest cmn_Hans.devtest
	cd flores200_dataset/devtest && ln -s zho_Hant.devtest cmn_Hant.devtest
	cd flores200_dataset/devtest && ln -s zsm_Latn.devtest msa.devtest


FLORES200_LANGS := $(sort $(basename $(notdir $(wildcard flores200_dataset/devtest/*.devtest))))

## flores200 languages with a mapping to our language codes
## that skip the writing script extension if not necessary

FLORES200_MAPPED_LANGS := $(sort $(shell \
	for l in ${FLORES200_LANGS}; do \
	  L=`echo $$l | cut -f1 -d_`; \
	  if [ "$$L" != "srp" ]; then \
	    if [ `ls flores200_dataset/devtest/$${L}* | wc -l` == 1 ]; then \
	      echo "$$l-$$L"; \
	    else \
	      echo "$$l-$$l"; \
	    fi \
	  else \
	    echo "$$l-$$l"; \
	  fi \
	done ))


flores200.tsv: flores200_dataset
	@for x in ${FLORES200_MAPPED_LANGS}; do \
	  s=`echo $$x | cut -f1 -d-`; \
	  S=`echo $$x | cut -f2 -d-`; \
	  echo "add $$S"; \
	  for y in ${FLORES200_MAPPED_LANGS}; do \
	    if [ "$$x" != "$$y" ]; then \
	      t=`echo $$y | cut -f1 -d-`; \
	      T=`echo $$y | cut -f2 -d-`; \
	      echo "$$S	$$T	flores200-devtest				datasets/facebook/flores/flores200_dataset/devtest/$$s.devtest	datasets/facebook/flores/flores200_dataset/devtest/$$t.devtest" >> $@; \
	    fi \
	  done \
	done




## flores v1 does not seem to exist anymore
## (probably because it is part of flores101 and flores200)

.PHONY: flores1
flores.tsv:
	wget -O flores_test_sets.tgz https://github.com/facebookresearch/flores/blob/main/floresv1/data/flores_test_sets.tgz?raw=true
	tar -xzf flores_test_sets.tgz
	rm -f flores_test_sets.tgz
	for s in km ne ps si; do \
	  mkdir -p testsets/$$s-en testsets/en-$$s; \
	  rsync flores_test_sets/wikipedia.devtest.$$s-en.en testsets/en-$$s/wikipedia.devtest.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.devtest.$$s-en.$$s testsets/en-$$s/wikipedia.devtest.$$s-en.$$s; \
	  rsync flores_test_sets/wikipedia.devtest.$$s-en.en testsets/$$s-en/wikipedia.devtest.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.devtest.$$s-en.$$s testsets/$$s-en/wikipedia.devtest.$$s-en.$$s; \
	  S=`iso639 -3 -k -n $$s`; \
	  echo "$$S	eng	flores-devtest				datasets/facebook/testsets/en-$$s/wikipedia.devtest.$$s-en.$$S	datasets/facebook/testsets/en-$$s/wikipedia.devtest.$$s-en.en" >> $@; \
	  echo "eng	$$S	flores-devtest				datasets/facebook/testsets/en-$$s/wikipedia.devtest.$$s-en.en	datasets/facebook/testsets/en-$$s/wikipedia.devtest.$$s-en.$$S" >> $@; \
	done
	for s in ne si; do \
	  mkdir -p testsets/$$s-en testsets/en-$$s; \
	  rsync flores_test_sets/wikipedia.test.$$s-en.en testsets/en-$$s/wikipedia.test.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.test.$$s-en.$$s testsets/en-$$s/wikipedia.test.$$s-en.$$s; \
	  rsync flores_test_sets/wikipedia.test.$$s-en.en testsets/$$s-en/wikipedia.test.$$s-en.en; \
	  rsync flores_test_sets/wikipedia.test.$$s-en.$$s testsets/$$s-en/wikipedia.test.$$s-en.$$s; \
	  S=`iso639 -3 -k -n $$s`; \
	  echo "$$S	eng	flores-test				datasets/facebook/testsets/en-$$s/wikipedia.test.$$s-en.$$S	datasets/facebook/testsets/en-$$s/wikipedia.test.$$s-en.en" >> $@; \
	  echo "eng	$$S	flores-test				datasets/facebook/testsets/en-$$s/wikipedia.test.$$s-en.en	datasets/facebook/testsets/en-$$s/wikipedia.test.$$s-en.$$S" >> $@; \
	done
