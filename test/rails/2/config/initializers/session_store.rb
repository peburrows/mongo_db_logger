# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_logger_and_rails2_session',
  :secret      => '7c2319b2b268596a89acfe8e58e0cb87f52a13fbe2e29cc0ab26bf060fd8dc221887849b42dbc12bfffc587dc7746db08101b164bd821b6a38038a7b381206b4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
