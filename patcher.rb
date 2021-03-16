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
  puts "This will not make a copy! Please ensure you have an extra copy before proceeding!"
  ascii_file_edit_option = gets.chop

  if ascii_file_edit_option == "y" || ascii_file_edit_option == "Y"
    data = nil

	puts "reading..."
	File.open(rom_filepath, "rb") do |file|
	  data = file.read
	end
	
	puts "unpacking..."
	control_data = data.unpack('H*')[0]
	
	puts "patching..."
	#62 75 74 74 6F 6E 44 65 62 75 67 to 62 75 74 74 6F 6E 20 20 20 20 20
	puts "(#{"buttonDebug".unpack('H*')[0]} --> #{"button     ".unpack('H*')[0]})"
	patchdata = control_data.gsub("buttonDebug".unpack('H*')[0], "button     ".unpack('H*')[0])
	
	puts "packing..."
	control_data = [control_data].pack('H*')
	patchdata = [patchdata].pack('H*')
	
	puts "fixing..."
	#replace all 0d 0a pairs with 0a because of a windows newline quirk
	File.write('mid.bin', control_data)
	File.write('pat.bin', patchdata)

	File.open('control.nds', 'wb') do |converted|
	  File.open('mid.bin', 'rb').each_line do |line|
	  #control_data.each_line do |line|
		converted << line.gsub("\r\n", "\n") # Replace CRLF with LF
	  end
	end
	
	File.open('converted.nds', 'wb') do |converted|
	  File.open('pat.bin', 'rb').each_line do |line|
	  #control_data.each_line do |line|
		converted << line.gsub("\r\n", "\n") # Replace CRLF with LF
	  end
	end
    
    #in the xml menu files for de blob 2 (DS) there are four splash screens
    #these screens were able to be skipped during debugging by pressing L
    
    #this is referenced by the code:
    #<widget type="button">
    #  <buttonDebug key="L" />
    #  <item menu="Menus\NEXT_MENU.xml" timer="240" quickLoad="true" menuDontStore="true" selectable="false"/>
    #</widget>
    #which can be found within each splash screen
    
    rom_filechars = File.size(rom_filepath)
    puts "now: #{File.basename(rom_filepath)} [#{rom_filechars} bytes]"
    
    menu()
  elsif ascii_file_edit_option == "n" || ascii_file_edit_option == "N" #non-header auto ascii replace
    menu()
  else
    "Recieved an invalid answer (#{ascii_file_edit_option}), needs to be (Y) or (N)"
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
    puts "Are you sure you want to quit? (Y)"
    quit_confirm = gets.chop
    if quit_confirm == "y" || quit_confirm == "Y"
      puts "Exited the program"
    else
      menu()
    end
  end
end

#program
puts "Booted patcher."
#add warnings?
menu()
