#!/usr/bin/perl -w
#-----------------------------------------------------------+
#                                                           |
# tr_export_species_tree.pl                                 |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 04/11/2012                                       |
# UPDATED: 04/12/2012                                       |
#                                                           |
# DESCRIPTION:                                              | 
#  Export a species tree that has been loaded to the TR     |
#  database. This generates a species tree with internal    |
#  node identifiers that are usable for input into          |
#  TREEBEST analyses to that reconciled gene trees can be   |
#  loaded into the database using the internal nodes ids    |
#  as used in the database.                                 |
#                                                           |
# LICENSE:                                                  |
#  Simplified BSD License                                   |
#                                                           |
#-----------------------------------------------------------+
#
#
# TEST USE:
# ./tr_export_species_tree.pl -o test_out.nwk -u jestill --host localhost --dbname tr_test --driver mysql -n bowers_rosids

# Set package in order to pass tree object to recursive subfunction. If
# this is changed will need to change object name in load_tree_nodes
# below.
package IPlantTR;

#-----------------------------+
# INCLUDES                    |
#-----------------------------+
use strict;
use DBI;
use Getopt::Long;
use Bio::TreeIO;                # BioPerl Tree I/O
use Bio::Tree::TreeI;
# The following needed for printing help
use Pod::Select;               # Print subsections of POD documentation
use Pod::Text;                 # Print POD doc as formatted text file
use IO::Scalar;                # For print_help subfunction
use IO::Pipe;                  # Pipe for STDIN, STDOUT for POD docs
use File::Spec;                # Convert a relative path to an abosolute path

#-----------------------------+
# VARIABLES                   |
#-----------------------------+
my ($VERSION) = 0.1;

my $outfile;                   # Path to the output species tree
my $format = "newick";         # Assumes newick is preferred output

# DATABASE VARS
my $db;                       # Database name (ie. iplant_tr)
my $host;                     # Database host (ie. localhost)
my $driver;                   # Database driver (ie. mysql)
my $statement;                # Database statement
my $sth;                      # Database statement handle

# OPTIONS SET IN USER ENVIRONMENT
my $usrname = $ENV{TR_USERNAME};  # User name to connect to database
my $pass = $ENV{TR_PASSWORD};     # Password to connect to database
my $dsn = $ENV{TR_DSN};           # DSN for database connection


# BOOLEANS
my $quiet = 0;
my $verbose = 0;
my $show_help = 0;
my $show_usage = 0;
my $show_man = 0;
my $show_version = 0;
my $do_test = 0;                  # Run the program in test mode

# Optional data for the tree
my $tree_name;                    # Name for species_tree_attributes table
my $tree_version;                 # Tree version number to assign

#-----------------------------+
# COMMAND LINE OPTIONS        |
#-----------------------------+
my $ok = GetOptions(# REQUIRED OPTIONS
		    "o|outfile=s"     => \$outfile,
		    "n|t|tree-name=s"   => \$tree_name,
		    # DSN REQUIRED UNLESS PARTS USED
                    "d|dsn=s"         => \$dsn,
		    # ALTERNATIVE TO --dsn 
		    "driver=s"        => \$driver,
		    "dbname=s"        => \$db,
		    "host=s"          => \$host,
		    # THE FOLLOWING CAN BE DEFINED IN ENV
		    "u|dbuser=s"      => \$usrname,
                    "p|dbpass=s"      => \$pass,
		    # ADDITIONAL OPTIONS
		    "tree-version=i"  => \$tree_version,
		    "format=s"        => \$format,
		    "q|quiet"         => \$quiet,
		    "verbose"         => \$verbose,
		    # ADDITIONAL INFORMATION
		    "usage"           => \$show_usage,
		    "test"            => \$do_test,
		    "version"         => \$show_version,
		    "man"             => \$show_man,
		    "h|help"          => \$show_help,);


#-----------------------------+
# SHOW REQUESTED HELP         |
#-----------------------------+
if ( ($show_usage) ) {
#    print_help ("usage", File::Spec->rel2abs($0) );
    print_help ("usage", $0 );
}

if ( ($show_help) || (!$ok) ) {
#    print_help ("help",  File::Spec->rel2abs($0) );
    print_help ("help",  $0 );
}

if ($show_man) {
    # User perldoc to generate the man documentation.
    system ("perldoc $0");
    exit($ok ? 0 : 2);
}

if ($show_version) {
    print "\n$0:\n".
	"Version: $VERSION\n\n";
    exit;
}


#-----------------------------------------------------------+
# DATABASE CONNECTION                                       |
#-----------------------------------------------------------+

if ( ($db) && ($host) && ($driver) ) {
    # Set default values if none given at command line
    $db = "biosql" unless $db; 
    $host = "localhost" unless $host;
    $driver = "mysql" unless $driver;
    $dsn = "DBI:$driver:database=$db;host=$host";
} 
elsif ($dsn) {
    # We need to parse the database name, driver etc from the dsn string
    # in the form of DBI:$driver:database=$db;host=$host
    # Other dsn strings will not be parsed properly
    # Split commands are often faster then regular expressions
    # However, a regexp may offer a more stable parse then splits do
    my ($cruft, $prefix, $suffix, $predb, $prehost); 
    ($prefix, $driver, $suffix) = split(/:/,$dsn);
    ($predb, $prehost) = split(/;/, $suffix);
    ($cruft, $db) = split(/=/,$predb);
    ($cruft, $host) = split(/=/,$prehost);
    # Print for debug
    print STDERR "\tPRE:\t$prefix\n" if $verbose;
    print STDERR "\tDRIVER:\t$driver\n" if $verbose;
    print STDERR "\tSUF:\t$suffix\n" if $verbose;
    print STDERR "\tDB:\t$db\n" if $verbose;
    print STDERR "\tHOST:\t$host\n" if $verbose;
}
else {
    # The variables to create a dsn have not been passed
    print "ERROR: A valid dsn can not be created\n";
    exit;
}



#-----------------------------+
# GET DB PASSWORD             |
#-----------------------------+
unless ($pass) {
    print "\nEnter password for the user $usrname\n";
    system('stty', '-echo') == 0 or die "can't turn off echo: $?";
    $pass = <STDIN>;
    system('stty', 'echo') == 0 or die "can't turn on echo: $?";
    chomp $pass;
}


#-----------------------------+
# CONNECT TO THE DATABASE     |
#-----------------------------+
# Commented out while I work on fetching tree structure
my $dbh = &connect_to_db($dsn, $usrname, $pass);


#-----------------------------+
# GET TREE ID                 |
#-----------------------------+
# Will do this separately in case there are muliple
# trees with the same name, this will allow for warning that version
# should be include in the query. I will load all results to the
# trees vaiable so that other values can be returned if necessary.

my $sel_trees_sql = "SELECT species_tree_id".
    " FROM species_tree ".
    " WHERE species_tree_name ='".$tree_name."'";
my $sel_trees = prepare_sth($dbh,$sel_trees_sql);

execute_sth($sel_trees);
my @trees = ();
while (my $row = $sel_trees->fetchrow_arrayref) {
    push(@trees,$row->[0]);
}
my $num_trees = @trees;

# We are going to expect a single tree for the variables given
# as input
if ($num_trees > 1 ) {
    print STDERR "More than one species tree matches the query:\n";
    print STDERR "$sel_trees_sql\n";
    print STDERR "You may need to include tree version in query.\n";
    # Could print out all trees that match name criteria here ...
}
elsif ($num_trees == 1) {
    print STDERR "Matching tree id is: ".$trees[0]."\n";
}
else {
    print STDERR "ERROR: No tree matches name: ".$tree_name."\n";
    exit 1;
}

#-----------------------------+
# CREATE A NEW TREE OBJECT    |
#-----------------------------+
print "\tCreating a new tree object.\n";
# Using our tree here to make tree available to recursive subfunction
# below.
our $tree = new Bio::Tree::Tree() ||
    die "Can not create the BioPerl tree object.\n";

#-----------------------------+
# GET THE ROOT NODE ID FOR    |
# THE TREE AND ADD ROOT OBJECT|
# TO TREE OBJECT              |
#-----------------------------+
my $sel_root_sql = "SELECT root_node_id".
    " FROM species_tree".
    " WHERE species_tree_id='".$trees[0]."'";
my $sel_root = prepare_sth($dbh,$sel_root_sql);

execute_sth($sel_root);
my $root_node_id = $sel_root->fetchrow_arrayref;

if ($root_node_id) {
    my $root_node = new Bio::Tree::Node( '-id' => $root_node_id->[0]);
    $tree->set_root_node($root_node);
}


#-----------------------------+ 
# LOAD TREE NODES TO TREE     |
# OBJECT                      |
#-----------------------------+
my $sel_child_sql = "SELECT species_tree_node_id, label".
    " FROM species_tree_node".
    " WHERE parent_id = ?"; 
my $sel_child = prepare_sth($dbh, $sel_child_sql);

# Given the root node id, we can recurse to
# get all children usind the load_tree_nodes subfunction below. 
# Since the root node has a unique id as assigned by the database, 
# and this id is loaded as the id of the root node id above, this 
# value can be used to refer to the node itself without needing
# to include tree_id as part of the query.

load_tree_nodes ($sel_child,$root_node_id);


#-----------------------------+
# LOAD NODE ATTRIBUTES        | 
#-----------------------------+
# At this point, all of the nodes should be loaded to the tree object
# and we  can use nod IDs to add information to the tree
# This could make direct use of a specified ontology to do this.
my @all_nodes = $tree->get_nodes;


# Select node attribute values
#my $sel_attrs_sql = " SELECT t.name, eav.value "
#    ."FROM term t, edge_attribute_value eav "
#    ."WHERE t.term_id = eav.term_id "
#    ."AND eav.edge_id = ?";
#my $sel_attrs = &prepare_sth($dbh, $sel_attrs_sql);

my $sel_label_sql = " SELECT label".
    " FROM species_tree_node".
    " WHERE species_tree_node_id = ?";

print STDERR "Adding node annotations ..\n";

foreach my $ind_node (@all_nodes) {
    print STDERR "\tAnnotating node : ".$ind_node->id."\n"
	if $verbose;
    
    # Get label if one exits, this should be the
    # name that was used in the orginal file input
    # to tag the nodes (ie species name_
    my $sel_label = prepare_sth($dbh, $sel_label_sql);
    &execute_sth( $sel_label, $ind_node->id );
    
    # If node label exists, the database id with node label
    my $node_label = $sel_label->fetchrow_arrayref;
    if ($node_label) {
	$ind_node->id($node_label->[0]);
    }
    
    # TO DO:
    # Get all generic attributes. This will be the
    # attributes tagged by the ontology derived name.
    #&execute_sth($sel_attrs,$ind_node);
    #my %attrs = ();
    
}

  
#-------------------------------+
# WRITE TREE TO FILE OR STDOUT  |
#-------------------------------+
if ($outfile) {
    my $treeio = Bio::TreeIO->new( -format => $format,
				   -file => '>'.$outfile)
	|| die "Could not open output file:\n$outfile\n";
    $treeio->write_tree($tree);
}
else {
    my $treeout_here = Bio::TreeIO->new( -format => $format );
    $treeout_here->write_tree($tree); 
}

exit 0;


#-----------------------------------------------------------+
# SUBFUNCTIONS                                              |
#-----------------------------------------------------------+
sub load_tree_nodes {

    my $sel_chld_sth = shift;# SQL to select children
    my $subroot = shift;        # reference to the root

    my @children = ();

    &execute_sth($sel_chld_sth,$subroot->[0]);

    # Push results to the children array
    while (my $child = $sel_chld_sth->fetchrow_arrayref) {
        push(@children, [@$child]);
    }
    
    # For all of the children, add the descendent node to
    # the tree object and call the load_tree_nodes subfunction
    # recursively for the resulting children nodes
    for(my $i = 0; $i < @children; $i++) {

	# The following used for debug
	print STDERR "\t|".$subroot->[0]."--->".$children[$i][0]."|\n"
	    if $verbose;
	
	#
	my ($par_node) = $IPlantTR::tree->find_node( '-id' => $subroot->[0] );
	
	# Check here that @par_node contains only a single node object
	my $node_child = new Bio::Tree::Node( '-id' => $children[$i][0] );
	$par_node->add_Descendent($node_child);

	&load_tree_nodes($sel_chld_sth, $children[$i]);

    }

} # end of load_tree_nodes


sub print_help {
    my ($help_msg, $podfile) =  @_;
    # help_msg is the type of help msg to use (ie. help vs. usage)
    
    print "\n";
    
    #-----------------------------+
    # PIPE WITHIN PERL            |
    #-----------------------------+
    #my $podfile = $0;
    my $scalar = '';
    tie *STDOUT, 'IO::Scalar', \$scalar;
    
    if ($help_msg =~ "usage") {
	podselect({-sections => ["SYNOPSIS|MORE"]}, $0);
    }
    else {
	podselect({-sections => ["SYNOPSIS|ARGUMENTS|OPTIONS|MORE"]}, $0);
    }

    untie *STDOUT;
    # now $scalar contains the pod from $podfile you can see this below
    #print $scalar;

    my $pipe = IO::Pipe->new()
	or die "failed to create pipe: $!";
    
    my ($pid,$fd);

    if ( $pid = fork() ) { #parent
	open(TMPSTDIN, "<&STDIN")
	    or die "failed to dup stdin to tmp: $!";
	$pipe->reader();
	$fd = $pipe->fileno;
	open(STDIN, "<&=$fd")
	    or die "failed to dup \$fd to STDIN: $!";
	my $pod_txt = Pod::Text->new (sentence => 0, width => 78);
	$pod_txt->parse_from_filehandle;
	# END AT WORK HERE
	open(STDIN, "<&TMPSTDIN")
	    or die "failed to restore dup'ed stdin: $!";
    }
    else { #child
	$pipe->writer();
	$pipe->print($scalar);
	$pipe->close();	
	exit 0;
    }
    
    $pipe->close();
    close TMPSTDIN;

    print "\n";

    exit 0;
   
}

sub connect_to_db {
    my ($cstr) = @_;
    return connect_to_mysql(@_) if $cstr =~ /:mysql:/i;
    return connect_to_pg(@_) if $cstr =~ /:pg:/i;
    die "can't understand driver in connection string: $cstr\n";
}

sub connect_to_pg {

	my ($cstr, $user, $pass) = @_;
	
	my $dbh = DBI->connect($cstr, $user, $pass, 
                               {PrintError => 0, 
                                RaiseError => 1,
                                AutoCommit => 0});
	$dbh || &error("DBI connect failed : ",$dbh->errstr);

	return($dbh);
} # End of ConnectToPG subfunction

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


sub prepare_sth {
    my $dbh = shift;
#    my ($dbh) = @_;
    my $sth = $dbh->prepare(@_);
    die "failed to prepare statement '$_[0]': ".$dbh->errstr."\n" unless $sth;
    return $sth;
}


sub execute_sth {
    
    # I would like to return the statement string here to figure 
    # out where problems are.
    
    # Takes a statement handle
    my $sth = shift;

    my $rv = $sth->execute(@_);
    unless ($rv) {
	$dbh->disconnect();
	die "failed to execute statement: ".$sth->errstr."\n"
    }
    return $rv;
} # End of execute_sth subfunction



sub last_insert_id {

    #my ($dbh,$table_name,$driver) = @_;
    
    # The use of last_insert_id assumes that the no one
    # is interleaving nodes while you are working with the db
    my $dbh = shift;
    my $table_name = shift;
    my $driver = shift;

    # The following replace by sending driver info to the sufunction
    #my $driver = $dbh->get_info(SQL_DBMS_NAME);
    if (lc($driver) eq 'mysql') {
	return $dbh->{'mysql_insertid'};
    } 
    elsif ((lc($driver) eq 'pg') || ($driver eq 'PostgreSQL')) {
	my $sql = "SELECT currval('${table_name}_pk_seq')";
	my $stmt = $dbh->prepare_cached($sql);
	my $rv = $stmt->execute;
	die "failed to retrieve last ID generated\n" unless $rv;
	my $row = $stmt->fetchrow_arrayref;
	$stmt->finish;
	return $row->[0];
    } 
    else {
	die "don't know what to do with driver $driver\n";
    }
} # End of last_insert_id subfunction

__END__

# The following pulled directly from the DBI module
# this is an attempt to see if I can get the DSNs to parse 
# for some reason, this is returning the driver information in the
# place of scheme
sub parse_dsn {
    my ($dsn) = @_;
    $dsn =~ s/^(dbi):(\w*?)(?:\((.*?)\))?://i or return;
    my ($scheme, $driver, $attr, $attr_hash) = (lc($1), $2, $3);
    $driver ||= $ENV{DBI_DRIVER} || '';
    $attr_hash = { split /\s*=>?\s*|\s*,\s*/, $attr, -1 } if $attr;
    return ($scheme, $driver, $attr, $attr_hash, $dsn);
}


=head1 NAME

tr_expot_species_tree.pl - Export species tree given tree name

=head1 VERSION

This documentation refers to program version 0.1

=head1 SYNOPSIS

=head2 Usage

    tr_export_species_tree.pl -o species_tree.nwk -t tree_name

=head2 Required Arguments

    --outfile, -o       # Path to the species tree file produced
    --tree-naame, -t    # Name of the tree to fetch from the database

=head1 DESCRIPTION

Exports a species tree with internal nodes labeled with IDs as
used in the database. This allows for reconciliciation against
a species tree with labeled internal nodes that can be more
easily loaded into the database.

=head1 REQUIRED ARGUMENTS

=over 2

=item -o, --outfile

Path of the species tree file to be created.

=item -t, --tree-name

Name of the tree to fetch from the database. This is the name for 
the tree that is listed in the 'species_tree_name' column of the 
'species_tree' table.

=back

=head1 OPTIONS

=over 2

=item --format

Format of the species tree to be created. Valid options include 

=item --usage

Short overview of how to use program from command line.

=item --help

Show program usage with summary of options.

=item --version

Show program version.

=item --man

Show the full program manual. This uses the perldoc command to print the 
POD documentation for the program.

=item -q,--quiet

Run the program with minimal output.

=back

=head1 EXAMPLES

The following are examples of how to use this script

=head2 Typical Use

This is a typcial use case.

=head1 DIAGNOSTICS

=over 2

=item * Expecting input from STDIN

If you see this message, it may indicate that you did not properly specify
the input sequence with -i or --infile flag. 

=back

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Environment

The following options can be set in the user environment.

=over 2

=item TR_USER

User name to connect to the tree reconciliation database.

=item TR_PASSWORD

Password for the tree reconciliation database connection

=item TR_DSN

DSN for the tree reconciliation database connection.

=back

For example in the bash shell this would be done be editing your .bashrc file
to contain:

    export TR_USERNAME=yourname
    export TR_PASS=yourpassword
    export TR_DSN='DBI:mysql:database=iplant_tr;host-localhost'

=head1 DEPENDENCIES

The program is dependent on the following:

* BioPerl

Specifically the TreeIO module is required for this program to work. 

* DBI

Module required For connecting to the database.

* DBD::mysql 

The driver for connecting to a mysql database

=head1 BUGS AND LIMITATIONS

Any known bugs and limitations will be listed here.

=head1 REFERENCE

No current manuscript or web site reference for use of this script.

=head1 LICENSE

Copyright (c) 2012, The Arizona Board of Regents on behalf of 
The University of Arizona.

All rights reserved.

Developed by: iPlant Collaborative as a collaboration between
participants at BIO5 at The University of Arizona (the primary hosting
institution), Cold Spring Harbor Laboratory, The University of Texas at
Austin, and individual contributors. Find out more at 
http://www.iplantcollaborative.org/.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are
met:

 * Redistributions of source code must retain the above copyright 
   notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright 
   notice, this list of conditions and the following disclaimer in the 
   documentation and/or other materials provided with the distribution.
 * Neither the name of the iPlant Collaborative, BIO5, The University 
   of Arizona, Cold Spring Harbor Laboratory, The University of Texas at 
   Austin, nor the names of other contributors may be used to endorse or 
   promote products derived from this software without specific prior 
   written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=head1 AUTHOR

James C. Estill E<lt>JamesEstill at gmail.comE<gt>

=head1 HISTORY

STARTED: 04/11/2012

UPDATED: 04/12/2012

VERSION: 0.1

=cut


