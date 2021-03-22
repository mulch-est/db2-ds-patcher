=begin
TODO:
-add language-unlocker functionality using editBySub
=end

require './modules'

#menu functions
def one(rom_filepath)
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
    
    menu(rom_filepath)
  elsif ascii_file_edit_option == "n" || ascii_file_edit_option == "N" #non-header auto ascii replace
    menu(rom_filepath)
  else
    "Recieved an invalid answer (#{ascii_file_edit_option}), needs to be (Y) or (N)"
    one(rom_filepath)
  end
end

def two(rom_filepath)
  puts "function not yet implemented"
  
  menu(rom_filepath)
end

def askFile()
	#get rom_filepath
	puts "Please enter the filepath of your [legally obtained] rom (ie db2ds.nds)"
	rom_filepath = gets.chop

	#open file and begin patch
	if File.exists?(rom_filepath)
		rom_filechars = File.size(rom_filepath)
		puts "Opened #{File.basename(rom_filepath)} [#{rom_filechars} bytes]"
		menu(rom_filepath)
		
	#file could not be opened
	else
		puts "Your file at (#{rom_filepath}) could not be located. Please try again"
		askFile()
	end
end

def menu(rom_filepath)
	printMenu()
	getMenu(rom_filepath)
end

def getMenu(rom_filepath)
	#get input, then execute chosen option
  edit_option = gets.chop
  if edit_option == "1"
    one(rom_filepath)
  elsif edit_option == "2"
    two(rom_filepath)
  elsif edit_option == "H" || edit_option == "h"
    printHelp()
	getMenu(rom_filepath)
  else
    puts "Are you sure you want to quit? (Y)"
    quit_confirm = gets.chop
    if quit_confirm == "y" || quit_confirm == "Y"
      puts "Exited the program"
    else
      menu(rom_filepath)
    end
  end
end

def printMenu()
	puts "Press 1 to apply Splash Screen Skip patch"
	#puts "Press 2 to X"
	puts "Press H to get more info"
	puts "Press any other button to quit"
end

def printHelp()
  puts "1. Splash Screen Skip patch:"
  puts "Allows users to skip splash screens by pressing L instead of waiting"
  puts "H. Repeat this help dialogue"
  puts "Else. Quit Program"
end

#program
puts "Booted patcher."
#add warnings?
askFile()
