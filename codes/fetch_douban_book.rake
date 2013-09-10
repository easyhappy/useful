#encoding: UTF-8
require 'typhoeus'
require 'nokogiri'
require 'pry'
require 'csv'

class Book
  attr_accessor :category
  attr_accessor :url
  attr_accessor :name
  attr_accessor :lpic
  attr_accessor :mpic
  attr_accessor :author
  attr_accessor :weight

  def initialize(category, url)
    self.url = url
    self.category = category
  end

  def to_array
    [name, category, author, weight, url, lpic, mpic]
  end
end

class FetchHandler
  def initialize(urls)
    @urls = urls
    @csv_file = CSV.open("/home/andy/Documents/tianjicom/book.csv", 'wb:UTF-8', {:col_sep => "|||"})
  end

  def dump_to_file(book)
    @csv_file.add_row(book.to_array)
  end

  def get_text(body, selector)
    item = body.at_css(selector) 
    if item
      item.text
    else
      ''
    end
  end

  def analyze_book_detail(category, response)
    book = Book.new(category, response.effective_url)

    new_body = Nokogiri::HTML(response.body)
    book.name = new_body.at_css("#wrapper h1 span").text
    book.name = get_text(new_body, "#wrapper h1 span")
    book.author = get_text(new_body, "#info span a")
    book.mpic = new_body.at_css("#mainpic a img")[:src]
    book.lpic = new_body.at_css("#mainpic a")[:href]
    book.weight = get_text(new_body, ".font_normal span a span")
    book
  end

  def analyze_next_page(next_page)
    return unless next_page
    request = generate_request(URI.escape("http://book.douban.com" + next_page)) do |response|
      analyze_book_list(response)
    end
    Typhoeus::Hydra.hydra.queue request
    Typhoeus::Hydra.hydra.run
  end

  def analyze_book_list(response)
    book_urls = []
    new_body = Nokogiri::HTML(response.body) 
    new_body.css(".info h2 a").each do |link|
      book_urls << link[:href]
    end

    return if book_urls.empty?

    category = new_body.at_css("#content h1").text.to_s.split(":")[-1].strip
    book_urls.each do |url|
      request = generate_request(url) do |response|
        book = analyze_book_detail(category, response)
        dump_to_file(book)
      end
      Typhoeus::Hydra.hydra.queue request
      Typhoeus::Hydra.hydra.run
    end

    next_page = new_body.at_css(".next a")[:href]
    analyze_next_page(next_page)
  end

  def generate_request(url, &block)
    request = Typhoeus::Request.new(url)
    request.on_complete do |response|
      if response.code == 200
        block.call(response) if block_given?
      end
      sleep 1
    end
    request
  end

  def run
    hydra = Typhoeus::Hydra.new(max_concurrency: 1)
    @urls.each do  |url|
      request = generate_request(url) do |response|
        analyze_book_list(response)
      end
      hydra.queue request
    end
    hydra.run
  end
end

def main
  url = 'http://book.douban.com/tag/?view=type'
  fetch_handler = FetchHandler.new(url)
  fetch_handler.run
end

main
