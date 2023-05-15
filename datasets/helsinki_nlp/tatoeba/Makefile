#-*-makefile-*-
#
# test sets from the Tatoeba translation challenge
#


.PHONY: all
all:
	wget https://object.pouta.csc.fi/Tatoeba-Challenge-devtest/test.tar
	tar -xf test.tar
	rm -f test.tar
	${MAKE} tatoeba-files
	${MAKE} tatoeba-remove-identicals
	${MAKE} testsets.tsv


TATOEBA_TEST_FILES = ${wildcard data/release/test/*/*.txt.gz}
TATOEBA_TEST_CONVERTED = ${patsubst %.txt.gz,%.converted,${TATOEBA_TEST_FILES}}

.PHONY: tatoeba-files
tatoeba-files: ${TATOEBA_TEST_CONVERTED}
${TATOEBA_TEST_CONVERTED}: %.converted: %.txt.gz
	@s=$(firstword $(subst -, ,$(subst .,,$(suffix ${basename $@})))); \
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
	fi
	touch $@


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



TATOEBA_TESTSETS = $(sort $(basename $(basename $(wildcard testsets/*/tatoeba-test-*))))


## tabs:
## srclang trglang benchmark IDfile srclabels trglabels domainlabels srcfile trgfiles ...
## - labelfiles only if there are alternative labels
## - domainlabels
## - IDfile in case there are IDs for sentences (or doc-IDs)

testsets.tsv:
	@for d in ${TATOEBA_TESTSETS}; do \
	  echo "add $$d"; \
	  l=`echo $$d | cut -f2 -d/`; \
	  n=`echo $$d | cut -f3 -d/`; \
	  s=`echo $$l | cut -f1 -d-`; \
	  t=`echo $$l | cut -f2 -d-`; \
	  D="datasets/helsinki_nlp/tatoeba"; \
	  if [ "$$s" == "$$t" ]; then \
	    S="$$d.$${s}1"; \
	    T="$$d.$${t}2"; \
	  else \
	    S="$$d.$$s"; \
	    T="$$d.$$t"; \
	  fi; \
	  SL=""; \
	  TL=""; \
	  if [ -e $$S.labels ]; then \
	    if [ `sort -u $$S.labels | wc -l` -gt 1 ]; then \
	      SL="$$D/$$S.labels"; \
	    fi \
	  fi; \
	  if [ -e $$T.labels ]; then \
	    if [ `sort -u $$T.labels | wc -l` -gt 1 ]; then \
	      TL="$$D/$$T.labels"; \
	    fi \
	  fi; \
	  echo "$$s	$$t	$$n		$${SL}	$${TL}	$$D/$$S	$$D/$$T" >> $@.unsorted; \
	  if [ "$$s" != "$$t" ]; then \
	    echo "$$t	$$s	$$n		$${TL}	$${SL}	$$D/$$T	$$D/$$S" >> $@.unsorted; \
	  fi; \
	done
	sort $@.unsorted > $@
	rm -f $@.unsorted

