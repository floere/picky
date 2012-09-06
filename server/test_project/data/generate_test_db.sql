# MySQL data
#
# > mysql -u root
# CREATE USER developer@localhost;
# CREATE DATABASE picky_test_project;
# GRANT ALL ON picky_test_project.* TO developer@localhost;
#
# On Florian's local computer:
# mysql --user developer -D picky_test_project < /Users/hanke/temp/picky/server/test_project/data/generate_test_db.sql
#
DROP TABLE IF EXISTS books;

CREATE TABLE books (
  id     integer      NOT NULL AUTO_INCREMENT,
  title  varchar(100) NOT NULL,
  author varchar(100) NOT NULL,
  isbn   varchar(10)  NOT NULL,
  year   decimal(4)   NOT NULL,
  PRIMARY KEY (id)
);

LOAD DATA INFILE '/Users/hanke/temp/picky/server/test_project/data/books.csv'
  INTO TABLE books
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
    LINES TERMINATED BY '\n';
