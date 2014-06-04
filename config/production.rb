require 'bcdatabase'

b = Bcdatabase.load

KayakoClient::Base.configure do |config|
  config.api_url    = b['kayako_prod', 'api']['url']
  config.api_key    = b['kayako_prod', 'api']['key']
  config.secret_key = b['kayako_prod', 'api']['secret']
end