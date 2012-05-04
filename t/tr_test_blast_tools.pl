#!/usr/bin/perl -w
#-----------------------------------------------------------+
#                                                           |
# tr_test_blast_tools.pl                                    |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 01/27/2011                                       |
# UPDATED: 01/28/2011                                       |
#                                                           |
# DESCRIPTION:                                              | 
#  Code to test the IPlant::TreeRec::BlastSearcher          |
#                                                           |
# USAGE: tr_test_blast_tools.pl                             |
#                                                           |
#-----------------------------------------------------------+

use strict;
use IPlant::TreeRec::BlastSearcher;
use IPlant::TreeRec::BlastArgs;
use JSON qw();

my $verbose = 1;

my $exec_dir = "/usr/local/ncbi/blast/bin/";
my $db_dir = "/Users/jestill/blastplus_dir/";

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

#-----------------------------+
# DETECT SEQUENCE TYPE        |
#-----------------------------+
my $sequence_type = detect_sequence_type($test_seq);

print STDERR "Seq is:\n$test_seq\n";
print STDERR "Sequence type is: $sequence_type\n";

#-----------------------------+
# SET THE BLAST PROGRAM TO    |
# USE BASED ON SEQ TYPE       |
#-----------------------------+
my $blast_program;
if ($sequence_type =~ "protein") {
    $blast_program = 'blastp';
}
else {
    $blast_program = 'tblastx';
}

my $blast_searcher = new IPlant::TreeRec::BlastSearcher ( 
    {
	'executable_dir' => $exec_dir,
	'database_dir'   => $db_dir
    }
    );


my $blast_args = IPlant::TreeRec::BlastArgs->_new ( 
    {
	'executable'    => $blast_program,
	'sequence'      => $test_seq,
	'database'      => 'all_pgclusters_aa',
	'evalue'        => '0.0001',
	'max_num_seqs'  => '20',

    } 
    );


# Show the sequence used
my $sequence_used = $blast_args->get_sequence();
print STDERR "SEQ: ".$sequence_used."\n";
print STDERR "Program: ".$blast_program."\n";

#-----------------------------+
# DO BLAST ARRAY METHOD
#-----------------------------+
my @gene_ids = $blast_searcher->search($blast_args);
my $num_gene_ids = @gene_ids;
print STDERR "Num Genes Found:".$num_gene_ids."\n";
for my $ind_gene_id (@gene_ids) {
    print STDERR "\t$ind_gene_id\n";
}

#-----------------------------+
# BLAST RESULTS
#-----------------------------+
#my $blast_result = $blast_searcher->search($blast_args);
#print STDERR $blast_result."\n".

#print STDERR "Program finished\n";

1;
exit;



#-----------------------------+
# TEST OF AUTODETECT
# SEQUENCE TYPE
#-----------------------------+
# Return nucleotide or protein

sub detect_sequence_type {
    my ( $seq_in ) = @_;

    # Remove FASTA headers if present
    # This allows the search for AA diagnostic characters to work
    
#   my $seq_test_in_length = length ($seq_in);
#   print STDERR "Testing sub in:\n".$seq_in."\n\n\n"
#	if $verbose;
#    print STDERR "Testing sub length:\n".$seq_test_in_length."\n"
#	if $verbose;

    # Remove FASTA header for mac line endings
#    $seq_in =~ s{\> [^\r]* }{}gxms; 
    # Remove FASTA header for unix and windows line endings
    $seq_in =~ s{\> [^\n]* }{}gxms; 

#    my $seq_test_in_clip_len = length($seq_in);
    print STDERR "Testing clipped:\n".$seq_in."\n\n\n"
	if $verbose;
#    print STDERR "Testing clipped length:".$seq_test_in_clip_len."\n"
#	if $verbose;

    #   EFILPQ are diagnostic protein sequence residues
    if ($seq_in =~ m/(E|F|I|L|P|Q|e|f|i|l|p|q)/xms) {
	return "protein";
    }
    else {
	return "dna";
    }
    
}

__END__
