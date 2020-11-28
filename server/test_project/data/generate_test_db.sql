-- Postgres
--
-- > createdb picky_test_project
-- > psql -d picky_test_project < /Users/admin/temp/picky/server/test_project/data/generate_test_db.sql

DROP TABLE IF EXISTS books;

CREATE TABLE books (
  id        INTEGER,
  title     TEXT       NOT NULL,
  author    TEXT       NOT NULL,
  isbn      TEXT       NOT NULL,
  year      DECIMAL(4) NOT NULL,
  publisher TEXT       NOT NULL,
  category  TEXT       NOT NULL,
  
  PRIMARY KEY(id)
);

COPY books (id, title, author, isbn, year, publisher, category) FROM '/Users/admin/temp/picky/server/test_project/data/books.csv' WITH (FORMAT csv, HEADER false);