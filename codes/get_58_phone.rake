#encoding: UTF-8
namespace :brss do
  desc "获取58用户手机号"
  task :get_58_phone_price => :environment do
    require 'nokogiri'
    require 'open-uri'
    require 'net/http'
    
    #网站首页
    WEB_URL = "http://bj.58.com/shouji/"
    RAILS_ROOT = Rails.root.to_s
    
    
    PROXY_LIST = [
      ["136.0.16.108", 7808],
      ["124.240.187.80", 82],
      ["125.39.66.153", 80],
      ["211.142.236.137", 80]
    ]
    
    def get_file(url, file_name)
       uri = URI.parse(URI.escape(url))
       http = Net::HTTP.new(uri.host, uri.port)
       
       http.get(url) do |str|
         img_file = File.new("#{file_name}","wb")
         img_file.write str
         img_file.close
        end
    end
    
    def get_http_body(url, use_proxy = false)
      begin
        uri = URI.parse(URI.escape(url))
        if use_proxy
          rand_proxy = PROXY_LIST[rand(4)]
          p "正在使用代理：#{rand_proxy}"
          web_proxy = Net::HTTP::Proxy(rand_proxy[0], rand_proxy[1])
          http = web_proxy.start(uri.host, uri.port)
        else
          http = Net::HTTP.new(uri.host, uri.port)
        end
        request = Net::HTTP::Get.new(uri.request_uri)  
        response = http.request(request)
        response.body
      rescue Timeout::Error
        puts "\e[31超时，挂代理重试\e[30m\n"
        use_proxy = true
        retry
      end
    end
    
    def post_http_body(url, params, use_proxy = false)
      begin
        uri = URI.parse(URI.escape(url))
        if use_proxy
          rand_proxy = PROXY_LIST[rand(4)]
          p "正在使用代理：#{rand_proxy}"
          web_proxy = Net::HTTP::Proxy(rand_proxy[0], rand_proxy[1])
          http = web_proxy.start(uri.host, uri.port)
        else
          http = Net::HTTP.new(uri.host, uri.port)
        end
        
        request = Net::HTTP::Post.new(uri.request_uri, {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:20.0) Gecko/20100101 Firefox/20.0', 
          'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          #'Accept-Encoding' => 'gzip, deflate',
          'Accept-Language' => 'zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3',
          'Connection' => 'keep-alive',
          'Cookie' => '_agc=1; __utma=27006125.162694603.1367462476.1367462476.1367462476.1; __utmb=27006125.3.9.1367462536333; __utmc=27006125; __utmz=27006125.1367462476.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)'
          })  
        request.set_form_data(params)
        response = http.request(request)
        response.body
      rescue Timeout::Error
        puts "\e[31超时，挂代理重试\e[30m\n"
        use_proxy = true
        retry
      rescue
        return nil
      end
    end
    
    def main
      phones = []
      index_body = Nokogiri::HTML(get_http_body("http://bj.58.com/shouji/"))
      #总手机数
      phone_count = index_body.css(".infocont span b").text.to_i
      current_index = 1
      #开始循环，如果内容没有下一页则到最后一页
      p "总共#{phone_count}条"
      for index in 1..100 do 
        p "第#{index}页"
        phone_list_body = Nokogiri::HTML(get_http_body("http://bj.58.com/shouji/#{index > 1 ? "pn#{index}/" : ""}"))
        #循环手机列表
        phone_list_body.css("#hoverinfo .tbimg").first.css("tr").each do |phone_tr|
          p "#{current_index} / #{phone_count}"
          title = phone_tr.css("a.t").first.text
          show_url = phone_tr.css("a.t").first.attr("href")
          price = phone_tr.css(".pri").text
          phone_show_body = Nokogiri::HTML(get_http_body(show_url))
          seller = phone_show_body.css(".tx:first").text
          tel = phone_show_body.css(".su_con #t_phone").text
          tel_img_url = phone_show_body.css(".f20 script").text.match(/http:\/\/[^\']*(?! )/)
          tel_img_url = tel_img_url[0] if tel_img_url.is_a?(MatchData)
          get_file(tel_img_url, "public/58phones/#{current_index}.gif") if tel_img_url.present?
          
          phones << [current_index, title, price, tel, show_url]

          current_index += 1
          p title
          p show_url
          p price
          p tel_img_url
          p "--------------"
          
        end
        break if phone_list_body.css(".next").blank? #没有下一页了
      end
      
      workbook = WriteExcel.new("public/58phones/phones.xls")
      worksheet  = workbook.add_worksheet
      # 定义一下标题格式
      format = workbook.add_format
      format.set_bold
      worksheet.write(0,0, %w(序号 标题 价格 手机号 地址) ,format)
      index = 1
      phones.each_with_index do |element, x|
       worksheet.write(x+1,0, element,format)
      end
      workbook.close
    end
    
    main()
  end
end
