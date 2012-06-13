#!/usr/bin/perl -w
#-----------------------------------------------------------+
#                                                           |
# tr_test_blast_treerec.pl                                  |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 02/01/2011                                       |
# UPDATED: 02/01/2011                                       |
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
# PROTEIN: Unix line endings, single record
my $test_aa_seq = ">POPTR-0010s18130.1_poplar\n".
    "MFHTKKPSTMNSHDRPMCVQGDSGLVLTTDPKPRLRWTVELHERFVDAVTQLGGPDKATP".
    "KTIMRVMGVKGLTLYHLKSHLQKFRLGKQPHKDFNDHSIKDASALDLQRSAASSSGMMSR".
    "SMNEMQMEVQRRLHEQLEVQRHLQLRTEAQGKYIQSLLEKACQTLAGDQNLASGSYKGMG".
    "NQGIPGMGAMKEFGTLNFPAFQDLNIYGGDQLDLQHNMDRPSLDGFMPNNDNICLGKKRP".
    "SPYDGSGKSPLIWPDDLRLQDLGSGPACLEPQDDPFKGDQIQMAPPSMDRGTDLDSISDM".
    "YEIKPALQGDALDEKKFEASAKLKRPSPRRSPLAAERMSPMINTGAMPQGRNSPFG";

# DNA: Unix line endings, single record
# This is a good test for stripping headers since it has 
# aa diagnostic characters in the header
my $test_dna_seq = ">POPTR-0010s18130.1_poplar\n".
    "ATGTTCCATACCAAGAAACCCTCAACTATGAATTCCCATGATAGACCCATGTGTGTTCAA".
    "GGGGACTCTGGTCTTGTCCTCACCACAGACCCCAAGCCCCGTCTCCGCTGGACTGTTGAG".
    "CTCCATGAACGCTTTGTGGATGCCGTTACTCAGCTTGGAGGCCCAGATAAGGCCACTCCC".
    "AAAACCATCATGAGAGTCATGGGTGTGAAGGGTCTTACCCTTTACCACCTCAAAAGCCAT".
    "CTTCAGAAATTCAGACTTGGAAAGCAACCACACAAGGATTTCAATGATCATTCAATTAAG".
    "GATGCTTCGGCGTTAGATCTTCAACGAAGTGCAGCATCTTCATCTGGCATGATGAGCCGC".
    "AGTATGAATGAGATGCAAATGGAGGTGCAGAGAAGACTGCATGAACAATTAGAGGTTCAA".
    "AGACACCTTCAATTAAGGACCGAGGCTCAAGGGAAATATATACAAAGTTTGTTGGAGAAA".
    "GCTTGCCAAACCCTAGCAGGTGATCAAAACTTGGCTTCTGGAAGCTATAAGGGAATGGGG".
    "AATCAAGGAATTCCTGGTATGGGTGCAATGAAAGAATTTGGCACGCTGAATTTTCCAGCA".
    "TTTCAAGACCTTAACATTTATGGGGGTGACCAACTTGACCTTCAACACAATATGGATAGG".
    "CCATCACTCGATGGTTTCATGCCGAACAACGACAACATTTGTTTGGGAAAGAAGAGGCCT".
    "AGTCCTTACGATGGTAGTGGAAAGAGCCCTTTGATTTGGCCGGACGATCTGCGTTTGCAG".
    "GATTTGGGATCAGGACCGGCATGTCTTGAACCCCAAGATGATCCTTTCAAAGGTGATCAA".
    "ATCCAGATGGCACCACCATCAATGGATAGGGGTACTGATCTGGATTCCATATCTGACATG".
    "TATGAAATAAAGCCAGCGCTTCAGGGTGATGCACTGGATGAGAAGAAATTTGAAGCATCA".
    "GCAAAGCTAAAAAGGCCATCCCCAAGAAGATCACCACTAGCAGCCGAAAGGATGAGCCCT".
    "ATGATCAATACTGGCGCCATGCCACAAGGCAGAAACTCACCATTTGGT";

# DNA: Unix line endings multiple records
my $test_multi_dna_seq = ">POPTR-0010s18130.1_poplar\n".
    "ATGTTCCATACCAAGAAACCCTCAACTATGAATTCCCATGATAGACCCATGTGTGTTCAA\n".
    "GGGGACTCTGGTCTTGTCCTCACCACAGACCCCAAGCCCCGTCTCCGCTGGACTGTTGAG\n".
    "CTCCATGAACGCTTTGTGGATGCCGTTACTCAGCTTGGAGGCCCAGATAAGGCCACTCCC\n".
    "AAAACCATCATGAGAGTCATGGGTGTGAAGGGTCTTACCCTTTACCACCTCAAAAGCCAT\n".
    "CTTCAGAAATTCAGACTTGGAAAGCAACCACACAAGGATTTCAATGATCATTCAATTAAG\n".
    "GATGCTTCGGCGTTAGATCTTCAACGAAGTGCAGCATCTTCATCTGGCATGATGAGCCGC\n".
    "AGTATGAATGAGATGCAAATGGAGGTGCAGAGAAGACTGCATGAACAATTAGAGGTTCAA\n".
    "AGACACCTTCAATTAAGGACCGAGGCTCAAGGGAAATATATACAAAGTTTGTTGGAGAAA\n".
    "GCTTGCCAAACCCTAGCAGGTGATCAAAACTTGGCTTCTGGAAGCTATAAGGGAATGGGG\n".
    "AATCAAGGAATTCCTGGTATGGGTGCAATGAAAGAATTTGGCACGCTGAATTTTCCAGCA\n".
    "TTTCAAGACCTTAACATTTATGGGGGTGACCAACTTGACCTTCAACACAATATGGATAGG\n".
    "CCATCACTCGATGGTTTCATGCCGAACAACGACAACATTTGTTTGGGAAAGAAGAGGCCT\n".
    "AGTCCTTACGATGGTAGTGGAAAGAGCCCTTTGATTTGGCCGGACGATCTGCGTTTGCAG\n".
    "GATTTGGGATCAGGACCGGCATGTCTTGAACCCCAAGATGATCCTTTCAAAGGTGATCAA\n".
    "ATCCAGATGGCACCACCATCAATGGATAGGGGTACTGATCTGGATTCCATATCTGACATG\n".
    "TATGAAATAAAGCCAGCGCTTCAGGGTGATGCACTGGATGAGAAGAAATTTGAAGCATCA\n".
    "GCAAAGCTAAAAAGGCCATCCCCAAGAAGATCACCACTAGCAGCCGAAAGGATGAGCCCT\n".
    "ATGATCAATACTGGCGCCATGCCACAAGGCAGAAACTCACCATTTGGT\n".
    ">POPTR-0010s18130.1_poplar\n".
    "ATGTTCCATACCAAGAAACCCTCAACTATGAATTCCCATGATAGACCCATGTGTGTTCAA\n".
    "GGGGACTCTGGTCTTGTCCTCACCACAGACCCCAAGCCCCGTCTCCGCTGGACTGTTGAG\n".
    "CTCCATGAACGCTTTGTGGATGCCGTTACTCAGCTTGGAGGCCCAGATAAGGCCACTCCC\n".
    "AAAACCATCATGAGAGTCATGGGTGTGAAGGGTCTTACCCTTTACCACCTCAAAAGCCAT\n".
    "CTTCAGAAATTCAGACTTGGAAAGCAACCACACAAGGATTTCAATGATCATTCAATTAAG\n";

# DNA: Windows line endings, multiple recors
my $test_multi_win_dna_seq = ">POPTR-0010s18130.1_poplar\r\n".
    "ATGTTCCATACCAAGAAACCCTCAACTATGAATTCCCATGATAGACCCATGTGTGTTCAA\r\n".
    "GGGGACTCTGGTCTTGTCCTCACCACAGACCCCAAGCCCCGTCTCCGCTGGACTGTTGAG\r\n".
    "CTCCATGAACGCTTTGTGGATGCCGTTACTCAGCTTGGAGGCCCAGATAAGGCCACTCCC\r\n".
    "AAAACCATCATGAGAGTCATGGGTGTGAAGGGTCTTACCCTTTACCACCTCAAAAGCCAT\r\n".
    "CTTCAGAAATTCAGACTTGGAAAGCAACCACACAAGGATTTCAATGATCATTCAATTAAG\r\n".
    "GATGCTTCGGCGTTAGATCTTCAACGAAGTGCAGCATCTTCATCTGGCATGATGAGCCGC\r\n".
    "AGTATGAATGAGATGCAAATGGAGGTGCAGAGAAGACTGCATGAACAATTAGAGGTTCAA\r\n".
    ">POPTR-0010s18130.1_poplar\r\n".
    "ATGTTCCATACCAAGAAACCCTCAACTATGAATTCCCATGATAGACCCATGTGTGTTCAA\r\n".
    "GGGGACTCTGGTCTTGTCCTCACCACAGACCCCAAGCCCCGTCTCCGCTGGACTGTTGAG\r\n".
    "CTCCATGAACGCTTTGTGGATGCCGTTACTCAGCTTGGAGGCCCAGATAAGGCCACTCCC\r\n".
    "AAAACCATCATGAGAGTCATGGGTGTGAAGGGTCTTACCCTTTACCACCTCAAAAGCCAT\r\n".
    "CTTCAGAAATTCAGACTTGGAAAGCAACCACACAAGGATTTCAATGATCATTCAATTAAG\r\n";

# DNA: Mac line endings, multiple records
my $test_multi_mac_dna_seq = $test_multi_dna_seq;
$test_multi_mac_dna_seq =~ s/\n/\r/g;

#print STDERR "Length ".$length_before." vs. ".$length_after."\n";

#-----------------------------+
# SET THE TEST SEQUENCE       |
#-----------------------------+
my $test_seq = $test_aa_seq;

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
