ENV['PICKY_ENV'] = 'test'

require File.expand_path '../../../lib/picky', __FILE__

# Check Redis.
#
system('redis-cli quit') || fail('Redis must be running.')

# Prepare test DB.
#
# Note: I'm afraid the SQL path inside the .sql file is very specific.
#       Please change and rerun. And suggest a better solution, please :)
#
sql_file = File.expand_path '../../data/generate_test_db.sql', __FILE__
system("mysql --user developer -D picky_test_project < #{sql_file}") || fail("MySQL test data couldn't be inserted.")

Picky::Loader.load_application