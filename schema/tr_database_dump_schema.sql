-- MySQL dump 10.13  Distrib 5.1.46, for apple-darwin9.8.0 (i386)
--
-- Host: localhost    Database: tr_test
-- ------------------------------------------------------
-- Server version	5.1.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cv`
--

DROP TABLE IF EXISTS `cv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cv` (
  `cv_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `definition` text NOT NULL,
  PRIMARY KEY (`cv_id`),
  UNIQUE KEY `cv_c1` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cvterm`
--

DROP TABLE IF EXISTS `cvterm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cvterm` (
  `cvterm_id` int(10) NOT NULL AUTO_INCREMENT,
  `cv_id` int(10) NOT NULL,
  `name` varchar(950) NOT NULL,
  `definition` text,
  `dbxref_id` int(10) NOT NULL,
  `is_obsolete` tinyint(1) NOT NULL DEFAULT '0',
  `is_relationshiptype` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cvterm_id`),
  UNIQUE KEY `cvterm_c1` (`name`,`cv_id`,`is_obsolete`),
  UNIQUE KEY `cvterm_c2` (`dbxref_id`),
  KEY `cvterm_idx1` (`cv_id`),
  KEY `cvterm_idx2` (`name`),
  KEY `cvterm_idx3` (`dbxref_id`)
) ENGINE=MyISAM AUTO_INCREMENT=32963 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cvterm_dbxref`
--

DROP TABLE IF EXISTS `cvterm_dbxref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cvterm_dbxref` (
  `cvterm_dbxref_id` int(10) NOT NULL AUTO_INCREMENT,
  `dbxref_id` int(10) NOT NULL,
  `is_for_definition` tinyint(1) NOT NULL,
  `cvterm_id` int(10) NOT NULL,
  PRIMARY KEY (`cvterm_dbxref_id`),
  KEY `cvterm_dbxref_idx1` (`cvterm_id`),
  KEY `cvterm_dbxref_idx2` (`dbxref_id`)
) ENGINE=MyISAM AUTO_INCREMENT=73980 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cvterm_relationship`
--

DROP TABLE IF EXISTS `cvterm_relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cvterm_relationship` (
  `cvterm_relationship_id` int(10) NOT NULL AUTO_INCREMENT,
  `type_id` int(10) NOT NULL,
  `subject_id` int(10) NOT NULL,
  `object_id` int(10) NOT NULL,
  `cvterm_id` int(10) NOT NULL,
  PRIMARY KEY (`cvterm_relationship_id`),
  UNIQUE KEY `cvterm_relationship_c1` (`subject_id`,`object_id`,`type_id`),
  KEY `cvterm_relationship_idx1` (`type_id`),
  KEY `cvterm_relationship_idx2` (`subject_id`),
  KEY `cvterm_relationship_idx3` (`object_id`)
) ENGINE=MyISAM AUTO_INCREMENT=57544 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cvtermpath`
--

DROP TABLE IF EXISTS `cvtermpath`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cvtermpath` (
  `cvtermpath_id` int(10) NOT NULL AUTO_INCREMENT,
  `type_id` int(10) NOT NULL,
  `subject_id` int(10) NOT NULL,
  `object_id` int(10) NOT NULL,
  `cv_id` int(10) NOT NULL,
  `pathdistance` int(10) NOT NULL,
  PRIMARY KEY (`cvtermpath_id`),
  KEY `cvtermpath_idx1` (`type_id`),
  KEY `cvtermpath_idx2` (`subject_id`),
  KEY `cvtermpath_idx3` (`object_id`),
  KEY `cvtermpath_idx4` (`cv_id`)
) ENGINE=MyISAM AUTO_INCREMENT=264090 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cvtermprop`
--

DROP TABLE IF EXISTS `cvtermprop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cvtermprop` (
  `cvtermprop_id` int(10) NOT NULL AUTO_INCREMENT,
  `cvterm_id` int(10) NOT NULL,
  `type_id` int(10) NOT NULL,
  `rank` tinyint(3) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`cvtermprop_id`),
  KEY `cvtermprop_idx1` (`cvterm_id`),
  KEY `cvtermprop_idx2` (`type_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3381 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cvtermsynonym`
--

DROP TABLE IF EXISTS `cvtermsynonym`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cvtermsynonym` (
  `cvtermsynonym_id` int(10) NOT NULL AUTO_INCREMENT,
  `cvterm_id` int(10) NOT NULL,
  `synonym` varchar(1024) NOT NULL,
  `type_id` int(10) NOT NULL,
  PRIMARY KEY (`cvtermsynonym_id`),
  KEY `cvtermsynonym_idx1` (`cvterm_id`),
  KEY `cvtermsynonym_fk2` (`type_id`)
) ENGINE=MyISAM AUTO_INCREMENT=64151 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `db`
--

DROP TABLE IF EXISTS `db`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `db` (
  `db_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `urlprefix` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`db_id`),
  UNIQUE KEY `db_c1` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=127 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dbxref`
--

DROP TABLE IF EXISTS `dbxref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dbxref` (
  `dbxref_id` int(10) NOT NULL AUTO_INCREMENT,
  `db_id` int(10) NOT NULL,
  `accession` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL DEFAULT '',
  `description` text,
  PRIMARY KEY (`dbxref_id`),
  UNIQUE KEY `dbxref_c1` (`db_id`,`accession`,`version`),
  KEY `dbxref_idx1` (`db_id`),
  KEY `dbxref_idx2` (`accession`),
  KEY `dbxref_idx3` (`version`),
  KEY `db_id` (`db_id`)
) ENGINE=MyISAM AUTO_INCREMENT=58517 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dbxrefprop`
--

DROP TABLE IF EXISTS `dbxrefprop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dbxrefprop` (
  `dbxrefprop_id` int(10) NOT NULL AUTO_INCREMENT,
  `type_id` int(10) NOT NULL,
  `dbxref_id` int(10) NOT NULL,
  `rank` smallint(3) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`dbxrefprop_id`),
  KEY `dbxrefprop_idx1` (`dbxref_id`),
  KEY `dbxrefprop_idx2` (`type_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `family`
--

DROP TABLE IF EXISTS `family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `family` (
  `family_id` int(10) NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(40) DEFAULT NULL,
  `version` int(10) DEFAULT NULL,
  `method_link_species_set_id` int(10) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `description_score` double DEFAULT NULL,
  PRIMARY KEY (`family_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2747 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `family_attribute`
--

DROP TABLE IF EXISTS `family_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `family_attribute` (
  `family_attribute_id` int(10) NOT NULL AUTO_INCREMENT,
  `family_id` int(10) NOT NULL,
  `cvterm_id` int(10) NOT NULL,
  `value` text,
  `rank` smallint(3) DEFAULT '0',
  `source_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`family_attribute_id`),
  KEY `family_id` (`family_id`),
  KEY `cvterm_id` (`cvterm_id`)
) ENGINE=MyISAM AUTO_INCREMENT=29618 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `family_member`
--

DROP TABLE IF EXISTS `family_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `family_member` (
  `family_id` int(10) DEFAULT NULL,
  `member_id` int(10) DEFAULT NULL,
  `cigar_line` mediumtext
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member` (
  `member_id` int(8) NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(64) NOT NULL,
  `version` int(8) DEFAULT '0',
  `source_name` char(17) NOT NULL,
  `taxon_id` int(8) NOT NULL,
  `genome_db_id` int(8) DEFAULT NULL,
  `sequence_id` int(8) DEFAULT NULL,
  `gene_member_id` int(8) DEFAULT NULL,
  `description` text,
  `chr_name` char(40) DEFAULT NULL,
  `chr_start` int(8) DEFAULT NULL,
  `chr_end` int(8) DEFAULT NULL,
  `chr_strand` tinyint(1) NOT NULL,
  `display_label` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`member_id`),
  KEY `taxon_id` (`taxon_id`) USING BTREE,
  KEY `genome_db_id` (`genome_db_id`) USING BTREE,
  KEY `stable_id` (`stable_id`) USING BTREE,
  KEY `source_name` (`source_name`) USING BTREE,
  KEY `sequence_id` (`sequence_id`) USING BTREE,
  KEY `gene_member_id` (`gene_member_id`) USING BTREE,
  KEY `stable_id_2` (`stable_id`),
  KEY `display_label` (`display_label`),
  KEY `member_id` (`member_id`)
) ENGINE=MyISAM AUTO_INCREMENT=25370 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `member_attribute`
--

DROP TABLE IF EXISTS `member_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_attribute` (
  `member_attribute_id` int(10) NOT NULL AUTO_INCREMENT,
  `member_id` int(8) NOT NULL,
  `cvterm_id` int(10) NOT NULL,
  `value` text,
  `rank` smallint(3) DEFAULT '0',
  `source_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`member_attribute_id`),
  KEY `member_id` (`member_id`),
  KEY `cvterm_id` (`cvterm_id`),
  KEY `cvterm_id_2` (`cvterm_id`)
) ENGINE=MyISAM AUTO_INCREMENT=190135 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `protein_tree`
--

DROP TABLE IF EXISTS `protein_tree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `protein_tree` (
  `protein_tree_id` int(10) NOT NULL AUTO_INCREMENT,
  `family_id` int(10) NOT NULL,
  `root_node_id` int(10) NOT NULL,
  PRIMARY KEY (`protein_tree_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2541 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `protein_tree_attribute`
--

DROP TABLE IF EXISTS `protein_tree_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `protein_tree_attribute` (
  `protein_tree_attribute_id` int(10) NOT NULL AUTO_INCREMENT,
  `protein_tree_id` int(10) NOT NULL,
  `cvterm_id` int(10) NOT NULL,
  `value` text NOT NULL,
  `rank` smallint(3) NOT NULL DEFAULT '0',
  `source_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`protein_tree_attribute_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `protein_tree_member`
--

DROP TABLE IF EXISTS `protein_tree_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `protein_tree_member` (
  `protein_tree_member_id` int(10) NOT NULL AUTO_INCREMENT,
  `node_id` int(8) NOT NULL,
  `root_id` int(8) NOT NULL,
  `member_id` int(8) NOT NULL,
  `method_link_species_set_id` int(8) NOT NULL,
  `cigar_line` text,
  `cigar_start` int(8) DEFAULT NULL,
  `cigar_end` int(8) DEFAULT NULL,
  PRIMARY KEY (`protein_tree_member_id`),
  KEY `node_id` (`node_id`),
  KEY `member_id` (`member_id`)
) ENGINE=MyISAM AUTO_INCREMENT=25326 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `protein_tree_node`
--

DROP TABLE IF EXISTS `protein_tree_node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `protein_tree_node` (
  `node_id` int(8) NOT NULL AUTO_INCREMENT,
  `protein_tree_id` int(10) NOT NULL,
  `parent_id` int(8) NOT NULL,
  `root_id` int(8) NOT NULL,
  `clusterset_id` int(10) NOT NULL,
  `left_index` int(8) NOT NULL,
  `right_index` int(8) NOT NULL,
  `distance_to_parent` double NOT NULL DEFAULT '1',
  PRIMARY KEY (`node_id`),
  KEY `node_id` (`node_id`),
  KEY `parent_id` (`parent_id`),
  KEY `protein_tree_id` (`protein_tree_id`),
  KEY `left_index` (`left_index`),
  KEY `right_index` (`right_index`)
) ENGINE=MyISAM AUTO_INCREMENT=51730 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `protein_tree_node_attribute`
--

DROP TABLE IF EXISTS `protein_tree_node_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `protein_tree_node_attribute` (
  `protein_node_attribute_id` int(10) NOT NULL AUTO_INCREMENT,
  `node_id` int(8) NOT NULL,
  `cvterm_id` int(10) NOT NULL,
  `value` text NOT NULL,
  `rank` smallint(3) NOT NULL,
  `source_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`protein_node_attribute_id`),
  KEY `node_id` (`node_id`),
  KEY `cvterm_id` (`cvterm_id`),
  KEY `source_id` (`source_id`)
) ENGINE=MyISAM AUTO_INCREMENT=146317 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `protein_tree_node_path`
--

DROP TABLE IF EXISTS `protein_tree_node_path`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `protein_tree_node_path` (
  `protein_tree_node_path_id` int(10) NOT NULL AUTO_INCREMENT,
  `parent_node_id` int(10) NOT NULL,
  `child_node_id` int(10) NOT NULL,
  `path` text NOT NULL,
  `distance` int(10) NOT NULL,
  PRIMARY KEY (`protein_tree_node_path_id`),
  KEY `protein_tree_node_path_idx1` (`parent_node_id`),
  KEY `protein_tree_node_path_idx2` (`child_node_id`),
  KEY `protein_tree_node_path_idx3` (`distance`)
) ENGINE=MyISAM AUTO_INCREMENT=604822 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reconciliation`
--

DROP TABLE IF EXISTS `reconciliation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reconciliation` (
  `reconciliation_id` int(10) NOT NULL AUTO_INCREMENT,
  `protein_tree_id` int(10) NOT NULL,
  `species_tree_id` int(10) NOT NULL,
  `species_set_id` int(10) NOT NULL,
  PRIMARY KEY (`reconciliation_id`),
  KEY `reconciliation_id` (`reconciliation_id`),
  KEY `reconciliation_id_2` (`reconciliation_id`),
  KEY `species_tree_id` (`species_tree_id`),
  KEY `protein_tree_id` (`protein_tree_id`),
  KEY `protein_tree_id_2` (`protein_tree_id`),
  KEY `protein_tree_id_3` (`protein_tree_id`),
  KEY `reconciliation_id_3` (`reconciliation_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2541 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reconciliation_attribute`
--

DROP TABLE IF EXISTS `reconciliation_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reconciliation_attribute` (
  `reconciliation_attribute_id` int(10) NOT NULL AUTO_INCREMENT,
  `reconciliation_id` int(10) NOT NULL,
  `cvterm_id` int(10) NOT NULL,
  `value` text NOT NULL,
  `rank` smallint(3) NOT NULL DEFAULT '0',
  `source_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`reconciliation_attribute_id`),
  KEY `reconciliation_attribute_idx1` (`reconciliation_id`),
  KEY `reconciliation_attribute_idx2` (`cvterm_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5083 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reconciliation_node`
--

DROP TABLE IF EXISTS `reconciliation_node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reconciliation_node` (
  `reconciliation_node_id` int(10) NOT NULL AUTO_INCREMENT,
  `reconciliation_id` int(10) NOT NULL,
  `node_id` int(8) NOT NULL,
  `host_parent_node_id` int(10) DEFAULT NULL,
  `host_child_node_id` int(10) DEFAULT NULL,
  `is_on_node` tinyint(1) NOT NULL,
  PRIMARY KEY (`reconciliation_node_id`),
  KEY `host_child_node_id` (`host_child_node_id`),
  KEY `host_parent_node_id` (`host_parent_node_id`),
  KEY `is_on_node` (`is_on_node`)
) ENGINE=MyISAM AUTO_INCREMENT=50733 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sequence`
--

DROP TABLE IF EXISTS `sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sequence` (
  `sequence_id` int(10) NOT NULL AUTO_INCREMENT,
  `length` int(10) DEFAULT NULL,
  `sequence` longtext,
  PRIMARY KEY (`sequence_id`)
) ENGINE=MyISAM AUTO_INCREMENT=28510 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `species_tree`
--

DROP TABLE IF EXISTS `species_tree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `species_tree` (
  `species_tree_id` int(10) NOT NULL AUTO_INCREMENT,
  `species_tree_name` text,
  `root_node_id` int(10) DEFAULT NULL,
  `version` smallint(3) DEFAULT NULL,
  PRIMARY KEY (`species_tree_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `species_tree_attribute`
--

DROP TABLE IF EXISTS `species_tree_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `species_tree_attribute` (
  `species_tree_attribute_id` int(10) NOT NULL AUTO_INCREMENT,
  `species_tree_id` int(10) NOT NULL,
  `cvterm_id` int(10) NOT NULL,
  `value` text NOT NULL,
  `rank` smallint(3) NOT NULL DEFAULT '0',
  `source_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`species_tree_attribute_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This would be the place to store information like version, s';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `species_tree_node`
--

DROP TABLE IF EXISTS `species_tree_node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `species_tree_node` (
  `species_tree_node_id` int(10) NOT NULL AUTO_INCREMENT,
  `species_tree_id` int(10) NOT NULL,
  `parent_id` int(10) NOT NULL,
  `label` text,
  `left_index` int(10) NOT NULL,
  `right_index` int(10) NOT NULL,
  PRIMARY KEY (`species_tree_node_id`),
  KEY `species_tree_node_idx2` (`left_index`),
  KEY `species_tree_node_idx3` (`right_index`),
  KEY `species_tree_node_idx4` (`species_tree_id`),
  KEY `species_tree_node_idx5` (`parent_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2781 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `species_tree_node_attribute`
--

DROP TABLE IF EXISTS `species_tree_node_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `species_tree_node_attribute` (
  `species_tree_node_attribute_id` int(10) NOT NULL AUTO_INCREMENT,
  `species_tree_node_id` int(10) NOT NULL,
  `cvterm_id` int(10) NOT NULL,
  `value` text NOT NULL,
  `rank` smallint(3) NOT NULL DEFAULT '0',
  `source_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`species_tree_node_attribute_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `species_tree_node_path`
--

DROP TABLE IF EXISTS `species_tree_node_path`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `species_tree_node_path` (
  `species_tree_node_path_id` int(10) NOT NULL AUTO_INCREMENT,
  `parent_node_id` int(10) NOT NULL,
  `child_node_id` int(10) NOT NULL,
  `path` text NOT NULL,
  `distance` int(10) NOT NULL,
  PRIMARY KEY (`species_tree_node_path_id`)
) ENGINE=MyISAM AUTO_INCREMENT=80246 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-02-27 11:38:52
