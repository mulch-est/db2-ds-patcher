#file editing functions
def replaceAscii(replace_filepath, replaced_ascii, new_ascii)
  asciireplace_filedata = File.binread(replace_filepath) #added bin
  asciireplace_newfiledata = asciireplace_filedata.gsub(replaced_ascii.to_s, new_ascii.to_s)
  #puts "Successfully replaced ascii data..."
  File.write(replace_filepath, asciireplace_newfiledata)
  puts "Successfully wrote new data to file..."
  #puts "--ASCII view--"
  #puts "#{asciireplace_newfiledata}"
end

def replaceHex(filepath, replaced_hex, new_hex)
    hexreplace_filedata = File.binread(filepath) #added bin
    hexreplace_newfiledata = hexreplace_filedata.gsub([replaced_hex].pack('H*'), [new_hex].pack('H*'))
    #puts "Successfully replaced hex data..."
    File.write(filepath, hexreplace_newfiledata)
    puts "Successfully wrote new data to file..."
    #puts "--ASCII view--"
    #puts "#{hexreplace_newfiledata}"
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
  puts "This will not make a copy! Please ensure you have an extra copy before proceeding!"
  ascii_file_edit_option = gets.chop

  if ascii_file_edit_option == "y" || ascii_file_edit_option == "Y"
    replaceAscii(rom_filepath, "buttonDebug", "button")
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
