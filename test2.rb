require './ExifInformationLoader'
require 'time'

loader=ExifInformationLoader.new()
exif=loader.load("C:\\shared\\135_0308\\IMGP4473.JPG")

puts(exif.dateTimeOriginal.strftime("%Y%m%d"))
