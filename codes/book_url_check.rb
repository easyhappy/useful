new_urls = []
urls = []
new_file = File.new("/home/andy/backup/books_url.txt")
new_file.each do |line|
  new_urls << line.strip
end
new_file = File.new("/home/andy/backup/new_books_url.txt")
new_file.each do |line|
  urls << line.strip
end

puts urls.size
urls.uniq!
puts urls.size
