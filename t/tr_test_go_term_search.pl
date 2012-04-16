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
# TERM SEARCH 
#-----------------------------------------------------------+
# This uses do_gene_family_search from TreeRec.pm
my $search01 = "miRNA binding";
my $result01 = $treerec->go_search("miRNA binding")->{families};

my @results01 = @$result01;
my $num_results01 = @results01;

print STDERR "-------------------------\n";
print STDERR " SEARCH: $search01 \n";
print STDERR "-------------------------\n";
print STDERR "NUMBER RESULTS:".$num_results01."\n";

# SHOW THE KEYS
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


#-----------------------------------------------------------+
# ACCESSION SEARCH
#-----------------------------------------------------------+
# These numbers must be padded

my $search02 = "0031124";
#my $search02 = "31124";

# Test of padding number
#$search02 = sprintf(“%070d”, $search02);
#my $search_pad = sprintf(“%07d”, $search02);

#$search02 = sprintf("%07d", $search02);
print STDERR "-------------------------\n";
print STDERR " SEARCH: $search02\n";
print STDERR "-------------------------\n";
# Fetch the relevant information
# Uses
#  TreeRec->go_accession_search
# which uses 
#  TreeRec->do_gene_family_search
#
print STDERR "\n";
my $result02 = $treerec->go_accession_search( $search02 )->{families};

my @results02 = @$result02;
my $num_results02 = @results02;
for my $ind_result (@results02) {
    print STDERR "FAMILY INFORMATION:\n";
    for my $key (%$ind_result) {
	print STDERR "\t$key";
	if ($ind_result->{$key}) {
	    print STDERR "--->".$ind_result->{$key};
	}
	print STDERR "\n";
    }
#    print STDERR "\n";
}
exit;


#eval {
#    warn Dumper $treerec->go_accession_search("0031124");
#};


#my @results02 = @$result02;
#my $num_results02 = @results02;

#
#for my $ind_result (@results02) {
#    print STDERR "FAMILY INFORMATION:\n";
#    for my $key (%$ind_result) {
#	print STDERR "\t$key\n";
##	print STDERR $ind_result->{$key}."\n";
#    }
#    print STDERR "\n";
#}


#-----------------------------------------------------------+
# GENERAL SEARCH                                            |
#-----------------------------------------------------------+
# This needs to determine what is the nature of the 
# input and then launch the specific type of search neede
# either an accession search or a term search.
my $gen_search01 = "miRNA binding";
my $gen_search02 = "0031124";
my $gen_search03 = "GO:0031124";

my @go_searches = (
    "miRNA binding",
#    "  miRNA binding",
#    "31124",
#    " 31124",
#    "0031124",
#    "GO:0031124",
    # From UAT
#    "cytoplasm",
#    "translation",
#    "multicellular organismal development",
#    "transcription",
#    "cytosol",
#    "nucleus",
    # ALSO FROM UAT
    "0005737",
    "0006412",
    "0007275",
    "0006350",
    "0005829",
    "0005634",
    );

for my $ind_search (@go_searches) {
	print STDERR "-------------------------\n";
	print STDERR " TERM SEARCH: $search01 \n";
	print STDERR "-------------------------\n";
	my $result01 = $treerec->general_go_search($ind_search)->{families};
}

#my $search03_type = determine_go_search_type( $gen_search03 );
#print STDERR "Search:$gen_search03".$search03_type."\n";

print STDERR "\n\n";
print STDERR "+-----------------------------------------------------------+\n";
print STDERR " GENERIC SEARCH TESTING:\n";
print STDERR "+-----------------------------------------------------------+\n";
for my $ind_search (@go_searches) {
    print STDERR $ind_search." : ";
    my $search_type;
    $search_type = determine_go_search_type($ind_search);
    print STDERR "$search_type";
    print STDERR "\n";
    
    if ($search_type =~ "GoAccessionSearch") {

    }
    elsif ($search_type =~ "GoSearch") {

	my $result01 = $treerec->go_search($ind_search)->{families};
	
	my @results01 = @$result01;
	my $num_results01 = @results01;
	
	print STDERR "-------------------------\n";
	print STDERR " TERM SEARCH: $search01 \n";
	print STDERR "-------------------------\n";
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
    
}




# Determine if this is an go_accesion_search or go_term_search


1;
exit;

sub determine_go_search_type {
# This needs to determine what is the nature of the 
# input and then launch the specific type of search neede
# either an accession search or a term search.
# Returns go_accession_search
#         go_term_search
# If the go_search includes leading white spaces this will
# not match to accession_search. May want to remove
# leading and trailing white spaces
#

    my ($search_string) = @_;
    
    # Remove whitespaces from the beginning and end of string
    $search_string =~ s/^\s+//;
    $search_string =~ s/\s+$//;

#    if ($go_search =~ m/GO\:(.*)/xms) {
    if ($search_string =~ m/GO\:(\d*)/xms) {
	# This is the case where users uses
	# GO:#######
	# Check that the value is a number
#	if ()
#	return 'go_accession_search';
	$search_string = $1;
	# Pad with zeros
	$search_string = sprintf("%07d", $search_string);
	return "GoAccessionSearch -> $search_string";
    }
    elsif ($search_string =~ m/(^\d+)/xms ) {
	# This will only return the first complete digit if there is a longer 
        # list of digits
	$search_string = sprintf("%07d", $search_string);
	return "GoAccessionSearch -> $search_string";
    }
    else {
	# Assumes all other strings are go terms
	return "GoSearch -> $search_string";
    }


}


__END__

#-----------------------------------------------------------+
# TEST TREEREC OBJECTS                                      |
#-----------------------------------------------------------+
#my $treerec = IPlant::TreeRec->new(
#    {   dbh              => $dbh,
#	#                      gene_tree_loader => $tree_loader,
#	#                      gene_family_info => $info,
#	#                      file_retreiver   => $file_retriever,
#	#                      blast_searcher   => $blast_searcher,
#                      }
#    );

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



#
# DENNIS'S EVAL
#
eval {
    #warn Dumper $treerec->go_search("miRNA binding");
    #warn Dumper $treerec->go_accession_search("0031124");
    #warn Dumper $treerec->gene_id_search("V01G0907");
    warn Dumper $treerec->get_gene_family_summary("pg00892");
    #warn Dumper $treerec->get_gene_family_details("pg00892");
    #warn Dumper get_gene_tree_file( $treerec, 'pg00892' );
    #warn Dumper get_gene_tree_file( $treerec, 'pg00892', 'bowers_rosids' );
    #warn Dumper get_species_tree_file( $treerec, 'bowers_rosids' );
    #warn Dumper get_species_tree_file( $treerec, 'bowers_rosids', 'pg00892' );
    #warn Dumper get_gene_tree_data( $treerec, 'pg00892' );
    #warn Dumper get_gene_tree_data( $treerec, 'pg00892', 'bowers_rosids' );
    #warn Dumper get_species_tree_data( $treerec, 'bowers_rosids' );
    #warn Dumper get_species_tree_data( $treerec, 'bowers_rosids', 'pg00892' );

    #warn Dumper $treerec->resolve_reconciliations(
    #    JSON->new()->encode(
    #        {   'speciesTreeName' => 'bowers_rosids',
    #            'familyName'      => 'pg00892',
    #            'speciesTreeNode' => 8,
    #            'edgeSelected'    => 0,
    #        }
    #    )
    #);
    #warn Dumper $treerec->resolve_reconciliations(
    #    JSON->new()->encode(
    #        {   'speciesTreeName' => 'bowers_rosids',
    #            'familyName'      => 'pg00892',
    #            'speciesTreeNode' => 8,
    #            'edgeSelected'    => 1,
    #        }
    #    )
    #);
    #warn Dumper $treerec->resolve_reconciliations(
    #    JSON->new()->encode(
    #        {   'speciesTreeName' => 'bowers_rosids',
    #            'familyName'      => 'pg00892',
    #            'geneTreeNode'    => 8,
    #        }
    #    )
    #);

    #for my $type ( $file_retriever->get_file_types() ) {
    #    warn Dumper $treerec->get_file( $type, 'pg00892' );
    #}

    warn Dumper blast_search( $treerec, 'nucleotide', 'dna_query.fa' );
    #warn Dumper blast_search( $treerec, 'protein', 'protein_query.fa' );
    #warn Dumper find_duplication_events( $treerec, 10, 1 );
    #warn Dumper find_duplication_events( $treerec, 10, 0 );
};

#-----------------------------+
# BLAST JSON OPTIONS          |
#-----------------------------+
#my $blast_program = 'tblastx';
#my $json_blast_opts = {
#	'sequence'      => $test_seq,
##	'sequenceType'  => 'protein',
#	'evalue'        => '0.0001',
##	'maxNumSeqs'    => '20',
#};
#
#my $json_args = JSON->new->encode($json_blast_opts);
#
##print STDERR "JSON IN:\n".$json_args."\n";

#-----------------------------------------------------------+
# DIRECT BLAST                                              |
#-----------------------------------------------------------+

#-----------------------------+
# SET THE JSON OBJECT         |
#-----------------------------+
my $blast_program = 'tblastx';
my $json_blast_opts = {
	'sequence'      => $test_seq,
#	'sequenceType'  => 'protein',
	'evalue'        => '0.0001',
#	'maxNumSeqs'    => '20',
};

my $json_args = JSON->new->encode($json_blast_opts);
#print STDERR "JSON IN:\n".$json_args."\n";

my $json_blast_args =  IPlant::TreeRec::BlastArgs->from_json($json_args);

my $direct_blast_searcher = new IPlant::TreeRec::BlastSearcher ( 
    {
	'executable_dir' => $exec_dir,
	'database_dir'   => $db_dir
    }
    );

# Show the sequence used
#my $sequence_used = $json_blast_args->get_sequence();
#print STDERR "SEQ: ".$sequence_used."\n";

#-----------------------------------------------------------+
# TREE REC BLAST                                            |
#-----------------------------------------------------------+

#-----------------------------+
# DO BLAST AND SHOW RESULTS   |
#-----------------------------+
# The following is a test of the BLAST returns directly
##my @gene_ids = $direct_blast_searcher->search($json_blast_args);
#my @direct_blast_results = $blast_searcher->search($json_blast_args);
#my $num_gene_ids = @direct_blast_results;
#print STDERR "Num matches Found:".$num_gene_ids."\n";
#for my $ind_hit (@direct_blast_results) {
#    print STDERR "\t".$ind_hit->{'query_id'}."\t";
#    print STDERR "\t".$ind_hit->{'gene_id'}."\t";
#    print STDERR "\t".$ind_hit->{'evalue'}."\t";
#    print STDERR "\t".$ind_hit->{'query_start'}."\t";
#    print STDERR "\t".$ind_hit->{'query_end'}."\t";
#    print STDERR "\t".$ind_hit->{'length'};
#    print STDERR "\n";
#    
#}


#-----------------------------------------------------------+
# TreeRec BLAST                                             |
#-----------------------------------------------------------+
my $matching_families = $treerec->blast_search($json_args)->{'families'};

# Dereference to an array
my @tr_results = @$matching_families;

print STDERR "THE MATCHING FAMILIES ARE\n";
for my $tr_result (@tr_results) {
   print STDERR "\t".$tr_result->{'geneFamilyName'};
    print STDERR "\t".$tr_result->{'evalue'};
    print STDERR "\t".$tr_result->{'length'};
    print STDERR "\n";
}

exit;

##-----------------------------+
## SET THE JSON OPTIONS        |
##-----------------------------+
#my $blast_program = 'tblastx';
#my $json_blast_opts = {
#	'sequence'      => $test_seq,
##	'sequenceType'  => 'protein',
#	'evalue'        => '0.0001',
##	'maxNumSeqs'    => '20',
#};


#
#my $json_args = JSON->new->encode($json_blast_opts);

#print STDERR "JSON IN:\n".$json_args."\n";

#my $json_blast_args =  IPlant::TreeRec::BlastArgs->from_json($json_args);
#

# Show the sequence used
#my $sequence_used = $json_blast_args->get_sequence();
#print STDERR "SEQ: ".$sequence_used."\n";


1;
exit;


sub connect_to_db {
    my ($cstr) = @_;
    return connect_to_mysql(@_) if $cstr =~ /:mysql:/i;
    return connect_to_pg(@_) if $cstr =~ /:pg:/i;
    die "can't understand driver in connection string: $cstr\n";
}


sub connect_to_mysql {
    
    my ($cstr, $user, $pass) = @_;
    
    my $dbh = DBI->connect($cstr, 
			   $user, 
			   $pass, 
			   {PrintError => 0, 
			    RaiseError => 1,
			    AutoCommit => 0});
    
    $dbh || &error("DBI connect failed : ",$dbh->errstr);
    
    return($dbh);
}

##########################################################################
#
# FROM DENNIS
#
# Usage      : $results_ref = blast_search( $treerec, $type, $file );
#
# Purpose    : Performs a BLAST search.
#
# Returns    : The results of the BLAST search.
#
# Parameters : $treerec - an instance of IPlant::TreeRec.
#              $type    - the type of sequence (nucleotide or protein).
#              $file    - the name of the file containing the sequence.
#
# Throws     : No exceptions.
sub blast_search {
    my ( $treerec, $type, $file ) = @_;

    # Build the BLAST arguments JSON.
    my $blast_args_json = JSON->new()->encode(
        {   sequenceType => $type,
            sequence     => scalar slurp $file,
        }
    );

    #Perform the search.
    return $treerec->blast_search($blast_args_json);
}

__END__
