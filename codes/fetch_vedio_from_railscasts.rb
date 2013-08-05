#Fetch vedio from railscasts
require 'pry'

class FetchUrl
  attr_accessor :base_path
  attr_accessor :page_number

  def fetch(page_number)
    base_url = "http://railscasts.com/?page=#{page_number}"
    self.base_path = "hello/#{page_number}"
    self.page_number = page_number
    system("wget --tries=10 #{base_url} -O #{self.base_path} -o logs/#{page_number}")
  end

  def get_contents
   lines = ''
   File.open(self.base_path, 'r') do |file|
     while line = file.gets
       lines += line
     end
   end
   lines
  end

  def analyze_url
   page_contents = get_contents()
   screenshot_re = /(?<=screenshot).*(?=div)/ 
   urls = []
   matches = screenshot_re.match(page_contents)
   urls << get_url_info(matches[0])

   while(matches)
     matches = screenshot_re.match(matches.post_match)
     if matches
      urls << get_url_info(matches[0])
     end
   end
   urls
  end

  def get_url_info(url)
    info = []
    return info unless url
    info << get_url_href(url)
    info << get_url_name(url)
    info
  end

  def get_url_href(url)
    href_url = /(?<=href=\").*(?=\">)/
    return href_url.match(url)[0]
  end

  def get_url_name(url)
   href_name = /(?<=alt=\").*(?=\" height)/ 
   return href_name.match(url)[0]
  end
end

def fetch_vedio_and_codes(url, page_number)
  return if url.empty?
  resource_name = url[0].split('/')[-1]
  if resource_name.split('-')[0].length == 2
    resource_name = '0' + resource_name
  end
  if resource_name.split('-')[0].length == 1
    resource_name = '00' + resource_name
  end
  base_url = "http://railscasts.com#{url[0]}"

  #get_code_and_mp4_url(base_url, resource_name)

  target_dir = "vedio/#{page_number}/#{resource_name}"
  system("mkdir -p #{target_dir}")

  code_url = "http://media.railscasts.com/assets/episodes/sources/#{resource_name}.zip"
  mp4_url = "http://media.railscasts.com/assets/subscriptions/naTPo0xldxskaKS5YlofHg/videos/#{resource_name}.mp4"
  page_url = "http://railscasts.com/episodes/#{resource_name}"

  #system("echo #{code_url} >> #{target_dir}/#{resource_name}")
  #system("echo #{mp4_url} >> #{target_dir}/#{resource_name}")

  #system("wget --tries=10 #{code_url} -O #{target_dir}/#{resource_name}.zip -o logs/#{resource_name}")
  system("wget --tries=10 #{page_url} -O #{target_dir}/#{resource_name}.html -o logs/#{resource_name}")

  #system("wget --tries=10 #{mp4_url} -O #{target_dir}/#{resource_name}.mp4 -o logs/#{resource_name}")
  #if File.new("#{target_dir}/#{resource_name}.mp4").stat.size == 0
  #  mp4_url = "http://media.railscasts.com/assets/episodes/videos/#{resource_name}.mp4"
  #  system("echo #{mp4_url} >> #{target_dir}/#{resource_name}")
  #  system("wget --tries=10 #{mp4_url} -O #{target_dir}/#{resource_name}.mp4 -o logs/#{resource_name}")
  #end
end

(1...49).each do |i|
  fetch_url = FetchUrl.new
  fetch_url.fetch(i)
  urls = fetch_url.analyze_url()

  threads = []
  urls.each do |url|
    threads << Thread.new { fetch_vedio_and_codes(url, fetch_url.page_number) }
  end
  threads.each { |t| t.join}
end


def check_file_count(page_number)
  base_dir = "vedio/#{page_number}"
  count = 0
  Dir.glob("#{base_dir}/*").each do |dir|
    Dir.glob("#{dir}/*") do |file|
			puts file if File.new(file).stat.size == 0
      count += 1
    end
  end
  puts "files count of #{page_number} is #{count}"
end

(1...49).each do |i|
  check_file_count(i)
end
