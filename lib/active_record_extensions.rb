
files = Dir.glob(File.dirname(__FILE__) + "/**/*.rb")
files.each do |file|
  require file
end

