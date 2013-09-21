# coding: utf-8

require 'active_support/callbacks'
require 'pry'

class Record
  include ActiveSupport::Callbacks
  define_callbacks :save

  def save
    run_callbacks :save do
      puts "- save"
    end
  end

  set_callback :save, :before, :saving_message
  def saving_message
    puts "before save 1"
    #return false
  end

  set_callback :save, :after do |object|
    puts "after save 1"
  end

  set_callback :save, :before, :hello
  def hello
    puts 'before save 2'
  end

  set_callback :save, :after do |object|
    puts 'after save 2'
  end

end

r = Record.new
r.save
r._save_callbacks.map do |c|
  puts c.to_s
end

puts r._save_callbacks.to_s
