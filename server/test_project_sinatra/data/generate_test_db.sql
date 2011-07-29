# MySQL data
#
# On Florian's local computer:
# mysql --user developer -D picky_test_project < /Users/admin/temp/picky/server/test_project/data/generate_test_db.sql
#
DROP TABLE IF EXISTS books;

CREATE TABLE books (
  id     integer      not null,
  title  varchar(100) not null,
  author varchar(100) not null,
  isbn   varchar(10)  not null,
  year   decimal(4)   not null
);

LOAD DATA INFILE '/Users/admin/temp/picky/server/test_project/data/books.csv'
  INTO TABLE books
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
    LINES TERMINATED BY '\n';
