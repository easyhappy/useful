require 'active_record'
require 'pry'
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory"
)

#ActiveRecord::Base.connection.execute("CREATE TABLE users (name String, is_admin boolean)")
class User < ActiveRecord::Base
  attr_accessible :name, :as => :admin
  attr_accessible :name, :pis_admin, :as => :admin
end

user = User.new
user.assign_attributes({ :name => 'Josh', :is_admin => true })
binding.pry
user.name       # => "Josh"
user.is_admin?  # => false
puts user.is_admin?

user = User.new
user.assign_attributes({ :name => 'Josh', :is_admin => true }, :as => :admin)
user.name       # => "Josh"
user.is_admin?  # => true
puts user.is_admin?

user = User.new
user.assign_attributes({ :name => 'Josh', :is_admin => true }, :without_protection => true)
user.name       # => "Josh"
user.is_admin?  # => true
puts user.is_admin?

user = User.new({:name => 'jsoin', :is_admin => true})
puts user.name
puts user.is_admin
