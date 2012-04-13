#!/usr/bin/perl

use warnings;
use strict;
use Benchmark qw(:all);

use lib 'lib';

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
 my$t = timeit(1, sub{
 

eval {

#    warn Dumper $treerec->get_species_tree_events("pg00892");
#    warn Dumper $treerec->get_species_tree_events();
    warn Dumper $treerec->find_duplication_events(
           JSON->new()->encode(
             {   'nodeId' => 3,
                 'edgeSelected'      => 1,
             }
         )
    );
};
 });
print "code took:",timestr($t),"\n";

if ( my $e = Exception::Class->caught() ) {
    warn "Exception: $e";
    if ( ref $e ) {
        warn $e->trace()->as_string();
    }
	
}

exit;

##########################################################################
# Usage      : $password = load_password();
#
# Purpose    : Loads the password from the password file.
#
# Returns    : The password.
#
# Parameters : None.
#
# Throws     : "unable to open $file for input: $reason"
#              "unable to close $file: $reason"
sub load_password {
    my $file = PASSWORD_FILE;

    # Open the file.
    open my $in, '<', $file
        or croak "unable to open $file for input: $ERRNO";

    # Load the contents of the file.
    my $password = do { local $\; <$in> };

    # Close the file.
    close $in
        or croak "unable to close $file: $ERRNO";

    return $password;
}


__END__

=head1 NAME

UNKNOWN


=head1 VERSION

This documentation refers to UNKNOWN version NA


=head1 SYNOPSIS

	use 


=head1 SUBROUTINES/METHODS


=head1 LICENSE & COPYRIGHT

Copyright (c) 2011, The Arizona Board of Regents on behalf of The University of Arizona

All rights reserved.

Developed by: iPlant Collaborative at BIO5 at The University of Arizona http://www.iplantcollaborative.org

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of the iPlant Collaborative, BIO5, The University of Arizona nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
