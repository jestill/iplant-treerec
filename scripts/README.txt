+-----------------------------------------------------------+
 PROCESS TO UPLOAD RECONCILED TREES TO TR DATABASE
 04/12/2012
 James Estill (JamesEstill @ gmail.com)
+-----------------------------------------------------------+

Given a database that has been loaded with the necessary 
ontologies, the following process is used to reconcile 
gene trees to species tree and load the resulting reconciled
trees to the database.

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

