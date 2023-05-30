#-*-makefile-*-
#
# add various WMT data sets



BENCHMARKS = 	wmt_newstest.tsv \
		wmt_newstest_multiref.tsv \
		wmt_newstest_multiling.tsv \
		wmt_wikipedia.tsv \
		wmt_europeana.tsv \
		wmt2021_newstest.tsv \
		wmt2022_newstest.tsv


testsets.tsv: ${BENCHMARKS}
	cat $^ | sort -u > $@


## various tsv files with benchmarks

wmt20%_newstest.tsv: wmt%-news-systems
	rm -f $@
	for d in `ls $</txt/sources`; do \
	  b=`echo $$d | cut -f1 -d.`; \
	  p=`echo $$d | cut -f2 -d.`; \
	  s=`echo $$d | cut -f4 -d.`; \
	  t=`echo $$p | cut -f2 -d-`; \
	  S=`iso639 -n -3 $$s`; \
	  T=`iso639 -n -3 $$t`; \
	  R=`ls $</txt/references/$$b.$$p.ref.*.$$t | sed 's|^|datasets/statmt/|' | tr "\n" "\t"`; \
	  echo "$$S	$$T	$$b				datasets/statmt/$</txt/sources/$$d	$$R" >> $@; \
	done

%-news-systems:
	git clone https://github.com/wmt-conference/$@.git
	rm -fr $@/.git*
	git add $@/txt/sources $@/txt/references $@/README.md







wmt_newstest.tsv: .wmt-files
	@for y in 2014 2015 2016 2017 2018 2019 2020; do \
	  echo "add year $$y"; \
	  for p in `ls wmt_newstest/$$y`; do \
	    s=`echo $$p | cut -f1 -d-`; \
	    t=`echo $$p | cut -f2 -d-`; \
	    S=`iso639 -n -3 $$s`; \
	    T=`iso639 -n -3 $$t`; \
	    for d in `ls wmt_newstest/$$y/$$p | cut -f1 -d. | sort -u`; do \
	      echo "$$S	$$T	$$d				datasets/statmt/wmt_newstest/$$y/$$d.$$s	datasets/statmt/wmt_newstest/$$y/$$d.$$t" >> $@.unsorted; \
	    done \
	  done \
	done
	@sort -u $@.unsorted > $@
	@rm -f $@.unsorted


wmt_newstest_multiref.tsv: .wmt-files
	@for d in `find wmt_newstest -name *B*`; do \
	  y=`echo $$d | cut -f2 -d/`; \
	  p=`echo $$d | cut -f3 -d/`; \
	  s=`echo $$p | cut -f1 -d-`; \
	  t=`echo $$p | cut -f2 -d-`; \
	  if [ -e wmt_newstest/$$y/$$p/newstest$$y.$$s ] && [ -e wmt_newstest/$$y/$$p/newstestB$$y.$$s ]; then \
	    if [ `diff wmt_newstest/$$y/$$p/newstest$$y.$$s wmt_newstest/$$y/$$p/newstestB$$y.$$s | wc -l` -eq 0 ]; then \
	      S=`iso639 -n -3 $$s`; \
	      T=`iso639 -n -3 $$t`; \
	      echo "$$S	$$T	newstestALL$$y				datasets/statmt/wmt_newstest/$$y/newstest$$y.$$s	datasets/statmt/wmt_newstest/$$y/newstest$$y.$$t	datasets/statmt/wmt_newstest/$$y/newstestB$$y.$$t" >> $@.unsorted; \
	    fi \
	  fi \
	done
	@sort -u $@.unsorted > $@
	@rm -f $@.unsorted


wmt_newstest_multiling.tsv: .wmt-files
	@for y in 2008 2009 2010 2011 2012 2013; do \
	  echo "add year $$y"; \
	  for s in `ls wmt_newstest/$$y/newstest* | cut -f2 -d.`; do \
	    S=`iso639 -n -3 $$s`; \
	    for t in `ls wmt_newstest/$$y/newstest* | cut -f2 -d.`; do \
	      T=`iso639 -n -3 $$t`; \
	      if [ "$$s" != "$$t" ]; then \
		echo "$$S	$$T	newstest$$y				datasets/statmt/wmt_newstest/$$y/newstest$$y.$$s	datasets/statmt/wmt_newstest/$$y/newstest$$y.$$t" >> $@.unsorted; \
	      fi \
	    done \
	  done \
	done
	@echo "add newssyscomb2009"
	@for s in `ls wmt_newstest/2009/newssyscomb* | cut -f2 -d.`; do \
	  S=`iso639 -n -3 $$s`; \
	  for t in `ls wmt_newstest/2009/newssyscomb* | cut -f2 -d.`; do \
	    T=`iso639 -n -3 $$t`; \
	    if [ "$$s" != "$$t" ]; then \
	      echo "$$S	$$T	newssyscomb2009				datasets/statmt/wmt_newstest/2009/newssyscomb2009.$$s	datasets/statmt/wmt_newstest/2009/newssyscomb2009.$$t" >> $@.unsorted; \
	    fi \
	  done \
	done
	@sort -u $@.unsorted > $@
	@rm -f $@.unsorted

wmt_europeana.tsv: .wmt-files
	@for s in is nb sv; do \
	  S=`iso639 -n -3 $$s`; \
	  for t in is nb sv; do \
	    T=`iso639 -n -3 $$t`; \
	    if [ "$$s" != "$$t" ]; then \
	      echo "$$S	$$T	europeana2021				datasets/statmt/wmt_multilingual/$$s/europeana2021.$$s	datasets/statmt/wmt_multilingual/is/europeana2021.$$t" >> $@.unsorted; \
	    fi \
	  done \
	done
	@sort -u $@.unsorted > $@
	@rm -f $@.unsorted


wmt_wikipedia.tsv: .wmt-files
	@for s in ca it oc ro; do \
	  S=`iso639 -n -3 $$s`; \
	  for t in ca it oc ro; do \
	    T=`iso639 -n -3 $$t`; \
	    if [ "$$s" != "$$t" ]; then \
	      echo "$$S	$$T	wmt21-ml-wp				datasets/statmt/wmt_multilingual/wp.test.$$s	datasets/statmt/wmt_multilingual/wp.test.$$t" >> $@.unsorted; \
	    fi \
	  done \
	done
	@sort -u $@.unsorted > $@
	@rm -f $@.unsorted








.wmt-files:
	wget http://data.statmt.org/wmt22/translation-task/dev.tgz
	tar -xzf dev.tgz
	rm -f dev.tgz
	${MAKE} .newstest-multiparallel \
		.newssyscomb-multiparallel \
		.newstest-sgm \
		.wmt-xml \
		.wikipedia \
		.wmt21-ml
	rm -f .newstest-sgm
	${MAKE} NEWSTEST_YEARS="2016 2017 2020" NEWSTEST_NAME=newstestB .newstest-sgm
	rm -f .newstest-sgm
	${MAKE} NEWSTEST_YEARS=2015 NEWSTEST_NAME=newsdiscusstest .newstest-sgm
	rm -fr dev
	touch $@


.newstest-multiparallel:
	for y in 2008 2009 2010 2011 2012 2013; do \
	  mkdir -p wmt_newstest/$$y; \
	  for f in `ls dev/sgm/news*test$$y-ref.*.sgm`; do \
	    l=`echo $$f | sed 's/^.*\.\(..\)\.sgm/\1/'`; \
	    ../../scripts/input-from-sgm.perl < $$f > wmt_newstest/$$y/newstest$$y.$$l; \
	  done \
	done
	touch $@

.newssyscomb-multiparallel:
	for y in 2009; do \
	  mkdir -p wmt_newstest/$$y; \
	  for f in `ls dev/sgm/newssyscomb$$y-ref.*.sgm`; do \
	    l=`echo $$f | sed 's/^.*\.\(..\)\.sgm/\1/'`; \
	    ../../scripts/input-from-sgm.perl < $$f > wmt_newstest/$$y/newssyscomb$$y.$$l; \
	  done \
	done
	touch $@

.wikipedia:
	mkdir -p wmt_wikipedia/km-en
	cp dev/sgm/wikipedia.devtest.km-en.en wmt_wikipedia/km-en/wikipedia.devtest.en
	cp dev/sgm/wikipedia.devtest.km-en.km wmt_wikipedia/km-en/wikipedia.devtest.km
	mkdir -p wmt_wikipedia/ps-en
	cp dev/sgm/wikipedia.devtest.ps-en.en wmt_wikipedia/ps-en/wikipedia.devtest.en
	cp dev/sgm/wikipedia.devtest.ps-en.ps wmt_wikipedia/ps-en/wikipedia.devtest.ps
	touch $@



NEWSTEST_YEARS = 2014 2015 2016 2017 2018 2019 2020
NEWSTEST_NAME  = newstest

.newstest-sgm:
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
	touch $@

.wmt-xml:
	for f in `ls dev/xml/*test*.xml`; do \
	  b=`basename $$f | cut -f1 -d. | sed 's/^\(.*\)....$$/\1/'`; \
	  y=`basename $$f | cut -f1 -d. | sed 's/^.*\(....\)$$/\1/'`; \
	  p=`echo $$f | cut -f2 -d.`; \
	  echo "$$p/$$b$$y"; \
	  mkdir -p wmt_$$b/$$y/$$p; \
	  dev/xml/extract.py -o wmt_$$b/$$y/$$p/$$b$$y $$f; \
	done
	touch $@


.wmt21-ml:
	tar xf wm21ml.tar.gz
	mkdir -p wmt_multilingual/is
	grep -v '^<' europeana/test/europeana.test.is.xml    > wmt_multilingual/is/europeana2021.is
	grep -v '^<' europeana/test/europeana.test.is_NO.xml > wmt_multilingual/is/europeana2021.nb
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
	touch $@




