ENV['PICKY_ENV'] = 'test'

require File.expand_path '../../../lib/picky', __FILE__

Picky::Loader.load_application