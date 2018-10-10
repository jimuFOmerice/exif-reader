class ExifInformation

	class Endian
		BigEndian=">"
		LittleEndian="<"
	end

end


puts("Nyaan")

fp=File.open("C:\\shared\\135_0308\\IMGP4473.JPG","rb")

#APP1�̐擪�ֈړ�
bytes=fp.read(2)

while bytes.unpack("S>")[0]!=Integer("0xFFE1")
	puts(bytes.unpack("S>"))
	bytes=fp.read(2)
end

puts(bytes.unpack("S>"))

#�Z�O�����g���AExif���ʎq���̂Ă�
fp.seek(8,IO::SEEK_CUR)

#offset�J�n�ʒu���L��
offsetStart=fp.pos

#�G���f�B�A��������
bytes=fp.read(2)
puts(bytes.unpack("S>"))
endian=nil

if bytes.unpack("S>")[0]==Integer("0x4D4D") then
	endian=ExifInformation::Endian::BigEndian
elsif bytes.unpack("S>")[0]==Integer("0x4949") then
	endian=ExifInformation::Endian::LittleEndian
else
#��O�H
end

puts(endian)


#TIFF�o�[�W�����̓ǂݎ̂�
fp.seek(2,IO::SEEK_CUR)

#0th IFD�̃I�t�Z�b�g�擾
bytes=fp.read(4)

puts(bytes.unpack("S"+endian)[0])

#0th IFD�̈ʒu��
fp.seek(offsetStart+bytes.unpack("S"+endian)[0],IO::SEEK_SET)
bytes=fp.read(2)

puts(bytes.unpack("S"+endian)[0])

#Exif IFD�ւ̃|�C���^�擾
loop do
	bytes=fp.read(2)
	break if bytes.unpack("S"+endian)[0]==Integer("0x8769")
	fp.seek(10,IO::SEEK_CUR)
end

fp.seek(6,IO::SEEK_CUR)
bytes=fp.read(4)

puts("X:"+(bytes.unpack("S"+endian)[0].to_s))

#Exif IFD�̐擪�ֈړ�
fp.seek(offsetStart+bytes.unpack("S"+endian)[0],IO::SEEK_SET)
bytes=fp.read(2)
puts(bytes.unpack("S"+endian)[0])

#Exif�^�O�̃��[�v
loop do
	bytes=fp.read(2)
#	puts(bytes.unpack("S"+endian)[0])
	break if bytes.unpack("S"+endian)[0]==Integer("0x9003")
	fp.seek(10,IO::SEEK_CUR)
end

puts(bytes.unpack("S"+endian)[0])

#�^�O�̒��g�𗿗�
#type�͂Ƃ肠�����X���[
fp.seek(2,IO::SEEK_CUR)

bytes=fp.read(4)
length=bytes.unpack("S"+endian)[0]

puts(length)

bytes=fp.read(4)
fp.seek(offsetStart+bytes.unpack("S"+endian)[0],IO::SEEK_SET)

str=fp.read(length)
puts(str)

fp.close

#�I���R�[�h


