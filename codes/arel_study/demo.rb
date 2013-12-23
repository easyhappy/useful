require 'active_record'
require 'arel'
require 'mysql'
require 'pry'

ActiveRecord::Base.establish_connection(
  :adapter => :mysql,
  :host    => '127.0.0.1',
  :username => 'tianji',
  :password => 'tianji',
  :database => 'tianji'
)
Arel::Table.engine = Arel::Sql::Engine.new(ActiveRecord::Base)
@users = Arel::Table.new(:users)
binding.pry
