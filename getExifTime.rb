require './ExifInformationLoader'
require 'time'

loader=ExifInformationLoader.new()
exif=loader.load(ARGV[0])

puts(exif.dateTimeOriginal.strftime("%Y%m%d"))
