# coding: utf-8
require 'zlib'
require 'action_view'
include ActionView::Helpers::NumberHelper

def show(dict)
  dict.each {|z, h|
    count_big_tiles = h[:hist].select{|k, v| k >= 100}.values.reduce(:+) || 0
    max_size = h[:hist].keys.max
    print <<-EOS
z=#{z}
合計 #{h[:count]}タイル、#{number_to_human_size(h[:size])}
平均 #{number_to_human_size(h[:size] / h[:count])}
100 KBを越えるタイルの個数 #{count_big_tiles} (#{(100.0 * count_big_tiles / h[:count]).to_i}%)
最大タイルサイズ #{number_to_human_size(max_size * 1024)}

    EOS
  }
end

dict = Hash.new {|h, k| h[k] = {
  :count => 0, :hist => Hash.new {|h, k| h[k] = 0}, :size => 0
                 }}

Zlib::GzipReader.open('mokuroku.csv.gz').each_line {|l|
  (path, date, size, md5) = l.strip.split(',')
  size = size.to_i
  (z, x, y) = path.split('.')[0].split('/').map{|v| v.to_i}
  dict[z][:count] += 1
  dict[z][:size] += size
  dict[z][:hist][size / 1024] += 1
  show dict if dict[z][:count] % 10000 == 0
}
show dict
  
