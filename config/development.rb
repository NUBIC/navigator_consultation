require 'bcdatabase'

b = Bcdatabase.load

KayakoClient::Base.configure do |config|
  config.api_url    = b['kayako_test', 'api']['url']
  config.api_key    = b['kayako_test', 'api']['key']
  config.secret_key = b['kayako_test', 'api']['secret']
end