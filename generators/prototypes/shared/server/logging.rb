# Separate file since this is usually what is
# environment specific.
# (But go ahead and place the code in app.rb if you wish)
#

# Picky loggers log into IO or Logger instances.
#
# For example:
# Picky.logger = Picky::Loggers::Concise.new STDOUT
# Picky.logger = Picky::Loggers::Concise.new Logger.new('log/search.log')
#

Picky.logger = Picky::Loggers::Concise.new STDOUT