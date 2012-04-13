#!/usr/bin/perl -w
#-----------------------------------------------------------+
#                                                           |
# tr_import_reconciled_set.pl                               |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 03/12/2012                                       |
# UPDATED: 04/12/2012                                       |
#                                                           |
# DESCRIPTION:                                              | 
#  Import reconciliation set data and loads to the          |
#  TR database. Initially this will use a tab delimited     |
#  text file to load reconcilation set name and associated  |
#  metadata to the database. Input can be a single tab      |
#  delimited text file or a dir of appropriately formatted  |
#  files. Later will extend to import of NEXML formatted    |
#  trees that include this metadata.                        |
#                                                           |
# LICENSE:                                                  |
#  Simplified BSD License                                   |
#  http://tinyurl.com/iplant-tr-license                     |
#                                                           |
#-----------------------------------------------------------+
#
# TEST USE:
# ./tr_import_reconciliation_set.pl -i sandbox/test_reconciliation_set.txt -n test -u jestill --host localhost --dbname tr_test --driver mysql --name test_set --description "Test set for debug"
#
# The input option has been written to accept dirs of files
# but the metadata (name, etc.) would need to be parsed from
# comment tagged header information within each file.
# TO DO:
# Check that name does not already exist in the database and throw
# error if that is the case. This will prevent using overlapping
# names in the reconciled tree database.

#-----------------------------+
# INCLUDES                    |
#-----------------------------+
use strict;
use DBI;
use Getopt::Long;
use File::Basename;           # Use this to extract base name from file path
# The following needed for printing help
use Pod::Select;               # Print subsections of POD documentation
use Pod::Text;                 # Print POD doc as formatted text file
use IO::Scalar;                # For print_help subfunction
use IO::Pipe;                  # Pipe for STDIN, STDOUT for POD docs
use File::Spec;                # Convert a relative path to an abosolute path

#-----------------------------+
# VARIABLES                   |
#-----------------------------+
my ($VERSION) = q$Rev: 603 $ =~ /(\d+)/;

my $infile;
my $in_path;                  # Modifed infile to inpath

# COMMAND LINE VARIABLES
# Variables set at the command line and available
my $format = "txt";           # Expect format as tab delimited text file
my $ontology = "TRON";        # Ontology used to tag values that are used
                              # in a tab delimited text file to tag attributes.
my $name;                     # Required: Name for reconciliation set
my $description;              # Optional: shot 255 character description 
                              # of reconciliation set.

my $species_tree_name;        # Path for the species tree
my $cluster_set_name;         # Name of the cluseter set
                              # if integer this is the inteer of __
                              # as used in the database
                              # otherwise must look up from database.
my $species_tree_id;          # The integer id of the species tree in database
my $species_root_node_id;     # Root node of the species tree
my $species_tree_version;     # The integer version of the species tree

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

#-----------------------------+
# COMMAND LINE OPTIONS        |
#-----------------------------+
my $ok = GetOptions(# REQUIRED
		    "i|infile|indir=s"  => \$in_path,
		    "n|name=s"          => \$name,
		    # OPTIONS
		    "description=s"     => \$description,
		    "ontology=s"        => \$ontology,
		    # DSN REQUIRED UNLESS PARTS USED
                    "d|dsn=s"           => \$dsn,
		    # ALTERNATIVE TO --dsn 
		    "driver=s"          => \$driver,
		    "dbname=s"          => \$db,
		    "host=s"            => \$host,
		    # THE FOLLOWING CAN BE DEFINED IN ENV
		    "u|dbuser=s"        => \$usrname,
                    "p|dbpass=s"        => \$pass,
		    # ADDITIONAL OPTIONS
		    "format=s"    => \$format,
		    "q|quiet"     => \$quiet,
		    "verbose"     => \$verbose,
		    # ADDITIONAL INFORMATION
		    "usage"       => \$show_usage,
		    "test"        => \$do_test,
		    "version"     => \$show_version,
		    "man"         => \$show_man,
		    "h|help"      => \$show_help,);

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
    $db = "iplant_tr" unless $db; 
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
    print STDERR "ERROR: A valid dsn can not be created\n";
#    print STDERR "No database specified" if (!$db);
#    print STDERR "No host specified" if (!$host);
#    print STDERR "No driver specified" if (!$driver);
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

#-----------------------------------------------------------+
# LOAD THE ARRAY OF FILE PATHS                              |
#-----------------------------------------------------------+
my @input_files;
if ($in_path) {
    if (-f $in_path) {
	print STDERR "Input path is a file\n"
	    if $verbose;
	push (@input_files, $in_path);
    }
    elsif (-d $in_path) {
	
	# NOTE: If other input formats are added, change the following to always
	# default to fasta format. Current here to allow for
	# input from other types of data.
	print STDERR "Input path is a directory\n" 
	    if $verbose;
	
	# GET THE DIRECTORY VAR
	my $in_dir = $in_path;
	# Add slash to indir if needed
	unless ($in_dir =~ /\/$/ ) {
	    $in_dir = $in_dir."/";
	}
	
	# LOAD FILES IN THE INTPUT DIRECTORY
	# First load to tmp array so that indir can be prefixed to inpath
	my @tmp_file_paths;
	# txt format is a tab delimited text file
	if ($format =~ "txt") {
	    opendir( DIR, $in_dir ) || 
		die "Can't open directory:\n$in_dir"; 
	    @tmp_file_paths = grep /\.text$|\.txt$/, readdir DIR ;
	    closedir( DIR );
	}
	elsif ($format =~ "xml") {
	    opendir( DIR, $in_dir ) || 
		die "Can't open directory:\n$in_dir"; 
	    @tmp_file_paths = grep /\.xml$|\.XML$/, readdir DIR ;
	    closedir( DIR );
	}
	
	# DIR directory to path of 
	foreach my $tmp_file_path (@tmp_file_paths ) {
	    push (@input_files, $in_dir.$tmp_file_path);
	}
	
	# If no files found matching expected extensions, may want to
	# just push all files in the directory
	
	
    } else {
	print STDERR "Input path is not a valid directory or file:\n";
	die;
    }
    
} else {
    print STDERR "\a";
    print STDERR "WARNING: A input directory or file has not been specified\n";
}

#-----------------------------------------------------------+
# PROCESS EACH FILE OF RECONCILIATION METADATA              |
#-----------------------------------------------------------+
foreach my $infile (@input_files) {

    print STDERR "\n============================================\n"
	if $verbose;
    print STDERR "Processing:\n$infile\n"
	if $verbose;
    print STDERR "============================================\n"
	if $verbose;

    open (RECIN, $infile) ||
	die "Can not open input file $infile \n";

    # The term values including id from datbase
    my @term_values;
    my @term_errors;
    # Term values as cvterm, cvterm_id, 
    print STDERR "\nFetching cvterm IDs from database ...\n";
    my $line_num = 0;
    while (<RECIN>) {

	chomp;
	$line_num++;
	# Comment lines starting with #
	next if (m/^\#/);
	
	#print STDERR "IN: ".$_."\n";
	my ($term,$value) = split (/\t/, $_);

	# Only process lines where it looks like there
	# is a term value pair
	if ($term && $value) {
	    # Get term_id

	    my $term_id = get_cvterm_id($term, $ontology, $dbh);

	    if ($term_id) {
		print STDERR "Term in database:\n" if $verbose;
		print STDERR "\tcvterm: ".$term."\n" if $verbose;
		print STDERR "\tvalue: ".$value."\n" if $verbose;
		print STDERR "\tcvterm_id:".$term_id."\n" if $verbose;
		my $term_set = {};
		$term_set->{cvterm_name} = $term;
		$term_set->{value} = $value;
		$term_set->{cvterm_id} = $term_id;
		push @term_values, $term_set;
	    }
	    else {
		# Push to the error set
		print STDERR "Term missing:\n" if $verbose;
		print STDERR "\tterm: ".$term."\n" if $verbose;
		print STDERR "\tvalue: ".$value."\n" if $verbose;
		my $err_set = {};
		$err_set->{cvterm_line} = $line_num;
		$err_set->{cvterm_name} = $term;
		$err_set->{value} = $value;
		push @term_errors, $err_set;
	    }

	}

    } # End of parsing file
    close RECIN; 


    #-----------------------------+
    # If some terms are not in    |
    # the database, abandon the   |
    # upload and report error.    |
    #-----------------------------+
    my $num_errors = @term_errors;
    if ($num_errors > 0) {
	print "\a";
	print STDERR "\n\nERROR: The following $num_errors cvterms could".
	    " not be found in the ".$ontology." ontology:\n";
	for my $err_term (@term_errors) {
	    print STDERR "\t".$err_term->{cvterm_name}.
		"\t(LINE NUM: ".$err_term->{cvterm_line}.")\n"
	}
	exit 1; # exit with error
    }

    #-----------------------------+
    # Create reconciliation set   |
    #-----------------------------+
    print STDERR "\nCreating reconciliation set ...\n";
    my $rs_fields = "name";
    my $rs_values = "\'".$name."\'";
    if ($description) {
	$rs_fields = $rs_fields.", description";
	$rs_values = $rs_values.", \'".$description."\'";
    }
    my $sql_create_rs = "INSERT INTO reconciliation_set".
	" ( ".$rs_fields." ) ".
	" VALUES (".$rs_values.")";
    print STDERR "\tRS SQL: ".$sql_create_rs."\n"
	if $verbose;
    # May want to also check to see if the name will
    # make for redundant values in the database
    my $rs_sth = $dbh->prepare($sql_create_rs);
    $rs_sth->execute();
    $rs_sth->finish();

    # Get reconciliatin set id
    my $rs_id = last_insert_id( $dbh, "reconciliation_set", "mysql");
    print STDERR "\tInsert as reconciliation_set_id=".$rs_id."\n"
	if $verbose;

    #-----------------------------+
    # load attribute values       |
    # to the table                |
    # reconciliation_set_attribute|
    #-----------------------------+
    print STDERR "\nAttribute values loading ...\n";
    for my $term (@term_values) {
	print STDERR "\t".$term->{cvterm_name}."\t".
	    $term->{cvterm_id}."\t".
	    $term->{value}."\t".
	    "\n";

	my $atr_sql = "INSERT INTO reconciliation_set_attribute ".
	    "(".
	    " reconciliation_set_id,".
	    " cvterm_id,".
	    " value".
	    ")".
	    " VALUES ".
	    "(".
	    " ".$rs_id.",".
	    " ".$term->{cvterm_id}.",".
	    " \'".$term->{value}."\'".
	    ")";

	print STDERR "\t\tATR_SQL:".$atr_sql."\n"
	    if $verbose;
	my $atr_sth = $dbh->prepare($atr_sql);
	$atr_sth->execute();
	$atr_sth->finish();

    }

} # End of for each file in the input path


exit 0;

#-----------------------------------------------------------+
# SUBFUNCTIONS
#-----------------------------------------------------------+


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

    
    # The use of last_insert_id assumes that the no one
    # else is loading data while you ae
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

# ////////////////////////////////
# AT WORK
# ////////////////////////////////

sub get_cvterm_id {
    
    # Take term and ontology name as input
    # return cvterm id as stored in database.

    my ($in_tag, $ontology, $dbh) = @_;

    my $sql;
    $sql = "SELECT cvterm.cvterm_id".
	" FROM cvterm".
	" LEFT JOIN dbxref".
	" ON cvterm.dbxref_id=dbxref.dbxref_id".
	" LEFT JOIN db".
	" ON db.db_id=dbxref.db_id".
	" WHERE db.name = '".$ontology."'".
	" AND cvterm.name = '".$in_tag."'";

    my $cur = $dbh->prepare($sql);
    $cur->execute();
    my @row=$cur->fetchrow;
    my $result = $row[0];
    $cur->finish();

    return $result;

}


__END__

=head1 NAME

tr_import_reconciliation_set.pl - Load reconciliation set data to dbase.

=head1 VERSION

This documentation refers to tr_import_reconciliation_set.pl 

=head1 SYNOPSIS

=head2 Usage

    tr_import_reconciliation_set.pl -i infile.txt -n "Set Name"

=head2 Required Arguments

    --infile, -i     # Path to the reconciliation set description file.
    --name, -n       # Name of the reconciliation set.

=head1 DESCRIPTION

Imports metadata for tree reconciliation into the database using a 
simple tab delimited text file as input that descripts reconciliation
methods using the Tree Reconciliation Onotlogy (TRON).

=head1 REQUIRED ARGUMENTS

=over 2

=item -i, --infile

Path of the file description the tree reconciliation methodology used.

=item -n, --name

Name of the reconciliation set. This should be a unique name within
the scope of the tree reconciliation database.

=item --driver

The database driver to use. This will be mysql by default.

=item --dbname

The name of the database that is being populated

=item --host

The host for the database connection.

=item -u, --dbuser

The user name for connecting to the database. This can also be set with the
TR_USERNAME variable in the user environment.

=item -p, --dbpass

This can also be set witg the TR_PASSWORD variable in the user environment. 
If not specified at the command line or in the environment, this will be
prompted for.

=back

=head1 OPTIONS

=over 2

=item --description

Short (<255 character) description of the tree reconciliation set. For
example "TREEBEST with default parameters".

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

=head2 Import Single Tree

The following example shows importing reconciliation set data.

  ./tr_import_reconciliation_set.pl -i sandbox/test_reconciliation_set.txt \
            -n test -u jestill --host localhost --dbname tr_test \
            --driver mysql --name test_set --description "Test set for debug"

=head1 DIAGNOSTICS

=over 2

=item * Expecting input from STDIN

If you see this message, it may indicate that you did not properly specify
the input sequence with -i or --infile flag. NOTE: This program does not
currently supporte input from STDIN.

=back

=head1 CONFIGURATION AND ENVIRONMENT

Many of the options passed at the command line can be set as 
options in the user's environment. 

=over 2

=item TR_USERNAME

User name to connect to the database.

=item TR_PASSWORD

Password for the database connection

=item TR_DBNAME

Database name.

=item TR_HOST

Host for the database connection.

=item TR_DSN

Full database DSN for connecting to a tree reconciliatin database.

=back

For example in the bash shell this would be done be editing your .bashrc file
to contain :

    export TR_USERNAME=yourname
    export TR_PASSWORD=yourpassword
    export TR_DBNAME=your_database_name
    export TR_DBHOST=localhost

Alternatively, the database name and host can be specified in a
DSN similar to the following format.

    export DBI_DSN='DBI:mysql:database=biosql;host-localhost'

=head1 DEPENDENCIES

=head2 Perl Modules

* BioPerl

This program depends on the BioPerl TreeIO module.

=head1 BUGS AND LIMITATIONS

=head2 Bugs

Please report bugs to:
http://pods.iplantcollaborative.org/jira

=head2 Limitations

Currently the tree_reconciliation database is limited to the MySQL RDBMS.

The reconcild trees used by this program must be in the PRIME format.
PRIME format trees from the Treebest program can be imported by using
the reconcile program included in the PRIME application download.

=head1 SEE ALSO

The tr_import_reconciled_tree.pl is a component of the iPlant Tree
Reconciliaton suite of utilities. Additoinal information is available
at:
L<https://pods.iplantcollaborative.org/wiki/display/iptol/1.0+Architecture>

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

STARTED: 09/15/2010

UPDATED: 04/12/2012

VERSION: 0.1

=cut

