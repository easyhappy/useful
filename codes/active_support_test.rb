require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter       => "mysql2",
  :username      => "tianji",
  :password      => "tianji",
  :db            => "tianji"
)

class Book < ActiveRecord::Base
end

count = 0
File.new("/home/andy/backup/book.csv").each do |line|
  splits = line.split("|||")
  h = {}
  h[:name] = splits[0]
  h[:author] = splits[2]
  h[:url] = splits[4]
  h[:lpic_url] = splits[5]
  h[:mpic_url] = splits[6]
  Book.create(h)

  count += 1
  if count > 10
    break
  end
end

