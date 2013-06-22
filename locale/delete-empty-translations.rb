#!/usr/bin/env ruby

def exec(fin, fout)
  fin.each do |line|
    line.chop!
    if line =~ /\"\";$/
      STDERR.puts line
      fout.puts "/* #{line} */"
    else
      fout.puts line
    end
  end
end

ARGV.each do |file|
  STDERR.puts "=== Processing: #{file}"

  fin = File.open(file)
  fout = File.open(file + ".new", "w")

  exec(fin, fout)

  fin.close
  fout.close

  STDERR.puts

  File.rename(file, file + ".bak")
  File.rename(file + ".new", file)
end

