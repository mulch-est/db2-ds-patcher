module Patcher
	#edits rom by substitution, maintaining exact file size
	#takes three strings: filepath, and replaced_data, new_data which are converted to hex
	def self.editBySub(rom_filepath, replaced_data, new_data)
	
		#check to make sure replaced and new data are the same size
		if(replaced_data.length != new_data.length)
			puts "err: editBySub received data that would change filesize"
		else
			
			data = nil

			puts "reading..." #read data from file, stored in data
			File.open(rom_filepath, "rb") do |file|
			  data = file.read
			end
			
			puts "unpacking..." #convert binary file data to hex, stored in hex_data
			hex_data = data.unpack('H*')[0]
			
			puts "patching..." #execute the replacement defined by function parameters, and store in patch_data
			puts "(#{replaced_data.unpack('H*')[0]} --> #{new_data.unpack('H*')[0]})"
			patch_data = hex_data.gsub(replaced_data.unpack('H*')[0], new_data.unpack('H*')[0])
			
			puts "packing..." #converts modified hex file data back to binary, stored in bin_data
			bin_data = [patch_data].pack('H*')
			
			File.write('mid.bin', bin_data) #store bin_data [without this step ~1 KiB of data is lost?]
			patchfile_name = "#{File.basename(rom_filepath, ".nds")}_patched.nds" #setup outfile name
			
			puts "fixing..." #replace all 0d 0a pairs with 0a because of a windows newline quirk
			
			File.open(patchfile_name, 'wb') do |converted|
			  File.open('mid.bin', 'rb').each_line do |line|
				converted << line.gsub("\r\n", "\n") # Replace CRLF with LF
			  end
			end
			
			#rom_filepath_patched should now contain a file of equal size to rom_filepath
			#with the changes instructed by replaced_data, new_data
			patch_filechars = File.size(patchfile_name)
			puts "fin: #{File.basename(patchfile_name)} [#{patch_filechars} bytes]"
			
		end
	end
end
