require 'bcdatabase'

b = Bcdatabase.load

KayakoClient::Base.configure do |config|
  config.api_url    = 'http://0.0.0.0:9876/api/index.php?'
  config.api_key    = 'TEST_KEY'
  config.secret_key = 'TEST_SECRET'
end