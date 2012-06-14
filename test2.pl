#!/usr/bin/perl

use warnings;
use strict;

use lib 'lib';
#did it work
use Carp;
use Data::Dumper;
use DBI;
use English qw(-no_match_vars);
use Exception::Class;
use IPlant::TreeRec;
use IPlant::TreeRec::BlastArgs;
use IPlant::TreeRec::BlastSearcher;
use IPlant::TreeRec::DatabaseTreeLoader;
use IPlant::TreeRec::FileRetriever;
use IPlant::TreeRec::FileTreeLoader;
use IPlant::TreeRec::GeneFamilyInfo;
use IPlant::TreeRec::GeneTreeEvents;
use IPlant::TreeRec::SpeciesTreeEvents;
use IPlant::TreeRec::GoCloud;
use JSON qw();
use Perl6::Slurp;

use constant PASSWORD_FILE => "$ENV{HOME}/mysql.tr_searcher";

local $Data::Dumper::Useqq = 1;

# Establish the database connection.
my $dsn      = "DBI:mysql:database=tree_reconciliation";
my $user     = "tr_searcher";
my $password = load_password();
my $dbh      = IPlant::DB::TreeRec->connect( $dsn, $user, $password );


# Create the tree loader.
#my $tree_loader = IPlant::TreeRec::FileTreeLoader->new(
#    {   data_dir           => '/home/dennis/treerec/clusters',
#        filename_extension => '_genetree.nhx',
#        tree_format        => 'nhx',
#    }
#);
my $tree_loader = IPlant::TreeRec::DatabaseTreeLoader->new($dbh);

# Create the gene family info.
my $gene_family_info = IPlant::TreeRec::GeneFamilyInfo->new(
    {   dbh                  => $dbh,
        go_term_length_limit => 30,
    }
);

# Create the file retriever.
my $file_retriever = IPlant::TreeRec::FileRetriever->new(
    { data_dir => '/home/dennis/treerec/clusters' } );

# Create the BLAST searcher.
my $blast_searcher = IPlant::TreeRec::BlastSearcher->new(
    {   executable_dir => '/usr/bin',
        database_dir   => '/home/dennis/treerec/blastdb',
    }
);

# Create the gene tree decorations
my $gene_tree_events = IPlant::TreeRec::GeneTreeEvents->new(
	{	  dbh                  => $dbh,		
	}
);

# Create the species tree decorations
my $species_tree_events = IPlant::TreeRec::SpeciesTreeEvents->new(
	{	  dbh                  => $dbh,		
	}
);



# Create the tree reconciliation object.
my $treerec = IPlant::TreeRec->new(
    {   dbh              => $dbh,
        gene_tree_loader => $tree_loader,
        gene_family_info => $gene_family_info,
        file_retriever   => $file_retriever,
        blast_searcher   => $blast_searcher,
        gene_tree_events =>$gene_tree_events,
        species_tree_events =>$species_tree_events,
        
    }
);


my$go_term='transport';
my$reconciliation_set_id=0;
my$family_name='pg13389';
my$go_accession="0031124";
my$gene_id="V01G0907";
my$json=JSON->new()->encode({ 'familyName'=>$family_name, 'reconciliationSetId'=>$reconciliation_set_id});
my$json2= JSON->new()->encode(
            {   'reconciliationSetId' => $reconciliation_set_id,
                 'nodeId' => 3,
                 'edgeSelected'    => 1,
             }
         );
my$json3= JSON->new()->encode(
            {   'reconciliationSetId' => $reconciliation_set_id,
            	'familyName' => $family_name,
                 'speciesTreeNode' => 8,
                 'edgeSelected'    => 0,
             }
         );
my$json4= JSON->new()->encode(
            {   'familyName' => $family_name,
                 'speciesTreeNode' => 8,
             }
         );
         
eval {
     

    ##########################################################################
    # Usage      : $results_ref = $treerec->general_go_search( $search_string,
    #                  $reconciliation_set_id );
    #
    # Purpose    : Performs a search for a GO term or a GO accession
    #              number.
    #
    # Returns    : Information about the matching gene families.
    #
    # Parameters : $search_string     - the string to search for.
    #              $reconciliation_set_id - the id of the reconciliation set.
    #
    # Throws     : No exceptions.
#    warn Dumper $treerec->general_go_search($go_term,$reconciliation_set_id); #PASS
 

    ##########################################################################
    # Usage      : $results_ref = $treerec->go_search( $search_string,
    #                  $reconciliation_set_id );
    #
    # Purpose    : Performs a GO search.
    #
    # Returns    : Information about the matching gene families.
    #
    # Parameters : $search_string     - the string to search for.
    #              $reconciliation_set_id - the id of the reconciliation set.
    #
    # Throws     : No exceptions.
#     warn Dumper $treerec->go_search($go_term,0); #PASS

    ##########################################################################
    # Usage      : $results_ref = $treerec->go_accession_search(
    #                  $search_string, $reconciliation_set_id );
    #
    # Purpose    : Performs a search by GO accession.
    #
    # Returns    : Information about the matching gene families.
    #
    # Parameters : $search_string     - the string to search for.
    #              $reconciliation_set_id - the id of the reconciliation set.
    #
    # Throws     : No exceptions.
#	warn Dumper $treerec->go_accession_search($go_accession,0); #PASS

    ##########################################################################
    # Usage      : $results_ref = $treerec->gene_id_search( $search_string,
    #                  $reconciliation_set_id );
    #
    # Purpose    : Performs a gene identifier search.
    #
    # Returns    : Information about the matching gene families.
    #
    # Parameters : $search_string     - the string to search for.
    #              $reconciliation_set_id - the id of the reconciliation set.
    #
    # Throws     : No exceptions.
#   warn Dumper $treerec->gene_id_search($gene_id,0); #PASS



    ##########################################################################
    # Usage      : $results_ref = $treerec->get_gene_family_summary(
    #                  $family_name, $reconciliation_set_id );
    #
    # Purpose    : Gets the summary information for the given gene family
    #              name.  The results of this method are returned as a single-
    #              element array reference in order to match the results of
    #              the search methods.
    #
    # Returns    : A reference to a list containing the single gene family
    #              summary or a reference to an empty list of the gene family
    #              doesn't exist.
    #
    # Parameters : $family_name       - the name of the gene family.
    #              $reconciliation_set_id - id of the reconciliation set.
    #
    # Throws     : No exceptions.
#	warn Dumper $treerec->get_gene_family_summary($family_name, $reconciliation_set_id ); #PASS w POTENTIAL PROBLEM (undef GO)

    ##########################################################################
    # Usage      : $results_ref = $treerec->get_gene_family_details(
    #                  $family_name, $reconciliation_set_id );
    #
    # Purpose    : Retrieves the gene family details for the given gene family
    #              name.
    #
    # Returns    : Detailed information about the gene family.
    #
    # Parameters : $family_name       - the gene family name.
    #              $reconciliation_set_id - the reconciliation set id.
    #
    # Throws     : IPlant::TreeRec::GeneFamilyNotFoundException
    #              IPlant::TreeRec::TreeNotFoundException
# 	warn Dumper $treerec->get_gene_family_details($family_name, $reconciliation_set_id ); #PASS


    ##########################################################################
    # Usage      : $results_ref = $treerec->get_gene_tree_events(
    #                  $family_name, $reconciliation_set_id );
    #
    # Purpose    : Retrieves the evolutionary events on the given gene family
    #              name.
    #
    # Returns    : Events.
    #
    # Parameters : $family_name       - the gene family name.
    #              $reconciliation_set_id - the reconciliation set id.
    #
    # Throws     : IPlant::TreeRec::GeneFamilyNotFoundException
    #              IPlant::TreeRec::TreeNotFoundException
#    warn Dumper $treerec->get_gene_tree_events($family_name, $reconciliation_set_id ); #PASS

    ##########################################################################
    # Usage      : $text = $treerec->get_gene_tree_file($json);
    #
    # Purpose    : Gets the gene tree for the gene family with the given name.
    #
    # Returns    : The gene tree.
    #
    # Parameters : familyName       - the name of the gene family.
    #              
    #
    # Throws     : IPlant::TreeRec::GeneFamilyNotFoundException
    #              IPlant::TreeRec::TreeNotFoundException
    #              IPlant::TreeRec::ReconciliationNotFoundException
    #              IPlant::TreeRec::IllegalArgumentException
#    warn Dumper $treerec->get_gene_tree_file($json); #PASS

    ##########################################################################
    # Usage      : $data_ref = $treerec->get_gene_tree_data($json);
    #
    # Purpose    : Retrieves the gene tree for the gene family with the given
    #              name as a Perl data structure.
    #
    # Returns    : The tree data.
    #
    # Parameters : familyName      - the name of the gene family.
    #              reconciliationSetId - the reconciliation set id.
    #
    # Throws     : IPlant::TreeRec::GeneFamilyNotFoundException
    #              IPlant::TreeRec::TreeNotFoundException
    #              IPlant::TreeRec::ReconciliationNotFoundException
    #              IPlant::TreeRec::IllegalArgumentException
# 	warn Dumper $treerec->get_gene_tree_data($json); #PASS w BioPerl exception on Destructor

    ##########################################################################
    # Usage      : $text = $treerec->get_species_tree_file($json);
    #
    # Purpose    : Retrieves the species tree in NHX format.
    #
    # Returns    : The species tree.
    #
    # Parameters : speciesTreeName - the name of the species tree.
    #              familyName      - the name of the related gene tree.
    #
    # Throws     : IPlant::TreeRec::TreeNotFoundException
    #              IPlant::TreeRec::IllegalArgumentException
#    warn Dumper $treerec->get_species_tree_file($json); #PASS

    ##########################################################################
    # Usage      : $data_ref = $treerec->get_species_tree_data($json)
    #
    # Purpose    : Retrieves species tree data in NHX format.
    #
    # Returns    : The species tree data.
    #
    # Parameters : speciesTreeName - the name of the species tree.
    #              familyName      - the name of the related gene tree.
    #
    # Throws     : IPlant::TreeRec::TreeNotFoundException
    #              IPlant::TreeRec::IllegalArgumentException
#	 warn Dumper $treerec->get_species_tree_data($json);#PASS w BioPerl exception on Destructor

    ##########################################################################
    # Usage      : $data_ref = $treerec->get_species_tree_events(
    #			   $family_name, $reconciliation_set_id)
    #
    # Purpose    : Retrieves duplication events along the species tree.
    #
    # Returns    : The duplication events.
    #
    # Parameters : reconciliationSetId - the reconciliation set id.
    #              familyName      - the name of the related gene tree.
    #			   If no family name is provided the duplications across
    #			   all gene families are returned
    #
    # Throws     : IPlant::TreeRec::TreeNotFoundException
    #              IPlant::TreeRec::IllegalArgumentException
#   warn Dumper $treerec->get_species_tree_events( $family_name, $reconciliation_set_id); #PASS Note: result seems meaningless
#   warn Dumper $treerec->get_species_tree_events( undef,0); #PASS Note: result seems meaningless

    ##########################################################################
    # Usage      : @families = $treerec->find_duplication_events($json);
    #
    # Purpose    : Retrieves the names of gene families with duplication
    #              events at a selected location in a species tree.
    #
    # Returns    : A reference to a hash containing the list of family names.
    #
    # Parameters : nodeId       - the identifier of the selected node or the
    #                             node that the selected edge leads into.
    #              edgeSelected - true if the edge leading into the node is
    #                             selected rather than the node itself.
    #			   reconciliationSetId - the reconciliation set Id.
    #
    # Throws     : IPlant::TreeRec::IllegalArgumentException
#	warn Dumper $treerec->find_duplication_events($json2); #PASS w POTENTIAL PROBLEM (undef GO)

    ##########################################################################
    # Usage      : $file_info_ref = $treerec->get_file( $type, $prefix );
    #
    # Purpose    : Retrieves the file of the given type, optionally with the
    #              given filename prefix.
    #
    # Returns    : Information about the file in the form of a hash reference
    #              containing the file name, content type and contents.
    #
    # Parameters : $type   - the type of file being retrieved.
    #              $prefix - the filename prefix.
    #
    # Throws     : No exceptions.
#TODO

    ##########################################################################
    # Usage      : $results_ref = $treerec->blast_search( $blast_args_json
    #                  $species_tree_name );
    #
    # Purpose    : Performs a BLAST search on the given BLAST arguments
    #              search.
    #
    # Returns    : Summaries of all of the matching gene families.
    #              Relevant Keys as:
    #               geneFamilyName
    #               length
    #               evalue
    #
    # Parameters : $blast_args_json   - a JSON string representing the search
    #                                   parameters.
    #              $species_tree_name - the name of the species tree.
    #
    # Throws     : No exceptions.
#TODO



    ##########################################################################
    # Usage      : $results_ref = $treerec->resolve_reconciliations($json);
    #
    # Purpose    : Searches for reconciliation nodes matching the given search
    #              parameters.  The species tree name and family name are
    #              always required.  The species tree node and edge-selected
    #              flag are required to find gene tree nodes corresponding to
    #              a species tree node.  The gene tree node is required to
    #              find species tree nodes corresponding to a gene tree node.
    #
    # Returns    : A reference to an array of matching reconciliation node
    #              information.  Eadch element in the result array is a fully
    #              populated version of the search parameters hash.
    #
    # Parameters : speciesTreeName - the name of the species tree.
    #              familyName      - the name of the gene family.
    #              speciesTreeNode - the species tree node ID.
    #              geneTreeNode    - the gene tree node ID.
    #              edgeSelected    - true if the leading edge is selected.
    #
    # Throws     : IPlant::TreeRec::IllegalArgumentException
    #              IPlant::TreeRec::TreeNotFoundException
    #              IPlant::TreeRec::GeneFamilyNotFoundException
    #              IPlant::TreeRec::ReconciliationNotFoundException
#warn Dumper $treerec->resolve_reconciliations($json3); #PASS


    ##########################################################################
    # Usage      : $results_ref = $treerec->genes_for_species($json);
    #
    # Purpose    : Gets the list of gene tree nodes for the given gene family
    #              name and species tree node ID.
    #
    # Returns    : A reference to a hash containing a reference to a list of
    #              gene tree node IDs.
    #
    # Parameters : familyName      - the gene family name.
    #              speciesTreeNode - the species tree node ID.
    #
    # Throws     : IPlant::TreeRec::TreeNotFoundException
    #              IPlant::TreeRec::NodeNotFoundException
# 	warn Dumper $treerec->genes_for_species($json4); #PASS BUT NEEDS REFACTORING
};

if ( my $e = Exception::Class->caught() ) {
    warn "Exception: $e";
    if ( ref $e ) {
        warn $e->trace()->as_string();
    }
}

exit;

sub load_password {
    my $file = PASSWORD_FILE;

    # Open the file.
    open my $in, '<', $file
        or croak "unable to open $file for input: $ERRNO";

    # Load the contents of the file.
    my $pwd = do { local $\; <$in> };

    # Close the file.
    close $in
        or croak "unable to close $file: $ERRNO";

    return $pwd;
}
__END__

=head1 NAME

IPlant::TreeRec - perl extension for accessing reconciled gene trees.

=head1 VERSION

This documentation refers to IPlant::TreeRec version 0.0.3.

=head1 SYNOPSIS

    use IPlant::TreeRec;

    # Create a new object.
    $treerec = IPlant::TreeRec->new(
        {   dbh              => $dbh,
            gene_tree_loader => $tree_loader,
            gene_family_info => $info,
            file_retreiver   => $file_retriever,
            blast_searcher   => $blast_searcher,
        }
    );

    # Perform a GO term search.
    $results_ref = $treerec->go_search($search_term);

    # Perform a GO accession search.
    $results_ref = $treerec->go_accession_search($accession);

    # Perform a BLAST search.
    $results_ref = $treerec->blast_search($blast_args);

    # Perform a gene identifier search.
    $results_ref = $treerec->gene_id_search($gene_id);

    # Get information about a gene family.
    $details_ref = $treerec->gene_family_details($family_name);

    # Get file metadata and contents.
    $file_info = $treerec->get_file( $file_type, $file_name_prefix );

=head1 DESCRIPTION

Provides high-level functions for obtaining information about reconciled
gene families.

=head1 AUTHOR

Dennis Roberts (dennis@iplantcollaborative.org)
James Estill
Naim Matasci

