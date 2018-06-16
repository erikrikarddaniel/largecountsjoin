#!/usr/bin/env Rscript

# largecountsjoin.r
#
# Author: daniel.lundin@lnu.se

suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(readr))

SCRIPT_VERSION = "0.2.0"

# Get arguments
option_list = list(
  make_option(
    '--firsttable', type = 'character', help = 'Name of first (left) tsv table. Can be gzipped.'
  ),
  make_option(
    '--firstkey', type = 'character', help = 'Name of key in first (left) table.'
  ),
  make_option(
    '--countstable', type = 'character', help = 'Name of counts (right) tsv table. Can be gzipped.'
  ),
  make_option(
    '--countskey', type = 'character', help = 'Name of key in counts (right) table.'
  ),
  make_option(
    '--outtable', type = 'character', help = 'Name of output tsv table. Can be gzipped.'
  ),
  make_option(
    c("-v", "--verbose"), action="store_true", default=FALSE, 
    help="Print progress messages"
  ),
  make_option(
    c("-V", "--version"), action="store_true", default=FALSE, 
    help="Print program version and exit"
  )
)
opt = parse_args(
  OptionParser(
    usage = "Joins a table (firsttable) with a counts table.\n\n%prog [options]\n\n\tAll options required.", 
    option_list = option_list
  ), 
  positional_arguments = TRUE
)

# Args for testing: opt <- list(options = list(firsttable = 'largecountsjoin.00.hmmrank.tsv', countstable = 'largecountsjoin.00.counts.tsv', firstkey = 'accno', countskey = 'gene', outtable = 'test.tsv', verbose = TRUE))

if ( opt$options$version ) {
  write(SCRIPT_VERSION, stdout())
  quit('no')
}

logmsg = function(msg, llevel='INFO') {
  if ( opt$options$verbose ) {
    write(
      sprintf("%s: %s: %s", llevel, format(Sys.time(), "%Y-%m-%d %H:%M:%S"), msg),
      stderr()
    )
  }
}

logmsg(sprintf("largecountsjoin.r version %s starting", SCRIPT_VERSION))

logmsg(sprintf("Reading %s", opt$options$firsttable))
if ( grepl('\\.gz', opt$options$firsttable) ) {
  fn <- sprintf("pigz -dc %s", opt$options$firsttable)
} else {
  fn <- opt$options$firsttable
}
ft <- fread(fn, sep = '\t', stringsAsFactors = FALSE, header = TRUE, data.table = TRUE, key = opt$options$firstkey, fill = TRUE)

logmsg(sprintf("Reading %s", opt$options$countstable))
if ( grepl('\\.gz', opt$options$countstable) ) {
  cn <- sprintf("pigz -dc %s", opt$options$countstable)
} else {
  cn <- opt$options$countstable
}
ct <- fread(cn, sep = '\t', stringsAsFactors = FALSE, header = TRUE, data.table = TRUE, key = opt$options$countskey, fill = TRUE)

# Create the joined table
logmsg(sprintf("Writing joined table to %s", opt$options$outtable))
ft[ct, nomatch = 0] %>% write_tsv(opt$options$outtable)
logmsg("Done")
