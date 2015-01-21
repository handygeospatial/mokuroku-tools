require 'open-uri'
require 'digest/md5'
require 'fileutils'
require 'zlib'

M = 10
stat = {true => 0, false => 0}
M.times {|residue|
  Zlib::GzipReader.open('mokuroku.csv.gz').each_line {|l|
    (path, date, size, md5) = l.strip.split(',')
    next unless path.split('/')[1].to_i % M == residue
    stat[File.exist?("#{path}") && Digest::MD5.file(path) == md5] += 1
    if rand(100) == 0
      sum = stat[true] + stat[false]
      print "#{(100.0 * stat[true] / sum).to_i}% downloaded in #{sum} (#{path}).\n"
    end
  }
}
