-- -----------------------------------------------------------
-- TREE RECONCILIATION SCHEMA
-- -----------------------------------------------------------
--
--  AUTHOR: James C. Estill ( JamesEstill@gmail.com )
-- STARTED: 09/21/2010
-- UPDATED: 03/27/2012
--
-- ABOUT:
-- This is a working version of the tree reconciliation 
-- schema.

-- -----------------------------------------------------------
-- SEQUENCE
-- -----------------------------------------------------------
-- Taken from the existing Ensemble-Compara table.
-- The following sequence table is only for AA sequences only
-- The DNA sequences are in sequence_cds.
CREATE TABLE sequence (
       sequence_id INT(10) AUTO_INCREMENT NOT NULL,
       length INT(10),
       sequence LONGTEXT,
       PRIMARY KEY (sequence_id)
);

-- -----------------------------------------------------------+
-- FAMILY MEMBER TABLE
-- -----------------------------------------------------------+
-- should add family_member_id as primary_key but ec does
-- not have this
CREATE TABLE family_member (
       family_id INT(10),
       member_id INT(10),
       cigar_line MEDIUMTEXT,
       PRIMARY KEY (family_id)
);

-- replace the following integers with unsigned integers
CREATE TABLE family (
       family_id INT(10) AUTO_INCREMENT,
       stable_id VARCHAR(40),
       version INT(10),
       method_link_species_set_id INT(10),
       description VARCHAR(255),
       description_score double,
       PRIMARY KEY (family_id)
);


-- -----------------------------+
-- family_attribute            |
-- -----------------------------+
CREATE TABLE family_attribute (
                family_attribute_id INT(10) AUTO_INCREMENT NOT NULL,
                family_id INT(10) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                value TEXT,
                rank SMALLINT(3) DEFAULT 0,
                source_id INT(10),
                PRIMARY KEY (family_attribute_id)
);
ALTER TABLE family_attribute ADD INDEX (family_id);
ALTER TABLE family_attribute ADD INDEX (cvterm_id);


-- -----------------------------------------------------------+

-- -----------------------------------------------------------+
-- MEMBER TABLE
-- -----------------------------------------------------------+
-- These are individual members in the database that 
-- participate in gene_trees. These can be assemblies
-- of expressed sequence data or they can be 
-- annotations of gene models on genomic DNA

CREATE TABLE member (
                member_id INT(8) AUTO_INCREMENT NOT NULL,
                stable_id VARCHAR(64) NOT NULL,
                version INT(8) DEFAULT 0,
                source_name CHAR(17) NOT NULL,
                taxon_id INT(8) NOT NULL,
                genome_db_id INT(8),
                sequence_id INT(8),
                gene_member_id INT(8),
                description TEXT,
                chr_name CHAR(40),
                chr_start INT(8),
                chr_end INT(8),
                chr_strand TINYINT(1) NOT NULL,
                display_label VARCHAR(64),
                PRIMARY KEY (member_id)
);

ALTER TABLE member COMMENT 'This is the primary information on each locus or protein in the datbase.';


CREATE UNIQUE INDEX source_stable_id USING BTREE
 ON member
 ( stable_id ASC, source_name ASC );

CREATE UNIQUE INDEX member_location USING BTREE
 ON member
 ( member_id ASC, chr_name ASC, chr_start ASC );

CREATE INDEX taxon_id USING BTREE
 ON member
 ( taxon_id ASC );

CREATE INDEX genome_db_id USING BTREE
 ON member
 ( genome_db_id ASC );

CREATE INDEX stable_id USING BTREE
 ON member
 ( stable_id ASC );

CREATE INDEX source_name USING BTREE
 ON member
 ( source_name ASC );

CREATE INDEX sequence_id USING BTREE
 ON member
 ( sequence_id ASC );

CREATE INDEX gene_member_id USING BTREE
 ON member
 ( gene_member_id ASC );



-- -----------------------------------------------------------+
--
-- CONTROLLED VOCABULARY TABLES
--
-- -----------------------------------------------------------+
-- These were manaully curated from Postgres code from Chado

-- -----------------------------------------------------------+
-- db
-- -----------------------------------------------------------+
-- Database table

CREATE TABLE db (
    db_id INT(10) AUTO_INCREMENT NOT NULL ,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) NULL,
    urlprefix VARCHAR(255) NULL,
    url VARCHAR(255) NULL,
    CONSTRAINT db_c1 UNIQUE (name),
    PRIMARY KEY (db_id)
);


ALTER TABLE db COMMENT = 'A database authority. Typical databases in
bioinformatics are FlyBase, GO, UniProt, NCBI, MGI, etc. The authority
is generally known by this shortened form, which is unique within the
bioinformatics and biomedical realm.  To Do - add support for URIs,
URNs (e.g. LSIDs). We can do this by treating the URL as a URI -
however, some applications may expect this to be resolvable - to be
decided.';

-- -----------------------------------------------------------+
-- dbxref
-- -----------------------------------------------------------+
create table dbxref (
    dbxref_id INT(10) AUTO_INCREMENT NOT NULL,
    db_id INT(10) not null,
    accession VARCHAR(255) not null,
    version VARCHAR(255) not null default '',
    description TEXT,
    CONSTRAINT dbxref_c1 UNIQUE (db_id,accession,version),
    PRIMARY KEY (dbxref_id)
);

ALTER TABLE dbxref ADD CONSTRAINT dbxref_fk1
FOREIGN KEY (db_id)
REFERENCES db (db_id)
ON DELETE CASCADE;

ALTER TABLE dbxref 
ADD INDEX dbxref_idx1 (db_id);

ALTER TABLE dbxref 
ADD INDEX dbxref_idx2 (accession);

ALTER TABLE dbxref 
ADD INDEX dbxref_idx3 (version);

ALTER TABLE dbxref COMMENT = 'A unique, global, public, stable identifier. 
Not necessarily an external reference - can reference data items inside the 
particular chado instance being used. Typically a row in a table can be 
uniquely identified with a primary identifier (called dbxref_id); a table 
may also have secondary identifiers (in a linking table <T>_dbxref). A dbxref 
is generally written as <DB>:<ACCESSION> or as <DB>:<ACCESSION>:<VERSION>.';

-- -----------------------------------------------------------+
-- cv
-- -----------------------------------------------------------+
-- Controlled vocabulary table

CREATE TABLE cv (
                cv_id INT(10) AUTO_INCREMENT NOT NULL,
                name VARCHAR(255) NOT NULL,
                definition TEXT NOT NULL,
                PRIMARY KEY (cv_id),
                CONSTRAINT cv_c1 UNIQUE (name)
);

-- -----------------------------------------------------------+
-- cvterm
-- -----------------------------------------------------------+
-- Changed the name field from following from 1024 to allow for 
-- constraint to work in mysql
--                name VARCHAR(1024) NOT NULL,

CREATE TABLE cvterm (
                cvterm_id INT(10) AUTO_INCREMENT NOT NULL,
                cv_id INT(10) NOT NULL,
                name VARCHAR(950) NOT NULL,
                definition TEXT,
                dbxref_id INT(10) NOT NULL,
                is_obsolete BOOLEAN NOT NULL DEFAULT 0,
                is_relationshiptype BOOLEAN NOT NULL DEFAULT 0,
                PRIMARY KEY (cvterm_id),
                CONSTRAINT cvterm_c1 UNIQUE (name,cv_id,is_obsolete),
                CONSTRAINT cvterm_c2 UNIQUE (dbxref_id)
);


ALTER TABLE cvterm 
ADD INDEX cvterm_idx1 (cv_id);

ALTER TABLE cvterm 
ADD INDEX cvterm_idx2 (name);

ALTER TABLE cvterm 
ADD INDEX cvterm_idx3 (dbxref_id);

-- -----------------------------------------------------------+
-- cvterm_relationship
-- -----------------------------------------------------------+

CREATE TABLE cvterm_relationship (
                cvterm_relationship_id INT(10) AUTO_INCREMENT NOT NULL,
                type_id INT(10) NOT NULL,
                subject_id INT(10) NOT NULL,
                object_id INT(10) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                PRIMARY KEY (cvterm_relationship_id),
                CONSTRAINT cvterm_relationship_c1 UNIQUE (subject_id,object_id,type_id)
);


ALTER TABLE cvterm_relationship 
ADD INDEX cvterm_relationship_idx1 (type_id);

ALTER TABLE cvterm_relationship 
ADD INDEX cvterm_relationship_idx2 (subject_id);

ALTER TABLE cvterm_relationship 
ADD INDEX cvterm_relationship_idx3 (object_id);

ALTER TABLE cvterm_relationship 
ADD CONSTRAINT cvterm_relationship_fk1
FOREIGN KEY (type_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

ALTER TABLE cvterm_relationship 
ADD CONSTRAINT cvterm_relationship_fk2
FOREIGN KEY (subject_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

ALTER TABLE cvterm_relationship 
ADD CONSTRAINT cvterm_relationship_fk3
FOREIGN KEY (object_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

-- -----------------------------------------------------------+
-- cvtermpath
-- -----------------------------------------------------------+

CREATE TABLE cvtermpath (
                cvtermpath_id INT(10) AUTO_INCREMENT NOT NULL,
                type_id INT(10) NOT NULL,
                subject_id INT(10) NOT NULL,
                object_id INT(10) NOT NULL,
                cv_id INT(10) NOT NULL,
                pathdistance INT(10) NOT NULL,
                PRIMARY KEY (cvtermpath_id)
);

ALTER TABLE cvtermpath 
ADD INDEX cvtermpath_idx1 (type_id);

ALTER TABLE cvtermpath 
ADD INDEX cvtermpath_idx2 (subject_id);

ALTER TABLE cvtermpath 
ADD INDEX cvtermpath_idx3 (object_id);

ALTER TABLE cvtermpath 
ADD INDEX cvtermpath_idx4 (cv_id);

ALTER TABLE cvtermpath ADD CONSTRAINT cvtermpath_fk1
FOREIGN KEY (type_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

ALTER TABLE cvtermpath ADD CONSTRAINT cvtermpath_fk2
FOREIGN KEY (subject_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

ALTER TABLE cvtermpath ADD CONSTRAINT cvtermpath_fk3
FOREIGN KEY (object_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

ALTER TABLE cvtermpath ADD CONSTRAINT cvtermpath_fk4
FOREIGN KEY (cv_id)
REFERENCES cvterm (cv_id)
ON DELETE CASCADE;


-- -----------------------------------------------------------+
-- cvtermsynonym
-- -----------------------------------------------------------+

CREATE TABLE cvtermsynonym (
                cvtermsynonym_id INT(10) AUTO_INCREMENT NOT NULL,
                cvterm_id INT(10) NOT NULL,
                synonym VARCHAR(1024) NOT NULL,
                type_id INT(10) NOT NULL,
                PRIMARY KEY (cvtermsynonym_id)
);

ALTER TABLE cvtermsynonym 
ADD INDEX cvtermsynonym_idx1 (cvterm_id);

ALTER TABLE cvtermsynonym ADD CONSTRAINT cvtermsynonym_fk1
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

ALTER TABLE cvtermsynonym ADD CONSTRAINT cvtermsynonym_fk2
FOREIGN KEY (type_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

-- -----------------------------------------------------------+
-- cvterm_dbxref
-- -----------------------------------------------------------+

CREATE TABLE cvterm_dbxref (
                cvterm_dbxref_id INT(10) AUTO_INCREMENT NOT NULL,
                dbxref_id INT(10) NOT NULL,
                is_for_definition BOOLEAN NOT NULL,
                cvterm_id INT(10) NOT NULL,
                PRIMARY KEY (cvterm_dbxref_id)
);

ALTER TABLE cvterm_dbxref 
ADD INDEX cvterm_dbxref_idx1 (cvterm_id);

ALTER TABLE cvterm_dbxref 
ADD INDEX cvterm_dbxref_idx2 (dbxref_id);

ALTER TABLE  cvterm_dbxref ADD CONSTRAINT cvterm_dbxref_fk1
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

ALTER TABLE  cvterm_dbxref ADD CONSTRAINT cvterm_dbxref_fk2
FOREIGN KEY (dbxref_id)
REFERENCES dbxref (dbxref_id)
ON DELETE CASCADE;

-- -----------------------------------------------------------+
-- cvtermprop
-- -----------------------------------------------------------+

CREATE TABLE cvtermprop (
                cvtermprop_id INT(10) AUTO_INCREMENT NOT NULL,
                cvterm_id INT(10) NOT NULL,
                type_id INT(10) NOT NULL,
                rank TINYINT(3) NOT NULL,
                value TEXT NOT NULL DEFAULT '',
                PRIMARY KEY (cvtermprop_id)
);

ALTER TABLE cvtermprop 
ADD INDEX cvtermprop_idx1 (cvterm_id);

ALTER TABLE cvtermprop 
ADD INDEX cvtermprop_idx2 (type_id);

ALTER TABLE cvtermprop ADD CONSTRAINT cvtermprop_fk1
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

ALTER TABLE cvtermprop ADD CONSTRAINT cvtermprop_fk2
FOREIGN KEY (type_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

-- -----------------------------------------------------------+
-- dbrefprop
-- -----------------------------------------------------------+
CREATE TABLE dbxrefprop (
                dbxrefprop_id INT(10) AUTO_INCREMENT NOT NULL,
                type_id INT(10) NOT NULL,
                dbxref_id INT(10) NOT NULL,
                rank SMALLINT(3) NOT NULL,
                value TEXT NOT NULL,
                PRIMARY KEY (dbxrefprop_id)
);

ALTER TABLE dbxrefprop 
ADD INDEX dbxrefprop_idx1 (dbxref_id);

ALTER TABLE dbxrefprop 
ADD INDEX dbxrefprop_idx2 (type_id);

ALTER TABLE dbxrefprop ADD CONSTRAINT dbxrefprop_fk1
FOREIGN KEY (dbxref_id)
REFERENCES dbxref (dbxref_id)
ON DELETE CASCADE;

ALTER TABLE dbxrefprop ADD CONSTRAINT dbxrefprop_fk2
FOREIGN KEY (type_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE;

-- -----------------------------------------------------------+
-- DATA SOURCE TABLES
-- -----------------------------------------------------------+

-- -----------------------------------------------------------+
-- source
-- -----------------------------------------------------------+

CREATE TABLE source (
                source_id INT(10) AUTO_INCREMENT NOT NULL,
                PRIMARY KEY (source_id)
);

-- -----------------------------------------------------------+
-- source_attribute
-- -----------------------------------------------------------+

CREATE TABLE source_attribute (
                source_attribute_id INT(10) NOT NULL,
                source_id INT(10) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                value TEXT NOT NULL,
                rank SMALLINT(3) NOT NULL,
                PRIMARY KEY (source_attribute_id)
);


-- -----------------------------------------------------------+
-- member_attribute
-- -----------------------------------------------------------+
-- Need to allow value to be null, this can allow for
-- assignments of values without value attribute
CREATE TABLE member_attribute (
                member_attribute_id INT(10) AUTO_INCREMENT NOT NULL,
                member_id INT(8) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                value TEXT,
                rank SMALLINT(3) DEFAULT 0,
                source_id INT(10),
                PRIMARY KEY (member_attribute_id)
);

ALTER TABLE member_attribute 
ADD INDEX (member_id);

ALTER TABLE member_attribute 
ADD INDEX (cvterm_id);

-- -----------------------------------------------------------+
-- member_attribute
-- ----------------------------------------------------------+

ALTER TABLE member_attribute COMMENT 'This would be the table to assign information to the protein.';


CREATE INDEX member_attribute_idx 
USING BTREE
 ON member_attribute
 ( member_id, cvterm_id );

-- -----------------------------------------------------------+
-- -----------------------------------------------------------+
-- -----------------------------------------------------------+
-- protein_tree
-- -----------------------------------------------------------+
-- -----------------------------------------------------------+
-- -----------------------------------------------------------+
-- Moved family_id and root_node_id
-- to this table. This will provide a single palce to get both
-- root and cluster set, and will allow for a quick and easy
-- query for the set of protein_trees that exist for a
-- a given cluster set. These may be different by the
-- method used for reconciliation

CREATE TABLE protein_tree (
                protein_tree_id INT(10) AUTO_INCREMENT NOT NULL,
                family_id INT(10) NOT NULL,
                root_node_id INT(10) NOT NULL,
                PRIMARY KEY (protein_tree_id)
);

ALTER TABLE protein_tree COMMENT 'I don''t know if this table would really be necessary. ';

-- -----------------------------------------------------------+
-- protein_tree_attribute
-- -----------------------------------------------------------+

CREATE TABLE protein_tree_attribute (
                protein_tree_attribute_id INT(10) AUTO_INCREMENT NOT NULL,
                protein_tree_id INT(10) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                value TEXT NOT NULL,
                rank SMALLINT(3) DEFAULT 0 NOT NULL,
                source_id INT(10),
                PRIMARY KEY (protein_tree_attribute_id)
);


-- -----------------------------------------------------------+
-- protein_tree_node
-- -----------------------------------------------------------+
-- I think that it may be useful to drop the following from
-- this table and move to protein_tree
-- root_id
-- clusterset_id
-- but these will be left here for now.

CREATE TABLE protein_tree_node (
                node_id INT(8) AUTO_INCREMENT NOT NULL,
                protein_tree_id INT(10) NOT NULL,
                parent_id INT(8) NOT NULL,
                root_id INT(8) NOT NULL,
                clusterset_id INT(10) NOT NULL,
                left_index INT(8) NOT NULL,
                right_index INT(8) NOT NULL,
                distance_to_parent DOUBLE PRECISION DEFAULT 1 NOT NULL,
                PRIMARY KEY (node_id)
);

ALTER TABLE protein_tree_node COMMENT 'It looks like trees are defined as a group by the root_id. It may make more sense to have a TREE_ID field. I ADDED protein_tree_id  ';

ALTER TABLE protein_tree_node MODIFY COLUMN protein_tree_id INTEGER(10) COMMENT 'THIS WAS ADDED TO E_C schema';


CREATE INDEX protein_tree_node_parent_id_idx 
USING BTREE
 ON protein_tree_node
 ( parent_id ASC );

CREATE INDEX protein_tree_node_root_id_idx 
USING BTREE
 ON protein_tree_node
 ( root_id ASC );

CREATE INDEX protein_tree_node_left_index_idx 
USING BTREE
 ON protein_tree_node
 ( left_index ASC );

CREATE INDEX protein_tree_node_right_index_idx 
USING BTREE
 ON protein_tree_node
 ( right_index ASC );

-- -----------------------------------------------------------+
-- PROTEIN_TREE_NODE_ATTRIBUTE
-- -----------------------------------------------------------+
-- This will hold tag value pairs from PRIME format files
-- for example AC vals etc
CREATE TABLE protein_tree_node_attribute (
                protein_node_attribute_id INT(10) AUTO_INCREMENT NOT NULL,
                node_id INT(8) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                value TEXT NOT NULL,
                rank SMALLINT(3) NOT NULL,
                source_id INT(10),
                PRIMARY KEY (protein_node_attribute_id)
);


-- -----------------------------------------------------------+
-- protein_tree_node_path
-- -----------------------------------------------------------+
-- This will hold TC path values for protein trees
--
CREATE TABLE protein_tree_node_path (
                protein_tree_node_path_id INT(10) AUTO_INCREMENT NOT NULL,
                parent_node_id INT(10) NOT NULL,
                child_node_id INT(10) NOT NULL,
                path TEXT NOT NULL,
                distance INT(10) NOT NULL,
                PRIMARY KEY (protein_tree_node_path_id)
);

ALTER TABLE protein_tree_node_path 
ADD INDEX protein_tree_node_path_idx1 (parent_node_id);

ALTER TABLE protein_tree_node_path 
ADD INDEX protein_tree_node_path_idx2 (child_node_id);

ALTER TABLE protein_tree_node_path 
ADD INDEX protein_tree_node_path_idx3 (distance);

-- -----------------------------------------------------------+
-- -----------------------------------------------------------|
-- -----------------------------------------------------------|
-- SPECIES TREE TABLES                                       |
-- -----------------------------------------------------------|
-- -----------------------------------------------------------|
-- -----------------------------------------------------------+
-- The following tables are related to the storage of 
-- species trees. These are generally trees that serve
-- as hosts to the guest species tree.


-- -----------------------------------------------------------+
-- species_tree
-- -----------------------------------------------------------+
-- It may be easier for queries if all trees have a name
-- and a version. For the moment these will be allowed to be null
-- 		tree_name TEXT NOT NULL,
-- may want to add root_node, this would provide a starting
-- point for indexing
CREATE TABLE species_tree (
                species_tree_id INT(10) AUTO_INCREMENT NOT NULL,
                species_tree_name TEXT,
                root_node_id INT(10),
                version SMALLINT(3),
                PRIMARY KEY (species_tree_id)
);

-- Need to add index for species tree
-- Add index for root_node_id
-- root_node_id is FK that is dependent on species_tree_node_id

-- -----------------------------------------------------------+
-- species_tree_attribute
-- -----------------------------------------------------------+

CREATE TABLE species_tree_attribute (
                species_tree_attribute_id INT(10) AUTO_INCREMENT NOT NULL,
                species_tree_id INT(10) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                value TEXT NOT NULL,
                rank SMALLINT(3) DEFAULT 0 NOT NULL,
                source_id INT(10),
                PRIMARY KEY (species_tree_attribute_id)
);


ALTER TABLE species_tree_attribute COMMENT 'This would be the place to store information like version, software used, parameters etc for species tree reconstruction. ';

-- -----------------------------------------------------------+
-- species_tree_node
-- -----------------------------------------------------------+
CREATE TABLE species_tree_node (
                species_tree_node_id INT(10) AUTO_INCREMENT NOT NULL,
                species_tree_id INT(10) NOT NULL,
                parent_id INT(10) NOT NULL,
                label TEXT,
                left_index INT(10) NOT NULL,
                right_index INT(10) NOT NULL,
                PRIMARY KEY (species_tree_node_id)
);

ALTER TABLE species_tree_node 
ADD INDEX species_tree_node_idx2 (left_index);

ALTER TABLE species_tree_node 
ADD INDEX species_tree_node_idx3 (right_index);

ALTER TABLE species_tree_node 
ADD INDEX species_tree_node_idx4 (species_tree_id);

ALTER TABLE species_tree_node 
ADD  INDEX species_tree_node_idx5 (parent_id);

-- -----------------------------------------------------------+
-- species_tree_node_attribute
-- -----------------------------------------------------------+

CREATE TABLE species_tree_node_attribute (
                species_tree_node_attribute_id INT(10) AUTO_INCREMENT NOT NULL,
                species_tree_node_id INT(10) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                value TEXT NOT NULL,
                rank SMALLINT(3) DEFAULT 0 NOT NULL,
                source_id INT(10),
                PRIMARY KEY (species_tree_node_attribute_id)
);


-- Foreign key
ALTER TABLE species_tree_node_attribute 
      ADD CONSTRAINT term_species_tree_node_attribute_fk
      FOREIGN KEY (cvterm_id)
      REFERENCES cvterm (cvterm_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE;

ALTER TABLE species_tree_node_attribute COMMENT 'This can hold information like taxonomic name of the node';

-- -----------------------------------------------------------+
-- species_tree_node_path
-- -----------------------------------------------------------+

CREATE TABLE species_tree_node_path (
                species_tree_node_path_id INT(10) AUTO_INCREMENT NOT NULL,
                parent_node_id INT(10) NOT NULL,
                child_node_id INT(10) NOT NULL,
                path TEXT NOT NULL,
                distance INT(10) NOT NULL,
                PRIMARY KEY (species_tree_node_path_id)
);

ALTER TABLE species_tree_node_path COMMENT 'For transitive closure between nodes. This is an optimization that is used for finding LCA. Idea taken from BioSQL phylo extension (Lapp and Piel). This would be necessary if finding the set of LCAs given as set of species (leaf nodes) of interest.';

ALTER TABLE species_tree_node_path MODIFY COLUMN path TEXT COMMENT 'This will get very large for big trees and may be too unwieldy to use in the database, may need to make the path an attribute with rank field.';

ALTER TABLE species_tree_node_path MODIFY COLUMN distance INTEGER(10) COMMENT 'Distance in the number nodes(or edges) between the child and the parent. This is used for optimized queries of LCA.';



-- -----------------------------------------------------------+
-- -----------------------------------------------------------|
-- -----------------------------------------------------------|
-- RECONCILIATION TABLES                                     |
-- -----------------------------------------------------------|
-- -----------------------------------------------------------|
-- -----------------------------------------------------------+
-- Added to test database 09/29/2010

CREATE TABLE reconciliation (
                reconciliation_id INT(10) AUTO_INCREMENT NOT NULL,
                protein_tree_id INT(10) NOT NULL,
                species_tree_id INT(10) NOT NULL,
                species_set_id INT(10) NOT NULL,
                PRIMARY KEY (reconciliation_id)
);



ALTER TABLE reconciliation COMMENT 'Reconciliation set refers to the set of nodes from a gene tree mapped to a set of nodes from the species tree.';


CREATE INDEX reconciliation_idx USING BTREE
 ON reconciliation
 ( species_tree_id, species_set_id, protein_tree_id );

CREATE TABLE reconciliation_attribute (
                reconciliation_attribute_id INT(10) AUTO_INCREMENT NOT NULL,
                reconciliation_id INT(10) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                value TEXT NOT NULL,
                rank SMALLINT(3) DEFAULT 0 NOT NULL,
                source_id INT(10),
                PRIMARY KEY (reconciliation_attribute_id)
);

ALTER TABLE reconciliation_attribute
ADD INDEX reconciliation_attribute_idx1 (reconciliation_id);

ALTER TABLE reconciliation_attribute
ADD INDEX reconciliation_attribute_idx2 (cvterm_id);

ALTER TABLE reconciliation_attribute COMMENT 'This is the place to store information related to the parameters used to generate a specific reconciliation. For example the program, program version, and any program specific parameters. Programs include primetv, treebest as well as alignment programs (Muscle, and others). This could also be a place to store the list of species from the species tree that are used in the reconciliation, this is a point to tak about.';

-- -----------------------------------------------------------+
-- RECONCILIATION NODE TABLE
-- -----------------------------------------------------------+
-- Added 10/02/2010
CREATE TABLE reconciliation_node (
                reconciliation_node_id INT(10) AUTO_INCREMENT NOT NULL,
                reconciliation_id INT(10) NOT NULL,
                node_id INT(8) NOT NULL,
                host_parent_node_id INT(10),
                host_child_node_id INT(10),
                is_on_node BOOLEAN NOT NULL,
                PRIMARY KEY (reconciliation_node_id)
);


CREATE TABLE reconciliation_node_attribute (
                reconciliation_node_attribute_id INT(10) AUTO_INCREMENT NOT NULL,
                reconciliation_node_id INT(10) NOT NULL,
                cvterm_id INT(10) NOT NULL,
                value VARCHAR(255) NOT NULL,
                rank SMALLINT(3) DEFAULT 0 NOT NULL,
                source_id INT(10),
                PRIMARY KEY (reconciliation_node_attribute_id)
);


-- Additional reconciliation table added 02/27/2012
-- The following allows for a central place to store information
-- about a reconciliaton experiment set.

CREATE TABLE reconciliation_set (
       	     reconciliation_set_id INT(10) AUTO_INCREMENT NOT NULL,
	     name VARCHAR(255) NOT NULL,
	     description VARCHAR(255),
	     PRIMARY KEY (reconciliation_set_id)
);

-- ATTRIBUTES RELATED TO THE RECONCILIATION SET
CREATE TABLE reconciliation_set_attribute (
       	     reconciliation_set_attribute_id INT(10) AUTO_INCREMENT NOT NULL,
	     reconciliation_set_id INT(10) NOT NULL,
             cvterm_id INT(10) NOT NULL,
             value VARCHAR(255) NOT NULL,
             rank SMALLINT(3) DEFAULT 0 NOT NULL,
             source_id INT(10),
	     PRIMARY KEY (reconciliation_set_attribute_id)
);

-- END ADDITIONS OF 2/27/2012


CREATE TABLE protein_tree_stable_id (
                protein_stable_id_id INT(10) AUTO_INCREMENT NOT NULL,
                node_id INT(8) NOT NULL,
                stable_id VARCHAR(40) NOT NULL,
                version INT(8) NOT NULL,
                PRIMARY KEY (protein_stable_id_id)
);


CREATE UNIQUE INDEX protein_tree_stable_id_stable_id_idx USING BTREE
 ON protein_tree_stable_id
 ( stable_id ASC );

CREATE TABLE protein_tree_hmmprofile (
                protein_tree_hmmprofile_id INT(10) AUTO_INCREMENT NOT NULL,
                node_id INT(8) NOT NULL,
                type VARCHAR(40) DEFAULT '' NOT NULL,
                hmmprofile TEXT,
                PRIMARY KEY (protein_tree_hmmprofile_id)
);


CREATE UNIQUE INDEX protein_tree_hmmprofile_node_id_idx_1 USING BTREE
 ON protein_tree_hmmprofile
 ( type ASC, node_id ASC );

CREATE INDEX protein_tree_hmmprofile_node_id_idx_2 USING BTREE
 ON protein_tree_hmmprofile
 ( node_id ASC );

CREATE TABLE protein_tree_member_score (
                protein_tree_member_score INT(10) AUTO_INCREMENT NOT NULL,
                node_id INT(8) NOT NULL,
                root_id INT(8) NOT NULL,
                member_id INT(8) NOT NULL,
                method_link_species_set_id INT(8) NOT NULL,
                cigar_line TEXT,
                cigar_start INT(8),
                cigar_end INT(8),
                PRIMARY KEY (protein_tree_member_score)
);


CREATE UNIQUE INDEX protein_tree_member_score_node_id_idx USING BTREE
 ON protein_tree_member_score
 ( node_id ASC );

CREATE INDEX protein_tree_member_score_root_id_idx USING BTREE
 ON protein_tree_member_score
 ( root_id ASC );

CREATE INDEX protein_tree_member_score_member_id_idx USING BTREE
 ON protein_tree_member_score
 ( member_id ASC );

-- -----------------------------------------------------------+
-- PROTEIN TREE MEMBER
-- -----------------------------------------------------------+
-- This tables links the information from members to the
-- the protein trees they participate in

CREATE TABLE protein_tree_member (
                protein_tree_member_id INT(10) AUTO_INCREMENT NOT NULL,
                node_id INT(8) NOT NULL,
                root_id INT(8) NOT NULL,
                member_id INT(8) NOT NULL,
                method_link_species_set_id INT(8) NOT NULL,
                cigar_line TEXT,
                cigar_start INT(8),
                cigar_end INT(8),
                PRIMARY KEY (protein_tree_member_id)
);


CREATE UNIQUE INDEX protein_tree_member_node_id_idx 
USING BTREE
 ON protein_tree_member
 ( node_id ASC );

CREATE INDEX protein_tree_member_root_id_idx 
USING BTREE
 ON protein_tree_member
 ( root_id ASC );

CREATE INDEX protein_tree_member_member_id_idx USING 
BTREE
 ON protein_tree_member
 ( member_id ASC );


-- THIS TABLE FROM E-C NOT USED
/*
CREATE TABLE protein_tree_tag (
                protein_tree_tag_id INT(10) AUTO_INCREMENT NOT NULL,
                node_id INT(8) NOT NULL,
                tag VARCHAR(50),
                value TEXT,
                PRIMARY KEY (protein_tree_tag_id)
);


CREATE UNIQUE INDEX protein_tree_tag_tag_node_id_idx USING BTREE
 ON protein_tree_tag
 ( node_id ASC, tag ASC );

CREATE INDEX protein_tree_tag_node_id_idx USING BTREE
 ON protein_tree_tag
 ( node_id ASC );

CREATE INDEX protein_tree_tag_tag_idx USING BTREE
 ON protein_tree_tag
 ( tag ASC );
*/

-- -----------------------------------------------------------+
-- CONSTRAINTS
-- -----------------------------------------------------------+
-- KEEP AT BOTTOM TO INSURE ALL TABLES AND FIELDS EXIST
-- WHEN ADDING CONSTRAINTS

ALTER TABLE reconciliation_attribute 
ADD CONSTRAINT source_reconciliation_attribute_fk
FOREIGN KEY (source_id)
REFERENCES source (source_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE species_tree_node_attribute 
ADD CONSTRAINT source_species_tree_node_attribute_fk
FOREIGN KEY (source_id)
REFERENCES source (source_id)
ON DELETE CASCADE
ON UPDATE CASCADE;


ALTER TABLE species_tree_attribute 
ADD CONSTRAINT source_species_tree_attribute_fk
FOREIGN KEY (source_id)
REFERENCES source (source_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE reconciliation_node_attribute 
ADD CONSTRAINT source_reconciliation_node_attribute_fk
FOREIGN KEY (source_id)
REFERENCES source (source_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_attribute 
ADD CONSTRAINT source_protein_tree_attribute_fk
FOREIGN KEY (source_id)
REFERENCES source (source_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE member_attribute 
ADD CONSTRAINT source_member_attribute_fk
FOREIGN KEY (source_id)
REFERENCES source (source_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE source_attribute 
ADD CONSTRAINT source_source_attribute_fk
FOREIGN KEY (source_id)
REFERENCES source (source_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_node_attribute 
ADD CONSTRAINT source_protein_tree_node_attribute_fk
FOREIGN KEY (source_id)
REFERENCES source (source_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_member 
ADD CONSTRAINT member_protein_tree_member_fk
FOREIGN KEY (member_id)
REFERENCES member (member_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE member_attribute 
ADD CONSTRAINT member_member_attribute_fk
FOREIGN KEY (member_id)
REFERENCES member (member_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE cvterm 
ADD CONSTRAINT ontology_term_fk
FOREIGN KEY (cv_id)
REFERENCES cv (cv_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE cvtermpath 
ADD CONSTRAINT cv_cvtermpath_fk
FOREIGN KEY (cv_id)
REFERENCES cv (cv_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE reconciliation_attribute 
ADD CONSTRAINT term_reconciliation_set_attribute_fk
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE species_tree_attribute 
ADD CONSTRAINT term_species_tree_attribute_fk
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE reconciliation_node_attribute 
ADD CONSTRAINT term_reconciliation_node_map_attribute_fk
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_attribute 
ADD CONSTRAINT term_protein_tree_attribute_fk
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE member_attribute 
ADD CONSTRAINT term_member_attribute_fk
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE source_attribute 
ADD CONSTRAINT cvterm_source_attribute_fk
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE dbxrefprop 
ADD CONSTRAINT cvterm_dbxrefprop_fk
FOREIGN KEY (type_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_node_attribute 
ADD CONSTRAINT cvterm_protein_tree_node_attribute_fk
FOREIGN KEY (cvterm_id)
REFERENCES cvterm (cvterm_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_node 
ADD CONSTRAINT protein_tree_protein_tree_node_fk
FOREIGN KEY (protein_tree_id)
REFERENCES protein_tree (protein_tree_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE reconciliation 
ADD CONSTRAINT protein_tree_reconciliation_set_fk
FOREIGN KEY (protein_tree_id)
REFERENCES protein_tree (protein_tree_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_attribute 
ADD CONSTRAINT protein_tree_protein_tree_attribute_fk
FOREIGN KEY (protein_tree_id)
REFERENCES protein_tree (protein_tree_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE species_tree_node 
ADD CONSTRAINT species_tree_species_tree_node_fk
FOREIGN KEY (species_tree_id)
REFERENCES species_tree (species_tree_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE reconciliation 
ADD CONSTRAINT species_tree_reconciliation_set_fk
FOREIGN KEY (species_tree_id)
REFERENCES species_tree (species_tree_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE species_tree_attribute 
ADD CONSTRAINT species_tree_species_tree_attribute_fk
FOREIGN KEY (species_tree_id)
REFERENCES species_tree (species_tree_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

/*
Warning: MySQL does not support this relationship's deferrability policy (INITIALLY_DEFERRED).
*/
ALTER TABLE reconciliation_node 
ADD CONSTRAINT reconciliation_set_reconciliation_node_map_fk
FOREIGN KEY (reconciliation_id)
REFERENCES reconciliation (reconciliation_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE reconciliation_attribute 
ADD CONSTRAINT reconciliation_set_reconciliation_set_attribute_fk
FOREIGN KEY (reconciliation_id)
REFERENCES reconciliation (reconciliation_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE species_tree_node_attribute 
ADD CONSTRAINT species_tree_node_species_tree_node_attribute_fk
FOREIGN KEY (species_tree_node_id)
REFERENCES species_tree_node (species_tree_node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE species_tree_node_path 
ADD CONSTRAINT species_tree_node_species_tree_node_path_fk_1
FOREIGN KEY (parent_node_id)
REFERENCES species_tree_node (species_tree_node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE species_tree_node_path 
ADD CONSTRAINT species_tree_node_species_tree_node_path_fk_2
FOREIGN KEY (child_node_id)
REFERENCES species_tree_node (species_tree_node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

/*
ALTER TABLE protein_tree_tag 
ADD CONSTRAINT protein_tree_node_protein_tree_tag_fk
FOREIGN KEY (node_id)
REFERENCES protein_tree_node (node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;
*/

ALTER TABLE protein_tree_member 
ADD CONSTRAINT protein_tree_node_protein_tree_member_fk
FOREIGN KEY (node_id)
REFERENCES protein_tree_node (node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_member_score 
ADD CONSTRAINT protein_tree_node_protein_tree_member_score_fk
FOREIGN KEY (node_id)
REFERENCES protein_tree_node (node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_hmmprofile 
ADD CONSTRAINT protein_tree_node_protein_tree_hmmprofile_fk
FOREIGN KEY (node_id)
REFERENCES protein_tree_node (node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_stable_id 
ADD CONSTRAINT protein_tree_node_protein_tree_stable_id_fk
FOREIGN KEY (node_id)
REFERENCES protein_tree_node (node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE reconciliation_node 
ADD CONSTRAINT protein_tree_node_reconciliation_node_map_fk
FOREIGN KEY (node_id)
REFERENCES protein_tree_node (node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE protein_tree_node_attribute 
ADD CONSTRAINT protein_tree_node_protein_tree_node_attribute_fk
FOREIGN KEY (node_id)
REFERENCES protein_tree_node (node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE reconciliation_node_attribute 
ADD CONSTRAINT reconciliation_node_map_reconciliation_node_map_attribute_fk
FOREIGN KEY (reconciliation_node_id)
REFERENCES reconciliation_node (reconciliation_node_id)
ON DELETE CASCADE
ON UPDATE CASCADE;
