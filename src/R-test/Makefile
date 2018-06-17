DIFF = grep -v "^[ ]*$$" $@.out | diff $@.expect -

CHECK = if [ ` $(DIFF) | wc -l ` -eq 0 ]; then echo "*** $@ OK ***"; else echo "*** $@ FAILED ***"; echo "Here's a diff: "; $(DIFF); exit 1; fi

largecountsjoin: largecountsjoin.00 largecountsjoin.01 largecountsjoin.02 largecountsjoin.03 largecountsjoin.04

largecountsjoin.00:
	@../R/largecountsjoin.r --verbose --firsttable=$@.hmmrank.tsv --firstkey=accno --countstable=$@.counts.tsv --countskey=gene --outtable=$@.out 
	@$(CHECK)

largecountsjoin.01:
	@../R/largecountsjoin.r --verbose --firsttable=$@.hmmrank.tsv.gz --firstkey=accno --countstable=$@.counts.tsv.gz --countskey=gene --outtable=$@.out 
	@$(CHECK)

largecountsjoin.02:
	@../R/largecountsjoin.r --verbose --firsttable=$@.hmmrank.tsv.gz --firstkey=accno --countstable=$@.counts.tsv.gz --countskey=gene --outtable=$@.out --longfirstcol=2 --longvalue=tpm
	@$(CHECK)

largecountsjoin.03:
	@../R/largecountsjoin.r --verbose --firsttable=$@.hmmrank.tsv --firstkey=accno --countstable=$@.counts.tsv --countskey=gene --outtable=$@.out --subset
	@$(CHECK)

largecountsjoin.04:
	@../R/largecountsjoin.r --verbose --firsttable=$@.hmmrank.tsv --firstkey=accno --countstable=$@.counts.tsv --countskey=gene --outtable=$@.out --longfirstcol=2 --longvalue=tpm --subset
	@$(CHECK)
