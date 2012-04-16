#!/usr/bin/perl -w
#-----------------------------------------------------------+
#                                                           |
# tr_test_go_term_search.pl                                 |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 02/04/2011                                       |
# UPDATED: 02/04/2011                                       |
#                                                           |
# DESCRIPTION:                                              | 
#  Test blast from IPlant::TreRec                           |
#                                                           |
# USAGE: tr_test_blast_treerec.pl                           |
#                                                           |
#-----------------------------------------------------------+

use strict;
use DBI;
use JSON qw();
use IPlant::TreeRec;
use IPlant::TreeRec::BlastArgs;
use IPlant::TreeRec::BlastSearcher;
use IPlant::TreeRec::DatabaseTreeLoader;
use IPlant::TreeRec::FileRetriever;
use IPlant::TreeRec::FileTreeLoader;
use IPlant::TreeRec::GeneFamilyInfo;

my $verbose = 1;

#-----------------------------------------------------------+
# TEST SEQUENCES                                            |
#-----------------------------------------------------------+
my $go_number;


#-----------------------------+
# SET THE TEST SEQUENCE       |
#-----------------------------+
my $go_search_term = $go_number;

#-----------------------------------------------------------+
# ESTABLISH DBH                                             |
#-----------------------------------------------------------+

# OPTIONS SET IN USER ENVIRONMENT
my $usrname = $ENV{TR_USERNAME};  # User name to connect to database
my $pass = $ENV{TR_PASSWORD};     # Password to connect to database
my $dsn = $ENV{TR_DSN};           # DSN for database connection

# DATABASE VARS
my $db = "tr_test";               # Database name (ie. iplant_tr)
my $host = "localhost";           # Database host (ie. localhost)
my $driver = "mysql";             # Database driver (ie. mysql)

if ( ($db) && ($host) && ($driver) ) {
    # Set default values if none given at command line
    $db = "iplant_tr" unless $db; 
    $host = "localhost" unless $host;
    $driver = "mysql" unless $driver;
    $dsn = "DBI:$driver:database=$db;host=$host";
} 
else {
    print STDERR "ERROR: A valid dsn can not be created\n";
    exit;
}

#-----------------------------+
# GET DB PASSWORD             |
#-----------------------------+
unless ($pass) {
    print STDERR "\nEnter password for the user $usrname\n";
    system('stty', '-echo') == 0 or die "can't turn off echo: $?";
    $pass = <STDIN>;
    system('stty', 'echo') == 0 or die "can't turn on echo: $?";
    chomp $pass;
}

# Establish the database connection.
my $user     = $usrname;
my $password = $pass;
my $dbh      = IPlant::DB::TreeRec->connect( $dsn, $user, $password );

my $tree_loader = IPlant::TreeRec::DatabaseTreeLoader->new($dbh);

# Create the gene family info.
my $gene_family_info = IPlant::TreeRec::GeneFamilyInfo->new(
    {   dbh                  => $dbh,
        go_term_length_limit => 30,
    }
);


# Create the file retriever.
my $file_retriever = IPlant::TreeRec::FileRetriever->new(
    { data_dir => 
     '/Users/jestill/code/tree_reconciliation/bowers_clusters/clusters' } );

# Create the BLAST searcher.
my $exec_dir = "/usr/local/ncbi/blast/bin/";
my $db_dir = "/Users/jestill/blastplus_dir/";
#my $blast_searcher = IPlant::TreeRec::BlastSearcher->new(
#    {   executable_dir => $exec_dir,
#        database_dir   => $db_dir,
#    }
#);

my $blast_searcher = new IPlant::TreeRec::BlastSearcher ( 
    {
	'executable_dir' => $exec_dir,
	'database_dir'   => $db_dir
    }
    );

# Create the tree reconciliation object.
my $treerec = IPlant::TreeRec->new(
    {   dbh              => $dbh,
        gene_tree_loader => $tree_loader,
        gene_family_info => $gene_family_info,
        file_retriever   => $file_retriever,
        blast_searcher   => $blast_searcher,
    }
);

#-----------------------------------------------------------+
# GENERAL SEARCH                                            |
#-----------------------------------------------------------+
# This needs to determine what is the nature of the 
# input and then launch the specific type of search neede
# either an accession search or a term search.

my @go_searches = (
    "miRNA binding",
    # The following tests of 0031124 should all return the same result
    "31124",
    " 31124",
    "0031124",
    "GO:0031124",
    # From UAT
#    "cytoplasm",  # This term does not work
    "translation",
    "multicellular organismal development",
#    "transcription", # This term does not work
#    "cytosol",     # This term does not work
#    "nucleus",    # This term does not work
    # From User Acceptance Test
#    "0005737",  # This does not work
    "0006412",
    "0007275",
#    "0006350", # This accession does not work
#    "0005829", # This accession does not work
#    "0005634", # This accession does not work
    );

for my $ind_search (@go_searches) {
	print STDERR "-------------------------\n";
	print STDERR " TERM SEARCH: $ind_search \n";
	print STDERR "-------------------------\n";
	my $gen_result = 
	    $treerec->general_go_search($ind_search)->{'families'};


	my @results01 = @$gen_result;
	my $num_results01 = @results01;
	
	print STDERR "NUMBER RESULTS:".$num_results01."\n";
	
        # SHOW THE KEYS AND VALUES
	for my $ind_result (@results01) {
	    print STDERR "FAMILY INFORMATION:\n";
	    for my $key (%$ind_result) {
		print STDERR "\t$key";
		if ($ind_result->{$key}) {
		    print STDERR "--->".$ind_result->{$key};
		}
		print STDERR "\n";
	    }
	    print STDERR "\n";
	}


}

exit;

__END__
