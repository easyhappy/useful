#encoding: UTF-8
require 'logger'
require 'uri'
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
  def initialize(url, tags)
    @logger = Logger.new(STDOUT)
    @tags = tags
    @url = url
    @csv_file = CSV.open("/home/andy/backup/book_check.csv", 'wb:UTF-8', {:col_sep => "|||"})
  end

  def dump_to_file(book)
    @new_books_url_file.write(book.url + "\n")
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
      next if @able_urls.include?(url)
      request = generate_request(url) do |response|
        begin
          book = analyze_book_detail(category, response)
          dump_to_file(book)
        rescue Exception => e
          @logger.info(__LINE__.to_s + url + e.inspect)
        end
      end
      Typhoeus::Hydra.hydra.queue request
      Typhoeus::Hydra.hydra.run
    end

    next_page = new_body.at_css(".next a")
    unless next_page == nil
      next_page = new_body.at_css(".next a")[:href]
      analyze_next_page(next_page)
    end
  end

  def check_url(url)
    book_urls = [url]
    book_urls.each do |url|
      request = generate_request(url) do |response|
        begin
          category = '创业'
          book = analyze_book_detail(category, response)
          dump_to_file(book)
        rescue Exception => e
          @logger.info(__LINE__.to_s + url + e.inspect)
        end
      end
      Typhoeus::Hydra.hydra.queue request
      Typhoeus::Hydra.hydra.run
    end
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

  def generate_urls_list_by_tags
    @urls = @tags.map do |tag|
      "http://book.douban.com/tag/%s" % tag.strip
    end
  end

  def generate_able_urls
    url_file = File.new('/home/andy/backup/books_url.txt')
    @able_urls = url_file.map do |line|
      line.strip
    end

    url_file = File.new('/home/andy/backup/new_books_url.txt')
    @able_urls += url_file.map do |line|
      line.strip
    end
    @new_books_url_file = File.new('/home/andy/backup/new_books_url.txt', 'a')
  end

  def generate_success_tags
    file_path = "/home/andy/backup/success_tag.txt"
    url_file = File.new(file_path)
    @success_tags = url_file.map do |line|
      line.strip
    end

    @success_tags_file = File.new(file_path, 'a')
  end

  def run
    generate_urls_list_by_tags
    generate_able_urls
    generate_success_tags
    @urls.each do  |url|
      next if @success_tags.include?(url)
      hydra = Typhoeus::Hydra.new(max_concurrency: 1)
      request = generate_request(URI.escape(url)) do |response|
        begin
          analyze_book_list(response)
        rescue Exception => e
          @logger.info(__LINE__.to_s + url + e.inspect)
        end
      end
      hydra.queue request
      hydra.run
      @success_tags_file.write(url + "\n")
    end
  end
end

def main
  tags = %w(小说
            外国文学
            文学
            中国文学
            社会
            人文
            随笔
            科技
            营销
            商业
            创业
            中国历史
            科学
            人物传记
            科普
            戏剧
            广告
            绘画
            艺术史
            投资
            互联网
            交互设计
            用户体验
            交互
            金融
            理财
            企业史
            web
            策划
            股票
            程序
            UCD
            通信
            编程
            UE
            神经网络
            算法
            管理)
  url = 'http://book.douban.com/tag/?view=type'
  fetch_handler = FetchHandler.new(url, tags)
  fetch_handler.run
end

main
