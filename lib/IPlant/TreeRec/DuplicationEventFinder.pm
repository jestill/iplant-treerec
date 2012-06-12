package IPlant::TreeRec::DuplicationEventFinder;

use warnings;
use strict;

our $version = '0.0.2';

use Carp;
use Class::Std::Utils;
use English qw( -no_match_vars );

{
    my %dbh_of;

    ##########################################################################
    # Usage      : $finder = IPlant::TreeRec::DuplicationEventFinder->new(
    #                  $dbh);
    #
    # Purpose    : Initializes a new duplication event finder with the given
    #              database handle.
    #
    # Returns    : The new duplication event finder.
    #
    # Parameters : $dbh - the database handle.
    #
    # Throws     : No exceptions.
    sub new {
        my ( $class, $dbh ) = @_;

        # Create the new object.
        my $self = bless anon_scalar, $class;

        # Initialize the properties.
        $dbh_of{ ident $self } = $dbh;

        return $self;
    }

#TODO: Refactor to use $reconciliation_set_id - Done
    ##########################################################################
    # Usage      : @families = $finder->find_duplication_events(
    #                  $node_id, $edge_selected, $reconciliation_set_id );
    #
    # Purpose    : Finds duplication events that are located in a specified
    #              place on a species tree for a given reconciliation set id.
    #
    # Returns    : The list of gene family names.
    #
    # Parameters : $node_id       - the identifier of the selected node or the
    #                               node that the selected edge leads into.
    #              $edge_selected - true if the edge leading into the node
    #                               with the given ID is selected.
    #			   $reconciliation_set_id - the reconciliation set id
    #
    # Throws     : No exceptions.
    sub find_duplication_events {
        my ( $self, $node_id, $edge_selected, $reconciliation_set_id ) = @_;

        # Find the duplication events.
        my $dbh = $dbh_of{ ident $self };
        my @family_names = $dbh->resultset('DuplicationSearch')
            ->search( {}, { 'bind' => [ $node_id, !$edge_selected , $reconciliation_set_id] } );
        return @family_names;
    }
}

1;
__END__
