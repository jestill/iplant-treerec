+-----------------------------------------------------------+
 PROCESS TO UPLOAD RECONCILED TREES TO TR DATABASE
 04/12/2012
 James Estill (JamesEstill @ gmail.com)
+-----------------------------------------------------------+

Documentation also available at
https://pods.iplantcollaborative.org/wiki/display/iptol/Populating+the+Database

Given a database that has been loaded with the necessary 
ontologies, the following process is used to reconcile 
gene trees to species tree and load the resulting reconciled
trees to the database.

+-----------------------------------------------------------+
 CREATE A BLANK DATABASE
+-----------------------------------------------------------+

Log on to mysql as user with create privelges, and then
create a blank databse:

  mysql> create database tr_deep_green;

+-----------------------------------------------------------+
 LOAD TR TABLES TO DATABASE
+-----------------------------------------------------------+

The SQL code to create the database exists at ../schema/
relative to this directory. From this dir create the tables
in the database using mysql command line program For example
for the database named tr_deep_green created above:
 
 mysql tr_deep_green < tr_schema_mysql.sql -p -u USERNAME

This should created all of the tables, indices and dependencies needed.

This can be checked in mysql as:

  mysql> use tr_deep_green;
  Reading table information for completion of table and column names
  You can turn off this feature to get a quicker startup with -A
  
  Database changed
  mysql> show tables;
  +-------------------------------+
  | Tables_in_tr_deep_green       |
  +-------------------------------+
  | cv                            |
  | cvterm                        |
  | cvterm_dbxref                 |
  | cvterm_relationship           |
  | cvtermpath                    |
  | cvtermprop                    |
  | cvtermsynonym                 |
  | db                            |
  | dbxref                        |
  | dbxrefprop                    |
  | family                        |
  | family_attribute              |
  | family_member                 |
  | member                        |
  | member_attribute              |
  | protein_tree                  |
  | protein_tree_attribute        |
  | protein_tree_hmmprofile       |
  | protein_tree_member           |
  | protein_tree_member_score     |
  | protein_tree_node             |
  | protein_tree_node_attribute   |
  | protein_tree_node_path        |
  | protein_tree_stable_id        |
  | reconciliation                |
  | reconciliation_attribute      |
  | reconciliation_node           |
  | reconciliation_node_attribute |
  | reconciliation_set            |
  | reconciliation_set_attribute  |
  | sequence                      |
  | source                        |
  | source_attribute              |
  | species_tree                  |
  | species_tree_attribute        |
  | species_tree_node             |
  | species_tree_node_attribute   |
  | species_tree_node_path        |
  +-------------------------------+
  38 rows in set (0.00 sec)

+-----------------------------------------------------------+
 POPULATE CONTROLLED VOCABULARY TABLES
+-----------------------------------------------------------+

Ontologies are in ontology dir relative to this README file at
../ontology/


The relationship ontology must first be loaded into the database to allow 
for other ontologies to use these terms.

The available tools for loading ontologies into the database requires 
the conversion of the obo file to chadoxml format with the go2chadoxml 
program from GMOD (http://gmod.org/wiki/XORT#go2chadoxml). This program takes 
a valid OBO format file as input, and converts it to a chado.xml file. For 
example to convert the phylogeny ontology to chado xml:

go2chadoxml phylo_ontology.obo > phylo_ontology.chado.xml

The resulting chadoxml file can then be loaded into the database using 
stag-storenode.pl available from CPAN.

Some relevant ontologies have been converted from OBO to xml and are
located in the ontology directory.

The resulting chadoxml files can then be loaded into the database 
using stag-storenode.pl available from CPAN.

This program accepts the following options:

 -d 
 DSN for connecting to the database. This should be in the format of 
 'dbi:mysql:dbname=[DATABASENAME];host=[HOSTREF]'
--user 
  user name for connecting to the database
--password 
  password for the database connection

For example, to load the file for the phylogeny ontology (phylo_ontology.xml):

 stag-storenode.pl -d 'dbi:mysql:dbname=tr_test;host=localhost' 
    --user [USERNAME] --password [PASSWORD] phylo_ontology.xml

For more information on loading custom ontologies into this framework, see 
the documentation for how to load a custom ontology into Chado at
http://gmod.org/wiki/Load_a_custom_ontology_in_Chado.

Loading Term Relationships into the Database
An overview of the use of transitive closure and deductive closure for 
GO terms is available from the gene ontology wiki
http://wiki.geneontology.org/index.php/Transitive_closur. 
In the TR database, the relationships among terms in the cvterm table is 
stored in the cvtermpath table. It is possible to use the code from GMOD 
to directly generative transitive closure links from the data in the database. 
This program requires Perl 5.10.0 which can be a limit on its use.

The current TR database does not use GMOD tools for computing relationship 
among terms in the database, but makes use of a precomputed transitive 
closure table for GO available at 
http://www.geneontology.org/scratch/transitive_closure/go_transitive_closure.links. 
This precomputed file is a result of running obo2linkfile on core GO terms. 
This program is included with the download of the OBO-Edit program.  It is 
possible to parse out the is_a links from this file, and then load only the 
is_a relationships to the database. The program 
tr_import_go_transitive_closure.pl (available from svn) can then be used to 
import the text file into the cvtermpath table.

The use of these these cvtermpath table to query the database for GO terms 
that includes all child terms of a parent query term is described elsewhere.

+-----------------------------------------------------------+
  1. IMPORT SPECIES TREE
+-----------------------------------------------------------+

Given the species tree that will be used as the base tree
for reconciliation of gene trees, do the following to import
the species tree into the TR database. 

The program to import species trees into the database is:

  tr_import_species_tree.pl

In addition to the database connection variables, this program 
requires the following as input:

  1) --infile, -i
    The species tree that will be used for reconciliation.
    Leaf node lables should be unique, and internal node lables
    are allowed but should also be unique.
  2) --tree-name, -t
    The name to be assigned to the tree in the database.
    This will be used to fill in the 'species_tree_name'
    column of the 'species_tree' table.

For example, for a tree named 'deep_green.tree' in newick format:

  ./tr_import_species_tree.pl -u USERNAME --host DBHOST 
  --dbname DBNAME --driver mysql --verbose 
  -i deep_green.tree -t deep_green

When successfully loaded you should see the tree name in the
database along with the root_node_id. This can be checked as:

  mysql> select * from species_tree;
  +-----------------+-----------------------+--------------+---------+
  | species_tree_id | species_tree_name     | root_node_id | version |
  +-----------------+-----------------------+--------------+---------+
  |               1 | bowers_rosids         |            1 |    NULL |
  |               3 | deep_green            |         2781 |    NULL |
  |               6 | deep_green_hex_spaced |         3276 |    NULL |
  +-----------------+-----------------------+--------------+---------+

Tree name should be unique, however it is possible to have multiple
species trees in the database with the same name, and use the version
field to distinguish among the different versions of the tree. The gene
trees reconciled to species trees use the 'species_tree_id' column to
identify the species tree that is being reconciled against.

+-----------------------------------------------------------+
  2. EXPORT SPECIES TREE WITH INTERNAL NODE IDENTIERS
+-----------------------------------------------------------+

Some reconciliation programs take a species tree as input
that has all of the internal nodes of the species tree labeled.
In situations where the internal nodes of the species tree do not have
labels, the species tree can be exported back out from the database.
This will return a species tree with internal nodes that are identified
by the node identiers as used in the databse. The program to
export species tree from a TR database is:

  tr_export_species_tree.pl

In addition to the database connection variables, this program
requires the following as input:

  1) --tree-name, -t
   The name of the tree to be 
  2) --outfile, -o
   The path to the output file that will be created.

By default the output tree will be in newick format. Additional
formats can be specified with the --format optoin.

For example, to export the tree loaded to the database above, use
the following:
    
  tr_export_species_tree.pl -o deep_green_labeled.nwk -u USERNAME 
       --host DBHOST --dbname DBNAME --driver mysql 
       -n deep_green

+-----------------------------------------------------------+
  3. RECONCILE GENE TREES TO SPECIES TREES
+-----------------------------------------------------------+

+-----------------------------------------------------------+
  4. IMPORT RECONCILIATION SET DATA
+-----------------------------------------------------------+

A reconciliation set is a set of gene trees reconciled to a
species tree using the same set of parameters. They may share
the program used to generate the reconciliation as well as 
the options selected when using the specific program for 
doing the reconciliation.

The program to import reconciled tree data is 

  tr_import_reconciliation_set.pl

This program requires as its input:
  1) --infile
     a tab delimited text file describing reconciliation
     attributes making use of the a tree reconciliation
     ontology. By default this is TRON.
  2) --name
     a unique name assigned to the reconciliation set
  3) --dsn
     DSN information for connecting to the TR database.
Additional options include:
  1) --description
     Description of the 
  2) --ontology
     Ontology namespace used. Default is TRON.

Example use:
  ./tr_import_reconciliation_set.pl -i sandbox/test_reconciliation_set.txt \
            -n test -u jestill --host localhost --dbname tr_test \
            --driver mysql --name test_set --description "Test set for debug"

For full set of options use the following to view program manual:
   /tr_import_reconciliation_set.pl --man

+-----------------------------------------------------------+
 5. Import reconciled gene trees
+-----------------------------------------------------------+
