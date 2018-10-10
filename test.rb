class ExifInformation

	class Endian
		BigEndian=">"
		LittleEndian="<"
	end

end


puts("Nyaan")

fp=File.open("C:\\shared\\135_0308\\IMGP4473.JPG","rb")

#APP1の先頭へ移動
bytes=fp.read(2)

while bytes.unpack("S>")[0]!=Integer("0xFFE1")
	puts(bytes.unpack("S>"))
	bytes=fp.read(2)
end

puts(bytes.unpack("S>"))

#セグメント長、Exif識別子を捨てる
fp.seek(8,IO::SEEK_CUR)

#offset開始位置を記憶
offsetStart=fp.pos

#エンディアンを決定
bytes=fp.read(2)
puts(bytes.unpack("S>"))
endian=nil

if bytes.unpack("S>")[0]==Integer("0x4D4D") then
	endian=ExifInformation::Endian::BigEndian
elsif bytes.unpack("S>")[0]==Integer("0x4949") then
	endian=ExifInformation::Endian::LittleEndian
else
#例外？
end

puts(endian)


#TIFFバージョンの読み捨て
fp.seek(2,IO::SEEK_CUR)

#0th IFDのオフセット取得
bytes=fp.read(4)

puts(bytes.unpack("S"+endian)[0])

#0th IFDの位置へ
fp.seek(offsetStart+bytes.unpack("S"+endian)[0],IO::SEEK_SET)
bytes=fp.read(2)

puts(bytes.unpack("S"+endian)[0])

#Exif IFDへのポインタ取得
loop do
	bytes=fp.read(2)
	break if bytes.unpack("S"+endian)[0]==Integer("0x8769")
	fp.seek(10,IO::SEEK_CUR)
end

fp.seek(6,IO::SEEK_CUR)
bytes=fp.read(4)

puts("X:"+(bytes.unpack("S"+endian)[0].to_s))

#Exif IFDの先頭へ移動
fp.seek(offsetStart+bytes.unpack("S"+endian)[0],IO::SEEK_SET)
bytes=fp.read(2)
puts(bytes.unpack("S"+endian)[0])

#Exifタグのループ
loop do
	bytes=fp.read(2)
#	puts(bytes.unpack("S"+endian)[0])
	break if bytes.unpack("S"+endian)[0]==Integer("0x9003")
	fp.seek(10,IO::SEEK_CUR)
end

puts(bytes.unpack("S"+endian)[0])

#タグの中身を料理
#typeはとりあえずスルー
fp.seek(2,IO::SEEK_CUR)

bytes=fp.read(4)
length=bytes.unpack("S"+endian)[0]

puts(length)

bytes=fp.read(4)
fp.seek(offsetStart+bytes.unpack("S"+endian)[0],IO::SEEK_SET)

str=fp.read(length)
puts(str)

fp.close

#終了コード


