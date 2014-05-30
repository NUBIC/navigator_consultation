require 'kayako_client'
require 'awesome_print'

# Configuration
KayakoClient::Base.configure do |config|
    config.api_url    = '***REMOVED***'
    config.api_key    = '***REMOVED***'
    config.secret_key = '***REMOVED***'
end

#Department id=14
#TicketStatus id=1
#TicketPriority id=1
#TicketType id=1

ticket = KayakoClient::Ticket.new(
    :department_id => 14,
    :status_id     => 1,
    :priority_id   => 1,
    :type_id       => 1,
    :subject       => 'Example ticket subject',
    :contents      => 'Example ticket details.'
)
 
# Set user details
ticket.full_name    = 'John Doe'
ticket.email        = 'foo@example.com'
ticket.auto_user_id = true
 
# Post ticket
ticket.post
