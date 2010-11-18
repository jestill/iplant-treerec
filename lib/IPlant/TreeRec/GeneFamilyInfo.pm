package IPlant::TreeRec::GeneFamilyInfo;

use 5.008000;

use strict;
use warnings;

our $VERSION = '0.0.1';

use Carp;
use Class::Std::Utils;

{
    my %dbh_of;
    my %go_term_length_limit_of;

    ##########################################################################
    # Usage      : $info = IPlant::TreeRec::GeneFamilyInfo->new(
    #                  {   dbh                  => $dbh,
    #                      go_term_length_limit => $limit,
    #                  }
    #              );
    #
    # Purpose    : Creates and initializes a new object instance.
    #
    # Returns    : The new object instance.
    #
    # Parameters : dbh                  - the database handle.
    #              go_term_length_limit - the length limit for the GO term.
    #
    # Throws     : No exceptions.
    sub new {
        my ( $class, $args_ref ) = @_;

        # Extract the arguments.
        my $dbh                  = $args_ref->{dbh};
        my $go_term_length_limit = $args_ref->{go_term_length_limit};

        # Create the new object.
        my $self = bless anon_scalar(), $class;

        # Initialize the object properties.
        $dbh_of{ ident $self }                  = $dbh;
        $go_term_length_limit_of{ ident $self } = $go_term_length_limit;

        return $self;
    }

    ##########################################################################
    # Usage      : N/A
    #
    # Purpose    : Cleans up after an instance of this class has gone out of
    #              scope.
    #
    # Returns    : Nothing.
    #
    # Parameters : None.
    #
    # Throws     : No exceptions.
    sub DESTROY {
        my ($self) = @_;

        # Clean up.
        delete $dbh_of{ ident $self };
        delete $go_term_length_limit_of{ ident $self };

        return;
    }

    ##########################################################################
    # Usage      : $summary_ref
    #                  = $info->get_summary( $family_name, $tree);
    #
    # Purpose    : Obtains summary information for a gene family.
    #
    # Returns    : The summary information.
    #
    # Parameters : $family_name - the gene family name.
    #              $tree        - the gene family tree.
    #
    # Throws     : No exceptions.
    sub get_summary {
        my ( $self, $family_name, $tree ) = @_;

        # Obtain the tree counts.
        my $summary_ref = $self->_get_tree_counts($tree);

        # Obtain the first GO term.
        $summary_ref->{go_annotations} = $self->_get_go_term($family_name);

        return $summary_ref;
    }

    ##########################################################################
    # Usage      : $details_ref
    #                  = $info->get_details( $family_name, $tree);
    #
    # Purpose    : Obtains detail information for a gene family.  Currently,
    #              the detail information is the same as the summary
    #              information except that the entire list of GO annotatins
    #              is included in the detail information.
    #
    # Returns    : The detail information.
    #
    # Parameters : $family_name - the gene family name.
    #              $tree        - the gene family tree.
    #
    # Throws     : No exceptions.
    sub get_details {
        my ( $self, $family_name, $tree ) = @_;

        # Obtain the tree counts.
        my $details_ref = $self->_get_tree_counts($tree);

        # Obtain all of the GO terms.
        $details_ref->{go_annotations}
            = [ $self->_get_all_go_terms($family_name) ];

        return $details_ref;
    }

    ##########################################################################
    # Usage      : $truncated_go_term
    #                  = $info->_get_go_term($family_name);
    #
    # Purpose    : Retrieves the first GO term for the given gene family and
    #              truncates it if there's a length limit.
    #
    # Returns    : The truncated GO term.
    #
    # Parameters : $family_name - the name of the gene family.
    #
    # Throws     : No exceptions.
    sub _get_go_term {
        my ( $self, $family_name ) = @_;

        # Fetch the first GO term.
        my @go_terms = $self->_get_all_go_terms($family_name);
        my $go_term = scalar @go_terms > 0 ? $go_terms[0] : "";

        # Add an ellipsis for long or multiple terms.
        my $length_limit = $go_term_length_limit_of{ ident $self };
        if ( defined $length_limit ) {
            if ( length $go_term > $length_limit || scalar @go_terms > 0 ) {
                $go_term = substr( $go_term, 0, $length_limit - 3 ) . "...";
            }
        }

        return $go_term;
    }

    ##########################################################################
    # Usage      : @go_terms = $info->_get_all_go_terms($family_name);
    #
    # Purpose    : Retrieves the GO terms for the given gene family.
    #
    # Returns    : The list of GO terms.
    #
    # Parameters : $family_name - the name of the gene family.
    #
    # Throws     : No exceptions.
    sub _get_all_go_terms {
        my ( $self, $family_name )  = @_;

        # Get all of the GO term objects from the database.
        my $dbh     = $dbh_of{ ident $self };
        my @results = $dbh->resultset('GoTermsForFamily')
            ->search( {}, { 'bind' => [$family_name] } );

        # Extract the actual GO term from each of the GO term objects.
        return map { $_->go_term() } @results;
    }

    # A data structure used for counting specific node types.
    my %NODE_COUNTER_FOR = (
        gene_count         => \&_count_gene_nodes,
        duplication_events => \&_count_duplication_events,
        speciation_events  => \&_count_speciation_events,
        species_count      => \&_count_species,
    );

    # A hash of unique species names.
    my %seen_species;

    ##########################################################################
    # Usage      : $counts_ref = $info->_get_tree_counts($tree);
    #
    # Purpose    : Obtains the node counts for the tree.
    #
    # Returns    : A reference to the counts hash.
    #
    # Parameters : $tree - the tree to obtain the counts from.
    #
    # Throws     : No exceptions.
    sub _get_tree_counts {
        my ( $self, $tree ) = @_;

        # Initialize any temporary data structures.
        %seen_species = ();

        # Determine the node where we're supposed to start counting.
        my $start_node = ( $tree->get_root_node()->each_Descendent() )[0];

        # Count the special nodes in the tree.
        return $self->_get_subtree_counts( $start_node, {} );
    }

    ##########################################################################
    # Usage      : $counts_ref = $info->_get_subtree_counts( $node,
    #                  $counts_ref );
    #
    # Purpose    : Adds the node counts for the subtree rooted at the given
    #              node to the given counts hash.
    #
    # Returns    : A reference to the counts hash.
    #
    # Parameters : $node       - the root of the subtree we're counting.
    #              $counts_ref - a reference to the counts hash.
    #
    # Throws     : No exceptions.
    sub _get_subtree_counts {
        my ( $self, $node, $counts_ref ) = @_;

        # Update the counts for the current node.
        for my $count_id ( keys %NODE_COUNTER_FOR ) {
            my $counter_ref = $NODE_COUNTER_FOR{$count_id};
            $counts_ref->{$count_id} += $counter_ref->($node);
        }

        # Update the counts for the subtrees rooted at this node's children.
        for my $child ( $node->each_Descendent() ) {
            $self->_get_subtree_counts( $child, $counts_ref );
        }

        return $counts_ref;
    }

    ##########################################################################
    # Usage      : $gene_count += _count_gene_nodes($node);
    #
    # Purpose    : Determines whether or not the given tree node represents a
    #              gene and returns the number of genes represented by the
    #              node (that is, 0 or 1).
    #
    # Returns    : The number of genes represented by the node.
    #
    # Parameters : $node - the node.
    #
    # Throws     : No exceptions.
    sub _count_gene_nodes {
        return $_[0]->is_Leaf() ? 1 : 0;
    }

    ##########################################################################
    # Usage      : $duplication_event_count
    #                  += _count_duplication_events($node);
    #
    # Purpose    : Determines whether or not the given tree node represents a
    #              duplication events and returns the number of duplication
    #              events represented by the node (that is, 0 or 1).
    #
    # Returns    : The number of duplication events represented by the node.
    #
    # Parameters : $node - the node.
    #
    # Throws     : No exceptions.
    sub _count_duplication_events {
        my $value = $_[0]->get_tag_values('D');
        return defined $value && ',Y,T,' =~ m/,$value,/ixms ? 1 : 0;
    }

    ##########################################################################
    # Usage      : $speciation_event_count
    #                  += _count_speciation_events($node);
    #
    # Purpose    : Determines whether or not the given tree node represents a
    #              speciation events and returns the number of speciation
    #              events represented by the node (that is, 0 or 1).
    #
    # Returns    : The number of speciation events represented by the node.
    #
    # Parameters : $node - the node.
    #
    # Throws     : No exceptions.
    sub _count_speciation_events {
        my $value = $_[0]->get_tag_values('D');
        return defined $value && ',N,F,' =~ m/,$value,/ixms ? 1 : 0;
    }

    ##########################################################################
    # Usage      : $species_count += _count_species($node);
    #
    # Purpose    : Determines whether or not the given tree node is associated
    #              with a species that hasn't been counted yet and returns the
    #              number of unseen species represented by the node (that is,
    #              0 or 1).
    #
    # Returns    : The number of unseen speices represented by the node.
    #
    # Parameters : $node - the node.
    #
    # Throws     : No exceptions.
    sub _count_species {
        my $species = $_[0]->get_tag_values('S');
        my $count
            = !defined $species ? 0
            : $species =~ m/ snode \d+ /xms ? 0
            : $seen_species{$species}++ > 0 ? 0
            :                                 1;
        return $count;
    }
}

1;
__END__
