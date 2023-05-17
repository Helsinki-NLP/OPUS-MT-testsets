#-*-makefile-*-




## add various WMT data sets

.PHONY: wmt
wmt:
	wget http://data.statmt.org/wmt22/translation-task/dev.tgz
	tar -xzf dev.tgz
	rm -f dev.tgz
	${MAKE} newstest-multiparallel newssyscomb-multiparallel \
		newstest-sgm wmt-xml wikipedia wmt21-ml
	${MAKE} NEWSTEST_YEARS="2016 2017 2020" NEWSTEST_NAME=newstestB newstest-sgm
	${MAKE} NEWSTEST_YEARS=2015 NEWSTEST_NAME=newsdiscusstest newstest-sgm



newstest-multiparallel:
	for y in 2008 2009 2010 2011 2012 2013; do \
	  mkdir -p wmt_newstest/$$y; \
	  for f in `ls dev/sgm/news*test$$y-ref.*.sgm`; do \
	    l=`echo $$f | sed 's/^.*\.\(..\)\.sgm/\1/'`; \
	    ../../scripts/input-from-sgm.perl < $$f > wmt_newstest/$$y/newstest$$y.$$l; \
	  done \
	done

newssyscomb-multiparallel:
	for y in 2009; do \
	  mkdir -p wmt_newstest/$$y; \
	  for f in `ls dev/sgm/newssyscomb$$y-ref.*.sgm`; do \
	    l=`echo $$f | sed 's/^.*\.\(..\)\.sgm/\1/'`; \
	    ../../scripts/input-from-sgm.perl < $$f > wmt_newstest/$$y/newssyscomb$$y.$$l; \
	  done \
	done

wikipedia:
	mkdir -p wmt_wikipedia/km-en
	cp dev/sgm/wikipedia.devtest.km-en.en wmt_wikipedia/km-en/wikipedia.devtest.en
	cp dev/sgm/wikipedia.devtest.km-en.km wmt_wikipedia/km-en/wikipedia.devtest.km
	mkdir -p wmt_wikipedia/ps-en
	cp dev/sgm/wikipedia.devtest.ps-en.en wmt_wikipedia/ps-en/wikipedia.devtest.en
	cp dev/sgm/wikipedia.devtest.ps-en.ps wmt_wikipedia/ps-en/wikipedia.devtest.ps



NEWSTEST_YEARS = 2014 2015 2016 2017 2018 2019 2020
NEWSTEST_NAME  = newstest

newstest-sgm:
	for y in ${NEWSTEST_YEARS}; do \
	  echo "newstest $$y"; \
	  for p in `ls dev/sgm/${NEWSTEST_NAME}$$y-*.sgm | cut -f2 -d- | sort -u`; do \
	    s=`echo $$p | sed 's/\(..\)../\1/'`; \
	    t=`echo $$p | sed 's/..\(..\)/\1/'`; \
	    if 	[ -e dev/sgm/${NEWSTEST_NAME}$$y-$$p-src.$$s.sgm ] && \
		[ -e dev/sgm/${NEWSTEST_NAME}$$y-$$p-ref.$$t.sgm ]; then \
	      mkdir -p wmt_newstest/$$y/$$s-$$t; \
	      ../../scripts/input-from-sgm.perl < dev/sgm/${NEWSTEST_NAME}$$y-$$p-src.$$s.sgm \
		> wmt_newstest/$$y/$$s-$$t/${NEWSTEST_NAME}$$y.$$s; \
	      ../../scripts/input-from-sgm.perl < dev/sgm/${NEWSTEST_NAME}$$y-$$p-ref.$$t.sgm \
		> wmt_newstest/$$y/$$s-$$t/${NEWSTEST_NAME}$$y.$$t; \
	    fi; \
	    if 	[ -e dev/sgm/${NEWSTEST_NAME}$$y-$$p-src.$$t.sgm ] && \
		[ -e dev/sgm/${NEWSTEST_NAME}$$y-$$p-ref.$$s.sgm ]; then \
	      mkdir -p wmt_newstest/$$y/$$t-$$s; \
	      ../../scripts/input-from-sgm.perl < dev/sgm/${NEWSTEST_NAME}$$y-$$p-src.$$t.sgm \
		> wmt_newstest/$$y/$$t-$$s/${NEWSTEST_NAME}$$y.$$t; \
	      ../../scripts/input-from-sgm.perl < dev/sgm/${NEWSTEST_NAME}$$y-$$p-ref.$$s.sgm \
		> wmt_newstest/$$y/$$t-$$s/${NEWSTEST_NAME}$$y.$$s; \
	    fi \
	  done \
	done

wmt-xml:
	for f in `ls dev/xml/*test*.xml`; do \
	  b=`basename $$f | cut -f1 -d. | sed 's/^\(.*\)....$$/\1/'`; \
	  y=`basename $$f | cut -f1 -d. | sed 's/^.*\(....\)$$/\1/'`; \
	  p=`echo $$f | cut -f2 -d.`; \
	  echo "$$p/$$b$$y"; \
	  mkdir -p wmt_$$b/$$y/$$p; \
	  dev/xml/extract.py -o wmt_$$b/$$y/$$p/$$b$$y $$f; \
	done



.PHONY: wmt21-ml
wmt21-ml:
	tar xf wm21ml.tar.gz
	mkdir -p wmt_multilingual/is
	grep -v '^<' europeana/test/europeana.test.is.xml    > wmt_multilingual/is/europeana2021.is
	grep -v '^<' europeana/test/europeana.test.is_NO.xml > wmt_multilingual/is/europeana2021.no
	grep -v '^<' europeana/test/europeana.test.is_SV.xml > wmt_multilingual/is/europeana2021.sv
	mkdir -p wmt_multilingual/nb
	grep -v '^<' europeana/test/europeana.test.nb.xml    > wmt_multilingual/nb/europeana2021.nb
	grep -v '^<' europeana/test/europeana.test.nb_IS.xml > wmt_multilingual/nb/europeana2021.is
	grep -v '^<' europeana/test/europeana.test.nb_SV.xml > wmt_multilingual/nb/europeana2021.sv
	mkdir -p wmt_multilingual/sv
	grep -v '^<' europeana/test/europeana.test.sv.xml    > wmt_multilingual/sv/europeana2021.sv
	grep -v '^<' europeana/test/europeana.test.sv_IS.xml > wmt_multilingual/sv/europeana2021.is
	grep -v '^<' europeana/test/europeana.test.sv_NB.xml > wmt_multilingual/sv/europeana2021.nb
	for s in ca it oc ro; do \
	  grep -v '^<' wikipedia/test/wp.test.$$s.xml > wmt_multilingual/wp.test.$$s; \
	done
	rm -fr europeana wikipedia
