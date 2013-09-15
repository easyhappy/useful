require 'mini_magick'
require 'pry'

def test_1
  image = MiniMagick::Image.open("/home/andy/Pictures/3.png")
  image.resize "100x100"
  image.write  "output.png"
end

def compose_picture(pic_name)
  base_path = "/home/andy/Pictures/"
  base_pic = base_path + "base.png"

  pic = base_path + pic_name
  first_image = MiniMagick::Image.open(base_pic)
  first_image.resize "2000x2000"

  second_image = MiniMagick::Image.open(pic)
  second_image.resize "200x200"
  new_image = first_image.composite(second_image) do |c|
    c.geometry "#{yield}"
  end
  new_image.combine_options do |i|
    i.pointsize 92
    i.fill 'red'
    i.font 'Candice'
    #i.draw "fill red font Candice text 200, 200 'wo shi xiaobei'"
    i.draw "text 200, 200 'wo shi xiaobei'"
  end
  puts new_image.write base_path + "base.png"
end

def test_2
  w_shift = 0
  h_shift = 0
  (1...2).each do |i|
    #binding.pry
    if (i%10) == 0
      w_shift = 9*200
    else
      w_shift = (i%10-1)*200
    end
    h_shift = (i-1)/10*200
    compose_picture("#{i%2}.png") do
     "+#{w_shift}+#{h_shift}"
    end
  end
end

test_2
