require 'active_support'
require 'pry'

class Audit
  def before(caller)
    puts 'Audit: before is called'
  end

  def before_save(caller)
    puts 'Audit: before_save is called'
  end

  def save(caller)
    puts "Audit: save is called"
  end
end

class Account
  include ActiveSupport::Callbacks

  define_callbacks :save
  define_callbacks :save, :scope => [:kind, :name]
  define_callbacks :save, :scope => [:name]
  set_callback :save, :before, Audit.new

  def save
    run_callbacks :save do
      puts 'save in main'
    end
  end
end

a = Account.new
a.save
binding.pry
