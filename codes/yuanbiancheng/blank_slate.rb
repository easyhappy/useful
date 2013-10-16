class C
  def method_missing(name, *args)
    "a Ghost method"
  end
end


o = C.new
puts o.to_s


class C
  instance_methods.each do |m|
    undef_method m unless m.to_s =~ /method_missing|respond_to?|^/
  end
end
o = C.new
puts o.to_s
