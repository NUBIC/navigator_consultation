ENV['RACK_ENV'] = 'test'

require_relative '../server'  # <-- your sinatra app
require 'rspec'
require 'capybara/rspec'
require 'rack/test'
require 'support/kayako_fake_server.rb'
require 'faraday'

describe 'The Navigator Submission Form', :type => :feature do
  include Rack::Test::Methods

  before(:all) do
    Capybara.app = app
  end

  before(:each) do
    Timeout.timeout(5) do 
      t = Thread.new do
        KayakoFakeServer.run! :host => kayako_uri.host, :port => kayako_uri.port
      end
    
      t.join(0.1)
    end
  end

  after(:each) do
    KayakoFakeServer.quit!
  end

  let(:kayako_uri) { URI("http://0.0.0.0:9876") }
  let(:kayako_client) { Faraday.new(:url => kayako_uri) }

  def app 
    Sinatra::Application
  end

  it "talks to Kayako" do
    visit '/'

    fill_in('firstname', :with => 'Fred')
    fill_in('lastname', :with => 'Flintstone')
    fill_in('phone', :with => '312-456-7890')
    fill_in('email', :with => 'fred@flintstone.com')

    check('interest_community')
    check('interest_informatics')
    check('interest_other')

    click_button('Send Request')

    kayako_client.get('/api/index.php?e=/Tickets/Ticket/ListAll').body.tap do |b|
      expect(b).to have_content('Subject: Consultation request from Fred Flintstone')
      expect(b).to have_content('Full Name: Fred Flintstone')
      expect(b).to have_content('Email: fred@flintstone.com')
      expect(b).to have_content('Contents: Phone: 312-456-7890 Interests: Community-Engaged Research;Biomedical Informatics;Other Comments:')
    end
  end
end
