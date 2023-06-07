#-*-makefile-*-
#
# maintain various MT testsets




DATASET_DIRS := $(dir $(shell find datasets -name Makefile))
TESTSET_TSVS := $(shell find datasets -name testsets.tsv)


all:
	for d in ${DATASET_DIRS}; do \
	  ${MAKE} -C $$d all; \
	done
	${MAKE} tsvfiles

tsvfiles: testsets.tsv benchmarks.tsv langpairs.tsv langpair2benchmark.tsv benchmark2langpair.tsv


index.txt: testsets
	find testsets -type f | \
	grep -v '.labels$$' | grep -v '.info$$' | \
	xargs wc > $@

testsets.tsv: ${TESTSET_TSVS}
	find datasets -name testsets.tsv -exec cat {} \; |\
	sort -u > $@

%.tsv-check: %.tsv
	cut -f7- $< | tr "\t" "\n" | xargs ls

benchmarks.tsv: testsets.tsv
	cut -f3 $< | sort -u > $@
	for b in `cat benchmarks.tsv`; do \
	  grep "	$$b	" testsets.tsv > testsets/$$b.tsv; \
	done

langpairs.tsv: testsets.tsv
	cut -f1,2 $< | sort -u > $@

langpair2benchmark.tsv: testsets.tsv
	scripts/langpair_benchmarks.pl < $< > $@

benchmark2langpair.tsv: testsets.tsv
	scripts/benchmark_langpairs.pl < $< > $@


