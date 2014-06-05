require 'sinatra'
require 'sqlite3'

class KayakoFakeServer < Sinatra::Base
  configure do
    enable :logging
  end

  set :server, 'thin'
  set :db, SQLite3::Database.new(':memory:')
  set :credentials_valid, true

  get '/api/index.php' do
    if params[:e] != '/Tickets/Ticket/ListAll'
      error 401 do
        'Unsupported Operation'
      end
    end
    
    create_db

    settings.db.results_as_hash = true
    tickets = settings.db.execute('select * from tickets')

    erb = ERB.new(%Q{
      <% tickets.each do |t| %>
        <div>
          <ul>
            <li>Subject: <%= t['subject'] %></li>
            <li>Full Name: <%= t['fullname'] %></li>
            <li>Email: <%= t['email'] %></li>
            <li>Contents: <%= t['contents'] %></li>
          </ul>
        </div>
      <% end %>
    })

    erb.result(binding)
  end

  post '/api/index.php' do
    # logger = Logger.new('log/development.log')

    if params[:e] != '/Tickets/Ticket'
      error 401 do
        'Unsupported Operation'
      end
    end

    required = %w(subject fullname email contents departmentid ticketstatusid ticketpriorityid tickettypeid)
    missing_required = required - params.keys
    if missing_required.any?
      error 401, "Missing required argument(s): #{missing_required}"
    end

    either = %w(autouserid userid staffid)
    if (params.keys & either).empty?
      error 401, "Missing either argument(s): #{either}"
    end

    if !settings.credentials_valid
      error 401, "Credentials invalid"
    end

    found_either = either.detect { |k| !params[k].nil? }

    create_db

    stmt = settings.db.prepare(%q{
      INSERT INTO tickets
      (subject, fullname, email, contents, departmentid, ticketstatusid, ticketpriorityid, tickettypeid, autouserid, userid, staffid)
      VALUES
      (:subject, :fullname, :email, :contents, :departmentid, :ticketstatusid, :ticketpriorityid, :tickettypeid, :autouserid, :userid, :staffid)
    })

    to_insert = params.select{ |k,v| required.include?(k) }.merge(found_either => params[found_either])
    logger.info "Inserting data: #{to_insert}"
    stmt.execute(to_insert)
    content_type 'text/xml'
    %Q{
      <?xml version="1.0" encoding="UTF-8"?>
      <tickets>
        <ticket id="1" flagtype="0">
            <displayid>OLJ-171-16930</displayid>
            <departmentid>#{params['departmentid']}</departmentid>
            <statusid>#{params['ticketstatusid']}</statusid>
            <priorityid>#{params['ticketpriorityid']}</priorityid>
            <typeid>#{params['tickettypeid']}</typeid>
            <userid>#{params['autouserid']}</userid>
            <ownerstaffid>#{params['autouserid']}</ownerstaffid>
            <fullname>#{params['fullname']}</fullname>
            <email>#{params['email']}</email>
            <subject>#{params['subject']}</subject>
        </ticket>
      </tickets>
    }
  end

  def create_db
    logger.info "Creating table: tickets"
    settings.db.execute(%q{
      CREATE TABLE IF NOT EXISTS tickets (
        id integer NOT NULL,
        subject text NOT NULL,
        fullname text NOT NULL,
        email text NOT NULL,
        contents text NOT NULL,
        departmentid integer NOT NULL,
        ticketstatusid integer NOT NULL,
        ticketpriorityid integer NOT NULL,
        tickettypeid integer NOT NULL,
        autouserid integer,
        userid integer,
        staffid integer,
        PRIMARY KEY(id)
      )
    })
  end
end