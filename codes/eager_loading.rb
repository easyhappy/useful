require 'rubygems'  
require 'faker'  
require 'active_record'  
require 'benchmark'  
 
# This call creates a connection to our database.  
 
ActiveRecord::Base.establish_connection(  
 :adapter  => "mysql",  
 :host     => "127.0.0.1",  
 :username => "tianji",     
 :password => "tianji",    
 :database => "andy")  

class Category < ActiveRecord::Base
end

unless Category.table_exists?
  ActiveRecord::Schema.define do
    create_table :categories do |t|
      t.column :name, :string
    end
  end
  puts 'Successful to create category table...'
end

#10.times.each do |i|
#  Category.create(:name => "name_#{i}").save
#end

number_of_categories = Category.count  
 
class Item <  ActiveRecord::Base   
 belongs_to :category   
end  
 
# If the table doesn't exist, we'll create it.  
 
unless Item.table_exists?  
 ActiveRecord::Schema.define do  
  create_table :items do |t|  
    t.column :name, :string  
    t.column :category_id, :integer   
  end  
 end   
end  
 
puts "Loading data..."  
 
item_count = Item.count  
item_table_size = 10000 
 
if item_count < item_table_size 
 (item_table_size - item_count).times do |i|
  begin_time = Time.now
  Item.create!(:name=>Faker.name,   
                 :category_id=>(1+rand(number_of_categories.to_i)))  
  puts "#{ item_count + i }cost: #{Time.now - begin_time}"
 end  
end  
 
puts "Running tests..."  
 
Benchmark.bm do |x|   
 [100,1000,10000].each do |size|   
  x.report "size:#{size}, with n+1 problem" do   
   @items=Item.limit(size)
   @items.each do |i|   
    i.category  
   end   
  end   
  x.report "size:#{size}, with :include" do   
   @items=Item.all.where(category_id:  true).limit(size)
   @items.each do |i|   
    i.category  
   end   
  end   
 end   
end 
