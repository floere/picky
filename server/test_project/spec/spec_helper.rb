ENV['PICKY_ENV'] = 'test'

require_relative '../../lib/picky'

# Check Redis.
#
system('redis-cli quit') || fail('Redis must be running. Run redis-server in a terminal.')

# Prepare test DB.
#
# Note: I'm afraid the SQL path inside the .sql file is very specific.
#       Please change and rerun. And suggest a better solution, please :)
#
sql_file = File.expand_path '../data/generate_test_db.sql', __dir__
system("psql -d picky_test_project < #{sql_file}") ||
  fail("Postgres test data couldn't be inserted. See #{sql_file} for infos.")

Picky::Loader.load_application