package IPlant::TreeRec::REST::Initializer;

use 5.008000;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(get_tree_rec);

our $VERSION = '0.0.2';

use IPlant::DB::TreeRec;
use IPlant::TreeRec::BlastSearcher;
use IPlant::TreeRec::DatabaseTreeLoader;
use IPlant::TreeRec::FileRetriever;
use IPlant::TreeRec::FileTreeLoader;
use IPlant::TreeRec::GeneFamilyInfo;
use IPlant::TreeRec::GeneTreeEvents;
use IPlant::TreeRec::X;
use IPlant::TreeRec;
use Readonly;


Readonly my $TREE_FILE_EXTENSION  => '_genetree.nhx';
Readonly my $TREE_FILE_FORMAT     => 'nhx';
Readonly my $GO_TERM_LENGTH_LIMIT => 30;

##########################################################################
# Usage      :
# Purpose    :
# Returns    :
# Parameters :
# Throws     : No exceptions.
# Comments   : None.
# See Also   : N/A
sub get_tree_rec {
    my ($request) = @_;

    # Extract the configuraiton parameters.
    my $dsn                  = $request->dir_config('TreeRecDsn');
    my $user                 = $request->dir_config('TreeRecUser');
    my $password             = $request->dir_config('TreeRecPassword');
    my $data_dir             = $request->dir_config('TreeRecDataDir');
    my $blast_exe_dir        = $request->dir_config('TreeRecBlastExeDir');
    my $blast_db_dir         = $request->dir_config('TreeRecBlastDbDir');
    my $default_species_tree = $request->dir_config('DefaultSpeciesTree');
    my @go_categories        = $request->dir_config('TreeRecGoCategories');

    # Establish the database connection.
    my $dbh = IPlant::DB::TreeRec->connect( $dsn, $user, $password );
    IPlant::TreeRec::DatabaseException->throw() if !defined $dbh;

    # Create the tree loader.
    my $tree_loader = IPlant::TreeRec::DatabaseTreeLoader->new($dbh);

    # Create the gene family info.
    my $gene_family_info = IPlant::TreeRec::GeneFamilyInfo->new(
        {   dbh                  => $dbh,
            go_term_length_limit => 30,
            go_categories        => \@go_categories,
        }
    );

    # Create the file retriever.
    my $file_retriever
        = IPlant::TreeRec::FileRetriever->new( { data_dir => $data_dir } );

    # Create the BLAST searcher.
    my $blast_searcher = IPlant::TreeRec::BlastSearcher->new(
        {   executable_dir => $blast_exe_dir,
            database_dir   => $blast_db_dir,
        }
    );
    
    # Create the gene tree event list.
    my $gene_tree_events = IPlant::TreeRec::GeneTreeEvents->new(
        {   dbh                  => $dbh,
        }
    );
    

    # Create the tree reconciliation object.
    my $treerec = IPlant::TreeRec->new(
        {   dbh                  => $dbh,
            gene_tree_loader     => $tree_loader,
            gene_family_info     => $gene_family_info,
            file_retriever       => $file_retriever,
            blast_searcher       => $blast_searcher,
            gene_tree_events     => $gene_tree_events,
            default_species_tree => $default_species_tree,
        }
    );

    return $treerec;
}

1;
__END__
