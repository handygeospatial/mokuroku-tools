require 'open-uri'
require 'digest/md5'
require 'fileutils'
require 'zlib'

Zlib::GzipReader.open('mokuroku.csv.gz').each_line {|l|
  next unless rand(1) == 0
  (path, date, size, md5) = l.strip.split(',')
  url = "http://cyberjapandata.gsi.go.jp/xyz/std/#{path}"
  next unless (8..15).include?(path.split('/')[0].to_i)
  if File.exist?("#{path}") && Digest::MD5.file(path) == md5
    print "skipped #{url}.\n"
    next
  end
  buf = open(url).read
  buf_md5 = Digest::MD5.hexdigest(buf)
  if md5 != buf_md5
    print <<-EOS
different MD5: #{url}
  #{md5}, #{size}B for mokuroku
  #{buf_md5}, #{buf.size}B from the web
    EOS
    if File.exist?(path)
      FileUtils.rm(path)
      print "deleted #{path}.\n"
    end
  end
  [File.dirname(path)].each{|it|
    FileUtils.mkdir_p(it) unless File.directory?(it)
  }
  File.open("#{path}", 'w') {|w| w.print buf}
  print "Downloaded #{path}#{'.' * (buf.size / 1000)}\n"
  #sleep rand(3)
}
