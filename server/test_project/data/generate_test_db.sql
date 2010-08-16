DROP TABLE IF EXISTS books;

-- .schema test
CREATE TABLE books (
  id     integer      not null,
  title  varchar(100) not null,
  author varchar(100) not null,
  blurb  varchar(400) not null,
  isbn   varchar(10)  not null,
  year   number(4)    not null
);

.mode csv
.import data/books.csv books
