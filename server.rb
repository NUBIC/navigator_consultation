require 'sinatra'
require 'kayako_client'
require 'bcdatabase'

# Configuration
require_relative "config/#{settings.environment}.rb"

#give the form to user
get '/' do
 send_file 'form.html'
end

post '/' do
  full_name = %w(firstname lastname).map{ |k| params[k] }.compact.join(' ')
  email = params['email']
  contents = "Phone: #{params['phone']}\nInterests: #{params['interest'].join(';')}\nComments: #{params['comments']}"

  ticket = KayakoClient::Ticket.new(
    :department_id => 14,
    :status_id     => 1,
    :priority_id   => 1,
    :type_id       => 1,
    :subject       => "Consultation request from #{full_name}",
    :contents      => contents
    )

  # Set user details
  ticket.full_name    = full_name
  ticket.email        = email
  ticket.auto_user_id = true

  # Post ticket
  ticket.post
end

#post form contents to kayako rest api
#Server will need traversal to Kayako to hit API

#Action:submit

#Post form contents to Kayako api
#'Create new ticket' in 'NUCATS Navigator' Queue
#fullname = First name + Last name 
#email = email
#Subject = Consultation request from fullname

# Redirect user back to 'Thank you' page on NUCATS site

