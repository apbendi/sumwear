#!/opt/local/bin/ruby1.9


module SumWear
	def SumWear.sum_list_dir(root_dir)
		Dir.chdir root_dir

		# First, iterate each sub directory & list its files
		Dir['*/'].each do |sub_dir|
			#puts sub_dir

			# sumwear check each sub directory's contents
			SumWear.sum_list_dir sub_dir
			Dir.chdir '..'
		end

		puts Dir.pwd

		# Now, iterate each non-directory file & do a checksum
		Dir['*'].each do |sub_file|
			# If this is a subdirectory, move on
			if File.directory? sub_file
				next
			end

			# run a checksum on the file & print the output
			puts `shasum #{sub_file}`
		end
	end
end

# 1 Argument required - the directory to sumwear check
if not dir_name = ARGV[0]
	puts "Usage: sumwear.rb directory_name"
	Process.exit
end

# Validate directory exists
if not Dir.exists? dir_name
	puts "'#{dir_name}'' not found or is not a directory"
	Process.exit
end

SumWear.sum_list_dir dir_name