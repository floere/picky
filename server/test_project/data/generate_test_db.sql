-- Postgres
--
-- > createdb picky_test_project
-- > psql -d picky_test_project < /Users/admin/temp/picky/server/test_project/data/generate_test_db.sql

DROP TABLE IF EXISTS books;

CREATE TABLE books (
  id        SERIAL PRIMARY KEY,
  title     TEXT       NOT NULL,
  author    TEXT       NOT NULL,
  isbn      TEXT       NOT NULL,
  year      DECIMAL(4) NOT NULL,
  publisher TEXT           NULL,
  category  TEXT           NULL
);

BEGIN;
  COPY books (id, title, author, isbn, year, publisher, category) FROM '/Users/admin/temp/picky/server/test_project/data/books.csv' WITH (FORMAT csv, HEADER false);
  SELECT setval('books_id_seq', max(id)) FROM books; -- Since we explicitly set IDs, we need to update serial (last ID inserted).
END;