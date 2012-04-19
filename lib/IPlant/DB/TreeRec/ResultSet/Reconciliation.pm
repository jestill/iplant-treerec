package IPlant::DB::TreeRec::ResultSet::Reconciliation;

use warnings;
use strict;

use IPlant::TreeRec::X;

use base 'DBIx::Class::ResultSet';

##########################################################################
# Usage      : $reconciliation = $dbh->resultset('Reconciliation')
#                  ->for_species_tree_and_family( $species_tree_name,
#                  $family_name );
#
# Purpose    : Finds the reconciliation for the given species tree and
#              family names.
#
# Returns    : The reconciliation.
#
# Parameters : $species_tree_name - the name of the species tree.
#              $family_name       - the name of the gene family.
#
# Throws     : IPlant::TreeRec::ReconciliationNotFoundException.
sub for_species_tree_and_family {
    my ( $self, $species_tree_name, $family_name ) = @_;

    # Find the tree.
    my $tree = $self->find(
        {   'species_tree.species_tree_name' => $species_tree_name,
            'family.stable_id'               => $family_name,
        },
        { 'join' => [ { 'protein_tree' => 'family' }, 'species_tree' ] }
    );
    IPlant::TreeRec::TreeNotFoundException->throw(
        error => "no protein tree found for species tree, $species_tree_name"
            . " and family, $family_name" )
        if !defined $tree;

    return $tree;
}

##########################################################################
# Usage      : $reconciliation = $dbh->resultset('Reconciliation')
#                  ->for_reconciliation_set_id_and_family( $reconciliation_set_id,
#                  $family_name );
#
# Purpose    : Finds the reconciliation for the given reconciliation set and
#              family names.
#
# Returns    : The reconciliation.
#
# Parameters : $reconciliation_set_id - the id of the reconciliation set.
#              $family_name       - the name of the gene family.
#
# Throws     : IPlant::TreeRec::ReconciliationNotFoundException.
sub for_reconciliation_set_id_and_family {
    my ( $self, $reconciliation_set_id, $family_name ) = @_;

    # Find the tree.
    my $tree = $self->find(
        {   'reconciliation_set.reconciliation_set_id' => $reconciliation_set_id,
            'family.stable_id'               => $family_name,
        },
        { 'join' => [ { 'protein_tree' => 'family' }, 'reconciliation_set' ] }
    );
    IPlant::TreeRec::TreeNotFoundException->throw(
        error => "no protein tree found for reconciliation set, $reconciliation_set_id"
            . " and family, $family_name" )
        if !defined $tree;

    return $tree;
}



1;
__END__
