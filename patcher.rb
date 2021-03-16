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
    replaceHex(rom_filepath, "buttonDebug".unpack('H*')[0], "button     ".unpack('H*')[0])
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
#menu()

#replace="      "
#infile = File.binread("db2-original.nds")
#infile = File.open("","")
outfile = "db2_out.nds"
contfile = "db2_control.nds"
outfile_data = ""
count = 0

def truncate(string, max)
  string.length > max ? "#{string[0...max]}..." : string
end

#corrected version with leading 0s

def bin_to_hex(s)
  #s.each_byte.map { |b| "%02x" % b.to_i }.join
  s.unpack('H*')[0]
  #[s].pack("B*").unpack("H*")[0]#.first
end

#does not fix -1KiB issue
def hex_to_bin(s)
  #s.scan(/../).map { |x| x.hex.chr }.join
  #[s].pack('H*')
end

data = nil

puts "reading..."
File.open("db2-original.nds", "rb") do |file|
#file.chomp!
  data = file.read
end

puts "unpacking..."
#hex_data = data.unpack('H*')[0]
control_data = bin_to_hex(data)

puts "#{truncate(control_data, 500)}"

puts "packing..."
#outfile_data = [hex_data.gsub("buttonDebug".unpack('H*')[0], "button     ".unpack('H*')[0])].pack('H*')
control_data = [control_data].pack('H*')

#outfile_data = data.gsub("<buttonDebug", "<button     ")
=begin
data = File.open("file", 'rb' ) {|io| io.read}.unpack("C*").map do |val| 
  val if val == 44
	puts "44"
end

=begin
File.open("db2-original.nds", "rb") do |f|
  f.each_line do |line|
	count = count+1
    outfile_data = "#{outfile_data}#{line.gsub("<buttonDebug", "<button     ")}"
	print "processed #{count} lines \r"
  end
end
=end

puts "fixing..."
#replace all 0d 0a pairs with 0a because of a windows newline quirk

converted = nil

#File.write('mid.bin', control_data)
#this function is extremely slow
=begin
File.open('converted.nds', 'wb') do |converted|
  File.open('mid.bin', 'rb').each_line do |line|
    converted << line.gsub("\r\n", "\n") # Replace CRLF with LF
  end
end
=end

#tf = Tempfile.new('modbin') #delete removes null-byte errors
#tf = control_data.delete("\u0000")

File.write('mid.bin', control_data)

File.open('converted.nds', 'wb') do |converted|
  File.open('mid.bin', 'rb').each_line do |line|
  #control_data.each_line do |line|
    converted << line.gsub("\r\n", "\n") # Replace CRLF with LF
  end
end

puts "finishing..."
#tf.close
#tf.unlink
#File.write(contfile, control_data)

puts "Successfully wrote new data to file..."
