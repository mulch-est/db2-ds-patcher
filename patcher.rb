$windows_mode

#modules
module Patcher
	#edits rom by substitution, maintaining exact file size
	#rom_filepath: string containing the path to the file which should already have been validated
	#replaced_data: ascii string data to replace in the rom
	#new_data: ascii string data to substitute into the rom
	def self.editBySub(rom_filepath, replaced_data, new_data)
		#checks to make sure replaced and new data are the same size (otherwise the rom becomes corrupted)
		if replaced_data.length == new_data.length
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

			if $windows_mode
				puts "applying windows-specific fix..." #replace all 0d 0a pairs with 0a because of a windows newline quirk

				File.open(patchfile_name, 'wb') do |converted|
					File.open('mid.bin', 'rb').each_line do |line|
						converted << line.gsub("\r\n", "\n") # Replace CRLF with LF
					end
				end
			else
				File.open(patchfile_name, 'wb') do |patched|
					File.open('mid.bin', 'rb').each_line do |mid|
						patched << mid
					end
				end
			end

			#rom_filepath_patched should now contain a file of equal size to rom_filepath
			#with the changes instructed by replaced_data, new_data
			patch_filechars = File.size(patchfile_name)
			puts "fin: #{File.basename(patchfile_name)} [#{patch_filechars} bytes]"
		else
			puts "editBySub() received unusable data (different lengths error)"
			puts "Process aborted"
		end
	end
end

#menu functions
def one()
	#get filepath
  	puts "Please enter the filepath of your [legally obtained] rom (ie db2ds.nds)"
  	rom_filepath = gets.chop

	#open file and begin patch
	if File.exists?(rom_filepath)
		rom_filechars = File.size(rom_filepath)
		puts "Opened #{File.basename(rom_filepath)} [#{rom_filechars} bytes]"

		one_exec(rom_filepath)
	#file could not be opened
	else
		puts "Your file at (#{rom_filepath}) could not be located. Please try again"
		one()
	end
end

def one_exec(rom_filepath)
	puts "Are you sure you want to apply the Splash Screen Skip patch? Y/N"
	ascii_file_edit_option = gets.chop

  	if ascii_file_edit_option == "y" || ascii_file_edit_option == "Y"

		#62 75 74 74 6F 6E 44 65 62 75 67 --> 62 75 74 74 6F 6E 20 20 20 20 20
		Patcher::editBySub(rom_filepath, "buttonDebug", "button     ")
    
		#in the xml menu files for de blob 2 (DS) there are four splash screens
		#these screens were able to be skipped during debugging by pressing L

		#this is referenced by the code:
		#<widget type="button">
		#  <buttonDebug key="L" />
		#  <item menu="Menus\NEXT_MENU.xml" timer="240" quickLoad="true" menuDontStore="true" selectable="false"/>
		#</widget>
		#which can be found within each splash screen
    
    		menu()
  	elsif ascii_file_edit_option == "n" || ascii_file_edit_option == "N" #non-header auto ascii replace
    		menu()
  	else
		puts "Recieved an invalid answer (#{ascii_file_edit_option}), needs to be (Y) or (N)"
		one_exec(rom_filepath)
	end
end

def two()
  	puts "function not yet implemented"
  
  	menu()
end

def help()
	puts "1. Splash Screen Skip patch:"
	puts "Allows users to skip splash screens by pressing L instead of waiting"

	menu()
end

def windows_check()
	puts "Are you running this patcher on Windows? (Y)"
	
	entry = gets.chop
	if entry == "y" || entry == "Y"
		$windows_mode = true
		puts "Running in windows mode..."
	else
		$windows_mode = false
		puts "The patcher will not apply windows-specific fixes."
	end
end
	

#Main function
def menu()
	#Display program options
	puts "Press 1 to apply Splash Screen Skip patch"
	#puts "Press 2 to X"
	puts "Press H to get more info"
	puts "Press any other button to quit"

	#get input, then execute chosen option
	edit_option = gets.chop
  	if edit_option == "1"
    		one()
  	elsif edit_option == "2"
    		two()
  	elsif edit_option == "H" || edit_option == "h"
    		help()
  	else
		puts "Exited the program"
	end
end

#program
puts "Booted patcher."
#add warnings?
windows_check()
menu()
