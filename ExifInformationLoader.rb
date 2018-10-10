require './ExifInformation'
require "time"

class ExifInformationLoader

	module Endian
		BigEndian=">"
		LittleEndian="<"
	end

	module TagID
		DATE_TIME_ORIGINAL=Integer("0x9003")
	end

	module DataType
		BYTE=1
		ASCII=2
		SHORT=3
		LONG=4
		RATIONAL=5
		UNDEFINED=7
		SLONG=9
		SRATIONAL=10
	end

	def load(fname)
		@fp=File.open(fname,"rb")

		@exif=ExifInformation.new()
		@exif.fileName=File.basename(fname)

		#APP1の先頭へ移動
		bytes=@fp.read(2)
		
		while bytes.unpack("S>")[0]!=Integer("0xFFE1")
			bytes=@fp.read(2)
		end
		
		#セグメント長、Exif識別子を捨てる
		@fp.seek(8,IO::SEEK_CUR)
		
		#offset開始位置を記憶
		@offsetStart=@fp.pos
		
		#エンディアンを決定
		bytes=@fp.read(2)
		@endian=decideEndian(bytes)
		
		#TIFFバージョンの読み捨て
		@fp.seek(2,IO::SEEK_CUR)

		#0th IFDのオフセット取得
		bytes=@fp.read(4)

		#0th IFDの位置へ
		@fp.seek(@offsetStart+bytes.unpack("S"+@endian)[0],IO::SEEK_SET)
		bytes=@fp.read(2)

		#Exif IFDへのポインタ取得
		loop do
			bytes=@fp.read(2)
			break if bytes.unpack("S"+@endian)[0]==Integer("0x8769")
			@fp.seek(10,IO::SEEK_CUR)
		end
		
		#Exif IFDタグのtype(2byte), count(4byte)読み捨て
		@fp.seek(6,IO::SEEK_CUR)
		
		#Exif IFDのオフセット取得
		bytes=@fp.read(4)

		#Exif IFDの先頭へ移動
		@fp.seek(@offsetStart+bytes.unpack("S"+@endian)[0],IO::SEEK_SET)
		
		#Exifタグのループ
		makeExifInfomation
		
		@fp.close
		
		return @exif
		
	end

	private
	
	def decideEndian(bytes)
		endian=nil
		if bytes.unpack("S>")[0]==Integer("0x4D4D") then
			endian=Endian::BigEndian
		elsif bytes.unpack("S>")[0]==Integer("0x4949") then
			endian=Endian::LittleEndian
		else
			#例外？
		end
		
		return endian
		
	end

	def makeExifInfomation
		numOfTags=@fp.read(2).unpack("S"+@endian)[0]
		numOfTags.times do |i|
			tagNumber=@fp.read(2).unpack("S"+@endian)[0]
			value=readOneTag
			setExifValue(tagNumber,value)
			@fp.seek(4,IO::SEEK_CUR)
		end
	end
	
	def readOneTag
		type=getFpValue(2)
		case type
			when DataType::ASCII then
				return getAsciiValue
			else
				@fp.seek(4,IO::SEEK_CUR)
				return ""
		end	
	end

	def setExifValue(tagNumber,value)
		case tagNumber
			when TagID::DATE_TIME_ORIGINAL then
				@exif.dateTimeOriginal=Time.parse(makeTimeString(value))
		end
	end

	def getAsciiValue
		count=getFpValue(4)
		offset=@offsetStart+getFpValue(4)
		tempFp=@fp
		tempFp.seek(offset,IO::SEEK_SET)
		value=tempFp.read(count)
		return value.chop()
	end
	
	def getFpValue(length)
		return @fp.read(length).unpack("S"+@endian)[0]
	end
	
	# yyyy:mm:ddをyyyy/mm/ddに
	def makeTimeString(value)
		value[4]="/"
		value[7]="/"
		return value
	end
	
end
