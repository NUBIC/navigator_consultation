ENV['RACK_ENV'] = 'test'

require_relative '../server' # <-- your sinatra app
require 'rspec'
require 'capybara/rspec'
require 'rack/test'
require 'faraday'

class KayakoTest < Sinatra::Base
	set :counter, 0
#	set :db, SQLite3::Database.new(':memory:')
	
	get '/foo' do
		"<html><body>Success: #{settings.counter}</body></html>"
	end
	
	post '/foo' do
		settings.counter = settings.counter + 1
		redirect to('/foo')
	end
end

describe 'The Navigator Submission Form', :type => :feature do
	include Rack::Test::Methods
	
	before(:all) do
		Capybara.app = app
	end
	
	before(:each) do
		t = Thread.new do
			KayakoTest.run! :host => 'localhost', :port => 9876
		end
		Timeout.timeout(5) { t.join(0.1) until KayakoTest.running? }
	end
	
	after(:each) do
		KayakoTest.quit!
	end
	
	def app
		Sinatra::Application
	end
	
	it "talks to Kayako" do
		visit '/'
# file_name = save_page
# require "launchy"
# Launchy.open(File.expand_path(file_name))
fill_in 'firstname', :with => 'fred'
click_button 'Send Request'
kayako = Faraday.new(:url => 'http://0.0.0.0:9876').get('/foo').body
expect(kayako).to have_content 'Success: 1'
end
end