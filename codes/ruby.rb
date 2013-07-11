require 'net/http'

pages = %w( www.rubycentral.com baidu.com www.weibo.com)
  threads = []
for page in  pages
  threads << Thread.new(page) do |url|
    h = Net::HTTP.new(url , 80)
    puts "Fecching: #{url}"
    resp = h.get('/',nil)
    puts "Got #{url} :#{resp.message}"
  end
end


threads.each do |thr|
  thr.join
end


