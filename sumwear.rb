#!/usr/bin/ruby

module SumWear

	def SumWear.create_log(root_dir)

		# Create the log file name using a timestamp & the path to the directory being checked
		timestamp = Time.now.to_i.to_s
		rootpath = root_dir.gsub(/\//, '.')
		log_file_name =  timestamp + "." + rootpath + "sumlog"

		# Initialize & return the log file
		return File.new log_file_name, 'w'
	end

	def SumWear.sum_list_dir(root_dir, log_file)
		Dir.chdir root_dir

		# First, iterate each sub directory & list its files
		Dir['*/'].each do |sub_dir|
			#puts sub_dir

			# sumwear check each sub directory's contents
			SumWear.sum_list_dir sub_dir, log_file

			# Flush the buffer from our subdirectory logging
			log_file.fsync

			# Move back up to root_dir after our subs moved down
			Dir.chdir '..'
		end

		log_file.puts "DIR #{Dir.pwd}"

		# Now, iterate each non-directory file & do a checksum
		Dir['*'].each do |sub_file|
			# If this is a subdirectory, move on
			if File.directory? sub_file
				next
			end

			# Replacement string for escaping single quotes to command line
			repl_str = "\'\\\\'\'"

			# run a checksum on the file & print the output
			log_file.puts "\t" + `shasum '#{sub_file.gsub(/\'/, repl_str)}'`
		end
	end
end

# 1 Argument required - the directory to sumwear check
if not dir_name = ARGV[0]
	puts "Usage: sumwear.rb directory_name"
	Process.exit
end

# Validate directory exists
if not File.directory? dir_name
	puts "'#{dir_name}'' not found or is not a directory"
	Process.exit
end

# Make sure we add a / to the end of filename if this is not included
if not dir_name.match(/.*\/$/)
	dir_name = dir_name + "\/"
end

# Create the log
log_file = SumWear.create_log dir_name

# Sum check the directory recursively
SumWear.sum_list_dir dir_name, log_file

# Close the log file
log_file.close