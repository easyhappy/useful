require 'benchmark/ips'
def slow
    "foo" + "bar"
end

def fast
    "foo" "bar"
end

def append
  "foo" << "bar"
end

def another
  "%s%s" %["foo", "bar"]
end

Benchmark.ips do |x|
  x.report("slow") { slow { 1 + 1 } }
  x.report("fast") { fast { 1 + 1 } }
  x.report("append") { append { 1 + 1 } }
  x.report("another") { another { 1 + 1 } }

end
