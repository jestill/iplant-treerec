ALTER TABLE reconciliation ADD COLUMN reconciliation_set_id INT(10) NOT NULL;

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



-- add reconciliation information