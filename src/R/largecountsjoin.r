#!/usr/bin/env Rscript

# largecountsjoin.r
#
# Author: daniel.lundin@lnu.se

suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(readr))

SCRIPT_VERSION = "0.1"

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
  ft <- fread(sprintf("pigz -dc %s", opt$options$firsttable), sep = '\t', stringsAsFactors = FALSE)
} else {
  ft <- fread(opt$options$firsttable, sep = '\t', stringsAsFactors = FALSE)
}

# Set the firstkey column as key
colnames(ft)[grep(opt$options$firstkey, colnames(ft))] <- 'key'
ft <- ft %>% setkey(key)

logmsg(sprintf("Reading %s", opt$options$countstable))
if ( grepl('\\.gz', opt$options$countstable) ) {
  ct <- fread(sprintf("pigz -dc %s", opt$options$countstable), sep = '\t', stringsAsFactors = FALSE)
} else {
  ct <- fread(opt$options$countstable, sep = '\t', stringsAsFactors = FALSE)
}

# Set the countskey column as key
colnames(ct)[grep(opt$options$countskey, colnames(ct))] <- 'key'
ct <- ct %>% setkey(key)

# Create the joined table
logmsg(sprintf("Writing joined table to %s", opt$options$outtable))
jt <- ft[ct, nomatch = 0] 
colnames(jt)[grep('key', colnames(jt))] <- opt$options$firstkey
jt %>% write_tsv(opt$options$outtable)
logmsg("Done")
