def padEnd(input)
  ""+input+" "
end

def padTo(num, input)
  if input.length > num
    while input.length > num
      input = input.chop
    end
    return input
  elsif input.length < num
    while input.length < num
      input = input + " "
    end
    return input
  else
    return input
  end
end

def hexPadTo(num, input)
  puts "num:#{num}, nwn:#{num.to_i(16)},"#{"}" int:#{num.unpack('H*')[0].to_i}"
  num = num.to_i(16)
  num = num * 2

  if input.length > num
    while input.length > num
      puts input.length
      input = input.chop.chop
    end
    return [input].pack('H*')
  elsif input.length < num
    while input.length < num
      puts "#{input.length}, #{input}"
      input = input + "20"
    end
    return [input].pack('H*')
  else
    return [input].pack('H*')
  end
end

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

def ascii_header_menu(filepath, header_filepath, headers, replace_header)
  if headers.include? replace_header
    replace_index = -1
    headers.each { |i|
      replace_index = replace_index + 1
      if i == replace_header
        break
      end
    }
    #puts "Replacing dialogue ##{replace_index}"
    #go through dialogue, match one to header, and get character limit from it's "spacer tag"
    log_data = File.binread(filepath) #doesn't stop at 1A on Windows if using binread
    logs = []
    log_heads = []
    charlims = []
    last_i = ""
    last_ii = ""
    last_it = ""
    curr_log = ""
    curr_loghead = ""
    collecting_log = 0
    collecting_loghead = 5

    # do last i, last last i to make sure you are getting 00 XX(!00) 00 XX(!00) 00
    #copy-paste begins
    log_data.split("").each do |i| #iterates over each character in log_data
      if i.unpack('H*')[0] == "00" && collecting_log > 0
        curr_log.slice!(0, 1) #easily removes the u/0000 that starts each dialogue otherwise
        logs.push(curr_log)
        curr_log=""
        collecting_log = 0
      end
      if i.unpack('H*')[0] == "00"
        if last_i == "00"
          curr_loghead = ""
        elsif curr_loghead == "" && collecting_log == 0
          collecting_loghead = 5
        end
      end
      if last_i == "00" && i.unpack('H*')[0] != "00" && curr_loghead.length == 2
        charlims.push((i.unpack('H*')[0]).to_i(16))
      end
      if last_i != "00" && i.unpack('H*')[0] == "00" && curr_loghead.length == 8
        collecting_log=5
        collecting_loghead=0
        curr_log=""
        curr_loghead=""
      end
      last_it = last_ii
      last_ii = last_i
      if collecting_loghead > 0
        last_i = i.unpack('H*')[0]
        curr_loghead = curr_loghead + i.unpack('H*')[0]
      elsif collecting_log > 0
        last_i = i
        curr_log = curr_log + i
      end
      #puts "i:#{i}, curr_loghead:#{curr_loghead}, curr_log:#{curr_log}, col_l:#{collecting_log}, col_lh:#{collecting_loghead}"
    end
    #puts "log_heads: #{log_heads}" #blank?
    #puts "charlims: #{charlims}"
    #puts "logs: #{logs}"
    #copy-paste ends
    puts "Please enter the dialogue you would like to substitute for the dialogue in #{replace_header}"
    puts "Limit is #{charlims[replace_index]} chars, enter less: excess is padded with spaces, enter more: excess is deleted"
    new_ascii = gets.chop

    puts "Replacing dialogue in (#{replace_header}) in #{File.basename(filepath)} with (#{new_ascii}) [#{new_ascii.length} chars], is this ok?  (Y)"
    ascii_replace_confirmation = gets.chop

    if ascii_replace_confirmation == "y" || ascii_replace_confirmation == "Y"
      #puts replace_index
      replaceAscii(filepath, logs[replace_index], padTo(charlims[replace_index], new_ascii))
      puts "Replaced #{logs[replace_index]} with #{padTo(charlims[replace_index], new_ascii)}"
      puts "Press 1 to continue working with the same command and header files"
      puts "Press 2 to continue replacing cameos, but change files"
      puts "Press any other button to return to the menu"
      cont_choice = gets.chop
      if cont_choice == "1"
        one_dialogue(filepath, header_filepath) #add more ops?
      elsif cont_choice == "2"
        one()
      else
        edOps()
      end
    else
      puts "Replacement was not confirmed: (#{ascii_replace_confirmation}). Booted to menu."
      edOps()
    end
  else
    "Invalid header: (#{replace_header}). Please try again by entering one from the list."
    ascii_header_menu(filepath, header_filepath, headers, gets.chop)
  end
end

def ascii_header_replace_menu(filepath, header_filepath)
  if File.exists?(header_filepath)
    header_filechars = File.size(header_filepath)
    puts "Opened #{File.basename(header_filepath)} [#{header_filechars} bytes]"

    header_data = File.binread(header_filepath) #doesn't stop at 1A on Windows if using binread
    headers = []
    # do last i, last last i to make sure you are getting 0X_0X_X*X_0X
    last_i = ""
    last_ii = ""
    last_it = ""
    curr_head = ""
    collecting_header = 0
    #puts header_data
    header_data.split("").each do |i| #iterates over each character in header_data
      if i == "0"
        if curr_head == ""
          collecting_header = 5
        elsif last_i == "_" && last_it != "0"
          collecting_header = 2
        end
      end
      if last_ii == "0" && i != "_" && curr_head.length == 2
        collecting_header=0
        curr_head=""
      end
      last_it = last_ii
      last_ii = last_i
      last_i = i
      if collecting_header > 0
        curr_head = curr_head + i
        if collecting_header == 1 || collecting_header == 2
          if !headers.include? curr_head
            collecting_header = collecting_header - 1
            if collecting_header == 0
              headers.push(curr_head)
              curr_head=""
            end
          end
        end
      end
      #puts "i:#{i}, curr_head:#{curr_head}"
    end
    puts "Listed below are all possible dialogue headers found in this chapter"
    puts headers
    puts "Please enter the header of the dialogue you would like to change (ie. 01_01_BLOT_01)"
    replace_header = gets.chop
    ascii_header_menu(filepath, header_filepath, headers, replace_header)
  else
    puts "Your file at (#{header_filepath}) could not be located. Please try again"
    ascii_header_replace_menu(filepath, gets.chop)
  end
end

def hex_header_menu(filepath, header_filepath, headers, replace_header)
  if headers.include? replace_header
    replace_index = -1
    headers.each { |i|
      replace_index = replace_index + 1
      if i == replace_header
        break
      end
    }
    #puts "Replacing dialogue ##{replace_index}"
    #go through dialogue, match one to header, and get character limit from it's "spacer tag"
    log_data = File.binread(filepath) #doesn't stop at 1A on Windows if using binread
    logs = []
    log_heads = []
    charlims = []
    last_i = ""
    last_ii = ""
    last_it = ""
    curr_log = ""
    curr_loghead = ""
    collecting_log = 0
    collecting_loghead = 5

    # do last i, last last i to make sure you are getting 00 XX(!00) 00 XX(!00) 00
    #copy-paste begins
    log_data.split("").each do |i| #iterates over each character in log_data
      if i.unpack('H*')[0] == "00" && collecting_log > 0
        curr_log.slice!(0, 1) #easily removes the u/0000 that starts each dialogue otherwise
        logs.push(curr_log)
        curr_log=""
        collecting_log = 0
      end
      if i.unpack('H*')[0] == "00"
        if last_i == "00"
          curr_loghead = ""
        elsif curr_loghead == "" && collecting_log == 0
          collecting_loghead = 5
        end
      end
      if last_i == "00" && i.unpack('H*')[0] != "00" && curr_loghead.length == 2
        charlims.push((i.unpack('H*')[0]))
      end
      if last_i != "00" && i.unpack('H*')[0] == "00" && curr_loghead.length == 8
        collecting_log=5
        collecting_loghead=0
        curr_log=""
        curr_loghead=""
      end
      last_it = last_ii
      last_ii = last_i
      if collecting_loghead > 0
        last_i = i.unpack('H*')[0]
        curr_loghead = curr_loghead + i.unpack('H*')[0]
      elsif collecting_log > 0
        last_i = i
        curr_log = curr_log + i
      end
      #puts "i:#{i}, curr_loghead:#{curr_loghead}, curr_log:#{curr_log}, col_l:#{collecting_log}, col_lh:#{collecting_loghead}"
    end
    #puts "log_heads: #{log_heads}" #blank?
    #puts "charlims: #{charlims}"
    #puts "logs: #{logs}"
    #copy-paste ends
    puts "Please enter the hex you would like to substitute for the hex in #{replace_header}"
    puts "Limit is #{charlims[replace_index]} chars (hex), enter less: excess is padded with spaces, enter more: excess is deleted"
    new_hex = gets.chop

    puts "Replacing hex in (#{replace_header}) in #{File.basename(filepath)} with (#{new_hex}) [#{new_hex.length.to_s(16)} chars (hex)], is this ok?  (Y)"
    hex_replace_confirmation = gets.chop

    if hex_replace_confirmation == "y" || hex_replace_confirmation == "Y"
      #puts replace_index
      replaceHex(filepath, logs[replace_index].unpack('H*')[0], hexPadTo(charlims[replace_index], new_hex).unpack('H*')[0])
      puts "Replaced #{logs[replace_index].unpack('H*')[0]} with #{hexPadTo(charlims[replace_index], new_hex).unpack('H*')[0]}"
      puts "Press 1 to continue working with the same command and header files"
      puts "Press 2 to continue replacing cameos, but change files"
      puts "Press any other button to return to the menu"
      cont_choice = gets.chop
      if cont_choice == "1"
        three_dialogue(command_filepath, header_filepath)
      elsif cont_choice == "2"
        three()
      else
        edOps()
      end
    else
      puts "Replacement was not confirmed: (#{hex_replace_confirmation}). Booted to menu."
      edOps()
    end
  else
    "Invalid header: (#{replace_header}). Please try again by entering one from the list."
    hex_header_menu(filepath, header_filepath, headers, gets.chop)
  end
end

def hex_header_replace_menu(filepath, header_filepath)
  if File.exists?(header_filepath)
    header_filechars = File.size(header_filepath)
    puts "Opened #{File.basename(header_filepath)} [#{header_filechars} bytes]"

    header_data = File.binread(header_filepath) #doesn't stop at 1A on Windows if using binread
    headers = []
    # do last i, last last i to make sure you are getting 0X_0X_X*X_0X
    last_i = ""
    last_ii = ""
    last_it = ""
    curr_head = ""
    collecting_header = 0
    #puts header_data
    header_data.split("").each do |i| #iterates over each character in header_data
      if i == "0"
        if curr_head == ""
          collecting_header = 5
        elsif last_i == "_" && last_it != "0"
          collecting_header = 2
        end
      end
      if last_ii == "0" && i != "_" && curr_head.length == 2
        collecting_header=0
        curr_head=""
      end
      last_it = last_ii
      last_ii = last_i
      last_i = i
      if collecting_header > 0
        curr_head = curr_head + i
        if collecting_header == 1 || collecting_header == 2
          if !headers.include? curr_head
            collecting_header = collecting_header - 1
            if collecting_header == 0
              headers.push(curr_head)
              curr_head=""
            end
          end
        end
      end
      #puts "i:#{i}, curr_head:#{curr_head}"
    end
    puts "Listed below are all possible dialogue headers found in this chapter"
    puts headers
    puts "Please enter the header of the dialogue you would like to change (ie. 01_01_BLOT_01)"
    replace_header = gets.chop
    hex_header_menu(filepath, header_filepath, headers, replace_header)
  else
    puts "Your file at (#{header_filepath}) could not be located. Please try again"
    hex_header_replace_menu(filepath, gets.chop)
  end
end

def six_confirm(command_filepath, header_filepath, picked_header, picked_cameo, headers)
  replace_index = -1
  headers.each { |i|
    replace_index = replace_index + 1
    if i == picked_header
      break
    end
  }
  #puts "got replace_index of #{replace_index}"
  command_data = File.binread(command_filepath) #doesn't stop at 1A on Windows if using binread

  spacers = []
  last_i = ""
  last_ii = ""
  last_it = ""
  curr_spacer = ""
  collect = 1
  num = 0
  command_new_data = "";
  # do last i, last last i to make sure you are getting 00 XX(!00) 00 XX(!00) 00
  command_data.split("").each do |i| #iterates over each character in command_data
    command_new_data = command_new_data + i;
    if i.unpack('H*')[0] == "00"
      if last_i == "00"
        curr_spacer = ""
      end
    end
    if i.unpack('H*')[0] != "00"
      if last_i != "00"
        curr_spacer = ""
        collect = 0
      end
    end
    if last_it != "00" && last_ii == "00" && last_i != "00" && i.unpack('H*')[0] == "00" && curr_spacer.length == 8
      if spacers.length == replace_index
        #writes over file while reading for spacers
        #puts "cs: #{curr_spacer}, ncs: #{curr_spacer[0, 6] + picked_cameo}, ri: #{replace_index}, ph: #{picked_header}"
        #puts "old: #{command_new_data}, new: #{command_new_data[0, num-4] + (curr_spacer[0, 6] + picked_cameo)}"
        command_new_data = command_new_data[0, num-4] + [curr_spacer[0, 6] + picked_cameo + "00"].pack('H*')
      end
      spacers.push(curr_spacer)
      curr_spacer=""
    end
    last_it = last_ii
    last_ii = last_i
    last_i = i.unpack('H*')[0]
    if collect == 1
      curr_spacer = curr_spacer + i.unpack('H*')[0]
    end
    collect = 1
    num = num + 1
    #puts "i:#{i}, cs:#{curr_spacer}"
  end
  #puts "s: #{spacers}"
  #^returns 00XX00YY items
  #puts command_new_data.unpack('H*')[0]

  File.write(command_filepath, command_new_data)
  puts "Replaced cameo."
  puts "Press 1 to continue working with the same command and header files"
  puts "Press 2 to continue replacing cameos, but change files"
  puts "Press any other button to return to the menu"
  cont_choice = gets.chop
  if cont_choice == "1"
    six_header(command_filepath, header_filepath)
  elsif cont_choice == "2"
    two()
  else
    edOps()
  end
end

def six_picked_cameo(command_filepath, header_filepath, picked_header, picked_cameo, headers)
  puts "Are you sure you want to change the cameo at (#{picked_header}) to (#{picked_cameo}) in #{File.basename(command_filepath)}? (Y)"
  confirm = gets.chop
  if confirm == "y" || confirm == "Y"
    six_confirm(command_filepath, header_filepath, picked_header, picked_cameo, headers)
  else
    puts "Replacement was not confirmed: (#{confirm}). Booted to menu."
    edOps()
  end
end

def six_picked_header(command_filepath, header_filepath, picked_header, headers)
  puts "Please enter the hex id of the cameo you would like to substitute for the cameo in #{picked_header} (ie. 07)"
  picked_cameo = gets.chop
  #should check valid cameo here, but since a list has not yet been procured, advance.
  six_picked_cameo(command_filepath, header_filepath, picked_header, picked_cameo, headers)
end

def six_header(command_filepath, header_filepath)
  header_filechars = File.size(header_filepath)
  puts "Opened #{File.basename(header_filepath)} [#{header_filechars} bytes]"
  #produce header list
  header_data = File.binread(header_filepath) #doesn't stop at 1A on Windows if using binread
  headers = []
  # do last i, last last i to make sure you are getting 0X_0X_X*X_0X
  last_i = ""
  last_ii = ""
  last_it = ""
  curr_head = ""
  collecting_header = 0
  #get headers from file
  header_data.split("").each do |i| #iterates over each character in header_data
    if i == "0"
      if curr_head == ""
        collecting_header = 5
      elsif last_i == "_" && last_it != "0"
        collecting_header = 2
      end
    end
    if last_ii == "0" && i != "_" && curr_head.length == 2
      collecting_header=0
      curr_head=""
    end
    last_it = last_ii
    last_ii = last_i
    last_i = i
    if collecting_header > 0
      curr_head = curr_head + i
      if collecting_header == 1 || collecting_header == 2
        if !headers.include? curr_head
          collecting_header = collecting_header - 1
          if collecting_header == 0
            headers.push(curr_head)
            curr_head=""
          end
        end
      end
    end
    #puts "i:#{i}, curr_head:#{curr_head}"
  end
  #got headers
  puts "Listed below are all possible dialogue headers found in this chapter"
  puts headers
  puts "Please enter the header of the dialogue you would like to change (ie. 01_01_INTRO_01)"
  picked_header = gets.chop

  if headers.include? picked_header #checks if input is one in headers[]
    six_picked_header(command_filepath, header_filepath, picked_header, headers)
  else
    puts "Invalid header: (#{picked_header}). Please try again by entering one from the list."
    six_header(command_filepath, header_filepath)
  end
end

def six_command(command_filepath)
  puts "Please enter the filepath of the header file (ie chapterX_header.str)"
  header_filepath = gets.chop
  if File.exists?(header_filepath)
    six_header(command_filepath, header_filepath)
  else
    puts "Your file at (#{header_filepath}) could not be located. Please try again"
    six_command(command_filepath)
  end
end

def six()
  puts "Please enter the filepath of the command file (ie chapterX_command.str)"
  command_filepath = gets.chop

  if File.exists?(command_filepath)
    six_command(command_filepath)
  else
    puts "Your file at (#{command_filepath}) could not be located. Please try again"
    six()
  end
end

def edOps()
  puts "Press 1 to edit dialogue in plaintext"
  puts "Press 2 to edit dialogue cameos"
  puts "Press 3 to edit dialogue in hexadecimal"
  puts "Press any other button to quit"

  edit_option = gets.chop
  if edit_option == "1"
    one()
  elsif edit_option == "2"
    two()
  elsif edit_option == "3"
    three()
  else
    puts "Are you sure you want to quit? (Y)"
    quit_confirm = gets.chop
    if quit_confirm == "y" || quit_confirm == "Y"
      puts "Exited the program"
    else
      edOps()
    end
  end
end

def one()
  puts "Please enter the filepath of the dialogue (ie chapterX_language.str)"
  dialogue_filepath = gets.chop

  if File.exists?(dialogue_filepath)
    dialogue_filechars = File.size(dialogue_filepath)
    puts "Opened #{File.basename(dialogue_filepath)} [#{dialogue_filechars} bytes]"
    #Menu navigation begins here, replace with a function for multiple edits rather than restarting the program eventually
    one_dialogue(dialogue_filepath)
  else
    puts "Your file at (#{dialogue_filepath}) could not be located. Please try again"
    one()
  end
end

def one_dialogue(dialogue_filepath)
  puts "Would you like to use the chapter header to edit dialogue Y/N"
  puts "Using the header will only change one dialogue at a time,"
  puts "Not using the header will allow for changing all instances of a word"
  puts "(Using the header is less likely cause a glitch, although it will not work for chapter 7)"
  puts "*Changing character count in non-header mode is the easiest way to brick dialogue"
  ascii_file_edit_option = gets.chop

  if ascii_file_edit_option == "y" || ascii_file_edit_option == "Y"
    puts "Please enter the filepath of the header (ie chapterX_header.str)"
    header_filepath = gets.chop

    ascii_header_replace_menu(dialogue_filepath, header_filepath)
  elsif ascii_file_edit_option == "n" || ascii_file_edit_option == "N" #non-header auto ascii replace
    puts "Please enter the dialogue you would like to change exactly as it appears in-game"
    replaced_ascii = gets.chop

    puts "Please enter the dialogue you would like to replace (#{replaced_ascii}) with"
    new_ascii = gets.chop

    puts "Replacing all (#{replaced_ascii}) in #{File.basename(dialogue_filepath)} with (#{new_ascii}), is this ok? (Y)"
    ascii_replace_confirmation = gets.chop

    if ascii_replace_confirmation == "y" || ascii_replace_confirmation == "Y"
      replaceAscii(dialogue_filepath, replaced_ascii, new_ascii)
      puts "Press 1 to continue working with the same dialogue file"
      puts "Press 2 to continue replacing dialogue, but change file"
      puts "Press any other button to return to the menu"
      cont_choice = gets.chop
      if cont_choice == "1"
        one_dialogue(dialogue_filepath) #maybe add more choice for header vs without rather than Y/Ning every time
      elsif cont_choice == "2"
        one()
      else
        edOps()
      end
    else
      puts "Replacement was not confirmed, booted to menu."
      edOps()
    end
  else
    "Recieved an invalid answer (#{ascii_file_edit_option}), needs to be (Y) or (N)"
    one_dialogue(dialogue_filepath)
  end
end

def two()
  six()
end

def three()
  puts "Please enter the filepath of the dialogue (ie chapterX_language.str)"
  dialogue_filepath = gets.chop

  if File.exists?(dialogue_filepath)
    dialogue_filechars = File.size(dialogue_filepath)
    puts "Opened #{File.basename(dialogue_filepath)} [#{dialogue_filechars} bytes]"
    #Menu navigation begins here, replace with a function for multiple edits rather than restarting the program eventually
    three_dialogue(dialogue_filepath)
  else
    puts "Your file at (#{dialogue_filepath}) could not be located. Please try again"
    three()
  end
end

def three_dialogue(dialogue_filepath)
  puts "Would you like to use the chapter header to edit dialogue Y/N"
  puts "Using the header will only change one dialogue at a time,"
  puts "Not using the header will allow for changing all instances of a word"
  puts "(Using the header is less likely cause a glitch, although it will not work for chapter 7)"
  puts "*Changing character count in non-header mode is the easiest way to brick dialogue"
  file_edit_option = gets.chop

  if file_edit_option == "y" || file_edit_option == "Y"
    puts "Please enter the filepath of the header (ie chapterX_header.str)"
    header_filepath = gets.chop
    hex_header_replace_menu(dialogue_filepath, header_filepath)
  elsif file_edit_option == "n" || file_edit_option == "N" #non-header auto ascii replace
    puts "Please enter the hex you would like to change exactly as it appears in-game"
    replaced_hex = gets.chop

    puts "Please enter the hex you would like to replace (#{replaced_hex}) with"
    new_hex = gets.chop

    puts "Replacing all (#{replaced_hex}) in #{File.basename(dialogue_filepath)} with (#{new_hex}), is this ok? (Y)"
    hex_replace_confirmation = gets.chop

    if hex_replace_confirmation == "y" || hex_replace_confirmation == "Y"
      replaceHex(dialogue_filepath, replaced_hex, new_hex)
      puts "Press 1 to continue working with the same dialogue file"
      puts "Press 2 to continue replacing dialogue, but change file"
      puts "Press any other button to return to the menu"
      cont_choice = gets.chop
      if cont_choice == "1"
        three_dialogue(dialogue_filepath) #maybe add more choice for header vs without rather than Y/Ning every time
      elsif cont_choice == "2"
        three()
      else
        edOps()
      end
    else
      puts "Replacement was not confirmed, booted to menu."
      edOps()
    end
  else
    "Recieved an invalid answer (#{file_edit_option}), needs to be (Y) or (N)"
    three_dialogue(dialogue_filepath)
  end
end

puts "Booted."
edOps()
