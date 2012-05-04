#!/usr/bin/perl -w


#-----------------------------+
# INCLUDES                    |
#-----------------------------+
use strict;
use DBI;
use Getopt::Long;
use Bio::TreeIO;                # creates Bio::Tree::TreeI objects
use Bio::Tree::TreeI;
use Bio::Tree::Node;
use Bio::Tree::NodeI;
#use Bio::TreeIO;                # BioPerl Tree I/O
#use Bio::Tree::TreeI;
use File::Basename;           # Use this to extract base name from file path

my $infile = "data/pg17890_reconciled.nhx";
my $informat = "prime";
my $outfile;
my $outformat = "prime";

#-----------------------------+
# TREE OBJECT                 |
#-----------------------------+
my $tree_in = new Bio::TreeIO(-file   => $infile,
			      -format => $informat)
    || die "Can not open $informat format tree file:\n$infile";

# The following should put this to STDOUT

my $treeout_here = Bio::TreeIO->new( -format => $outformat );
#my $tree_out = new Bio::Tree::Tree( -format=> $outformat) ||
#    die "Can not create the tree object.\n";
my $tree = $tree_in->next_tree;

$treeout_here->write_tree($tree);
exit;
