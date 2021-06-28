require 'csv'
require 'sequel'

require_relative 'config'

script_dir = File.dirname(__FILE__)

sqlite_db = Sequel.connect("sqlite://#{script_dir}/wifi-location.sqlite3")
postgres_db = Sequel.connect("postgres://#{CONFIG['postgres_user']}:#{CONFIG['postgres_password']}@#{CONFIG['postgres_host']}/#{CONFIG['postgres_db']}")

postgres_db.transaction do
  postgres_db.drop_table?(:raw_locations, cascade: true)
  postgres_db.create_table(:raw_locations) do
    Integer :id, primary_key: true
    Float :lat
    Float :lon
    Float :horizontal_accuracy, index: true
    Time :timestamp, index: true
  end

  locations_rows = sqlite_db[:locations].all
  postgres_db[:raw_locations].multi_insert(locations_rows)
end
