#encoding: UTF-8
require 'logger'
require 'uri'
require 'typhoeus'
require 'nokogiri'
require 'pry'
require 'csv'

class Request < Typhoeus::Request
  def original_on_complete=(proc)
    @original_on_complete = proc
  end
    
  def original_on_complete
    @original_on_complete
  end
    
  def get_on_complete
    @on_complete
  end
    
  def retries=(retries)
    @retries = retries
  end
  
  def retries
    @retries ||= 0
  end
end

class FetchHandler
  def initialize()
    @logger = Logger.new(STDOUT)
    @success_file = File.open("/home/andy/backup/success_file", 'a')
    @output_base_url = '/home/andy/backup/douban_book_comments'
  end

  def dump_to_file(url)
    book_id = url.split("/")[4]
    @book_directory = [@output_base_url, book_id].join('/')
    FileUtils.mkdir_p(@book_directory)

    tags_file = File.open(@book_directory + '/tags', 'w')
    @key_words.each do |word|
      tags_file.write(word + "\n")
    end
    tags_file.close

    url_file = File.open(@book_directory + '/url', 'w')
    url_file.write(url)
    url_file.close

    @comments.each_with_index do |comment, index|
      comments_file = File.open(@book_directory + "/comments_#{index}", 'w')
      comments_file.write(comment)
      comments_file.close
    end
  end

  def get_text(body, selector)
    item = body.at_css(selector)
    if item
      item.text
    else
      ''
    end
  end

  def analyze_book(response)
    new_body = Nokogiri::HTML(response.body)
    @key_words = get_key_words(new_body)
    get_comments(new_body, response.request.url)
  end

  def get_comments(new_body, url)
    begin
      more_url = "http://book.douban.com/subject/#{url.split("/")[4]}/reviews"
      if more_url
        hydra = Typhoeus::Hydra.new(max_concurrency: 1)
        request = generate_request(URI.escape(more_url)) do |response|
          begin
            new_body = Nokogiri::HTML(response.body)
          rescue Exception => e
            @success_flag = false
            @logger.info(__LINE__.to_s + more_url + e.inspect)
          end
        end
        hydra.queue request
        hydra.run
      end
    rescue Exception => e
      @success_flag = false
      @logger.info(__LINE__.to_s + url + e.inspect)
    end

    @comments = []
    new_body.css(".nlst h3 div").each do |review|
      return if @comments.size > 8
      url = "http://book.douban.com/review/" + review.attributes['id'].value.split('-')[-1] + "/"
      fetch_comment url
    end
  end

  def fetch_comment(url)
    hydra = Typhoeus::Hydra.new(max_concurrency: 1)
      request = generate_request(URI.escape(url)) do |response|
        begin
          analyze_comment(response)
        rescue Exception => e
          @success_flag = false
          @logger.info(__LINE__.to_s + url + e.inspect)
        end
      end
    hydra.queue request
    hydra.run
  end

  def analyze_comment(response)
    new_body = Nokogiri::HTML(response.body)
    @comments << new_body.at_css("#link-report span").text
  end

  def get_key_words(body)
    key_words = []
    body.at_css("#db-tags-section .indent").children.each do |child|
      text = child.text.strip
      key_words << text.split('(')[0] if text.include?('(')
    end
    key_words
  end

  def generate_request(url, &block)
    request = Request.new(url)
    request.on_complete do |response|
      if response.code == 200
        block.call(response) if block_given?
      else
        puts response.code
        puts url
      end
      if response.code == 0 and response.request.retries < 10
        response.request.retries +=1
        hydra = Typhoeus::Hydra.new(max_concurrency: 1)
        hydra.queue response.request
        hydra.run
      end
      if response.request.retries >= 10 and response.code == 0
        @success_flag = false
      end
      sleep 2
    end
    request
  end

  def generate_urls_list
    url_file = File.new('/home/andy/backup/books_url.txt')
    @urls = url_file.map do |line|
      line.strip
    end
  end

  def generate_success_urls
    url_file = File.new('/home/andy/backup/success_file')
    @success_urls = url_file.map do |line|
      line.strip
    end
    url_file.close
  end  

  def run
    generate_urls_list
    generate_success_urls
    puts @urls.size
    @urls.each do  |url|
      next if @success_urls.include?(url)
      @success_flag = true
      hydra = Typhoeus::Hydra.new(max_concurrency: 1)
      request = generate_request(URI.escape(url)) do |response|
        begin
          analyze_book(response)
        rescue Exception => e
          @success_flag = false
          @logger.info(__LINE__.to_s + url + e.inspect)
        end
        if @success_flag
          @success_file.write(url + "\n")
          dump_to_file url
        end
      end
      hydra.queue request
      hydra.run
    end
  end
end

def main
  fetch_handler = FetchHandler.new
  fetch_handler.run
end

main
