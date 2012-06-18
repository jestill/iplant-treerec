package IPlant::TreeRec::ReconciliationSetFinder;

use 5.008000;

use strict;
use warnings;

our $VERSION = '0.0.1';

use Carp;
use Class::Std::Utils;
use IPlant::TreeRec::X;
use Readonly;

{
    my %dbh_of;

    ##########################################################################
    # Usage      : $finder = IPlant::TreeRec::ReconciliationSetFinder->new($dbh);
    #
    # Purpose    : Creates a new reconciliation set finder.
    #
    # Returns    : The new finder.
    #
    # Parameters : $dbh - the database handle.
    #
    # Throws     : No exceptions.
    sub new {
        my ( $class, $dbh ) = @_;

        # Create the new object.
        my $self = bless anon_scalar(), $class;

        # Initialize the properties.
        $dbh_of{ ident $self } = $dbh;

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

        return;
    }


    ##########################################################################
    # Usage      : $reconciliations = $finder->get_reconciliation_sets()
    #
    #
    # Purpose    : Gets the list of reconciliation sets 
    #
    # Returns    : A list of available reconciliation sets
    #
    # Parameters :None 
	#
    #
    # Throws     : No exceptions.
    sub get_reconciliation_sets {
        my ( $self ) = @_;

        # Fetch the database handle.
        my $dbh = $dbh_of{ ident $self };


        # Obtain the reconciliation sets.
        my $reconciliation_sets=$dbh->resultset('ReconciliationSet')->reconciliations();
  		return $reconciliation_sets;
    }


    ##########################################################################
    # Usage      : $details = $finder->get_reconciliation_set_details(
    #								  $reconciliation_set_id)
    #
    #
    # Purpose    : Gets the details of a given reconciliation set
    #
    # Returns    : The details
    #
    # Parameters :$reconciliation_set_id - the id of the reconciliation set
	#
    #
    # Throws     : No exceptions.
    sub get_reconciliation_set_details{
    	my ( $self,$reconciliation_set_id ) = @_;	
    	
        # Fetch the database handle.
        my $dbh = $dbh_of{ ident $self };


        # Obtain the reconciliation set fetails
        my $reconciliation_set_details=$dbh->resultset('ReconciliationSetAttribute')
        	->find( 
    	{ 'reconciliation_set_id' => $reconciliation_set_id }
    	);
       	
  		return $reconciliation_set_id;    	
    	
 	}
 	
 	
    ##########################################################################
    # Usage      : $reconciliations = $finder->blast($sequence)
    #
    #
    # Purpose    : Gets the list of reconciliation sets that contain a given sequence
    #
    # Returns    : A list of reconciliation sets
    #
    # Parameters :None 
	#
    #
    # Throws     : No exceptions.
    sub blast {}

    ##########################################################################
    # Usage      : $reconciliations = $finder->go_search($go_term)
    #
    #
    # Purpose    : Gets the list of reconciliation sets that contain a given go term or accession
    #
    # Returns    : A list of reconciliation sets
    #
    # Parameters :None 
	#
    #
    # Throws     : No exceptions.
    sub go_search {}


    ##########################################################################
    # Usage      : $reconciliations = $finder->by_family($family)
    #
    #
    # Purpose    : Gets the list of reconciliation sets that contain a given gene family
    #
    # Returns    : A list of reconciliation sets
    #
    # Parameters :None 
	#
    #
    # Throws     : No exceptions.
    sub by_family {}
    
    ##########################################################################
    # Usage      : $reconciliations = $finder->by_species($species)
    #
    #
    # Purpose    : Gets the list of reconciliation sets that contain a given species
    #
    # Returns    : A list of reconciliation sets
    #
    # Parameters :None 
	#
    #
    # Throws     : No exceptions.
    sub by_species {}    
    
    ##########################################################################
    # Usage      : $reconciliations = $finder->by_method($species)
    #
    #
    # Purpose    : Gets the list of reconciliation sets that contain a given species
    #
    # Returns    : A list of reconciliation sets
    #
    # Parameters :None 
	#
    #
    # Throws     : No exceptions.
    sub by_method {}   	
}

1;
__END__
