
# Requirements:
# To run this script you need to have the following packages installed:
# ncbi-blast+ > https://packages.debian.org/bookworm/ncbi-blast+
# ncbi-blast+-legacy > https://packages.debian.org/bookworm/ncbi-blast+-legacy

# how to run
# ruby main.rb TAIR10_cds_20101214_updated.fa pep.fa BRH_report.txt

require 'bio'
require "date"

# inputs from the commnad line
if ARGV.length != 3 || (
	!ARGV[0].to_s.include?('.fa') ||
	!ARGV[1].to_s.include?('.fa') ||
	!ARGV[2].to_s.include?('.txt')
	)
	# https://stackoverflow.com/questions/23340609/what-is-the-difference-between-exit-and-abort
	abort("ERROR: Invalid number or file formats in input parameteres. Please see README.md for more information.")
end

# vars
db_dir_name = "databases"
input_data_arr = [ARGV[0], ARGV[1]]
db_name_arr = ["arabid", "spombe"]
seq_type_arr = []
# > https://www.metagenomics.wiki/tools/blast/evalue
e_value = 1e-10
bit_score = 50
arabid_seq_hsh = {}
spombe_seq_hsh = {}
orthologs_file_name = ARGV[2]


# method to check if a directory exists
# > https://www.geeksforgeeks.org/ruby-directories/
def dir_exists(dirname)
	return Dir.exists?(dirname)
end

# method for creating databases
def createDatabaseFiles(input_data_arr, db_dir_name, db_name_arr)
	# check if the files already exist
	db_path_src = "#{db_dir_name}/#{db_name_arr}.*"
	db_path = "#{db_dir_name}/#{db_name_arr}"
	if Dir[db_path_src].empty?
		# create the databases
		system("makeblastdb -in #{input_data_arr} -dbtype #{getSeqType(input_data_arr)} -out #{db_dir_name}/#{db_name_arr}")
		puts "Created database > #{db_path}"
	else
		puts "Database found > #{db_path} "
	end
	# return the complete path to the databases
	return db_path
end

# method to obtain the sequence type of a given input
def getSeqType(input)
	# create a FlatFile object from the input file and get the first sequence
	seq = Bio::Sequence.new(Bio::FlatFile.auto(input).next_entry.seq)
	# check the type of the sequence and return result
	if seq.guess == Bio::Sequence::AA
		return "prot"
	else
		return "nucl"
	end
end

# method to obtain the program value
def getBlastProgram(arr, i)
	# store the values of the arr in variables and analyze the possible cases
	a, b = arr
	if a == b			# if the values are equal (nucl or prot)
		if a == "nucl"
			return "blastn"
		else
			return "blastp"
		end
	else				# if the values are not equal
		if arr[i] == "nucl"
			return "tblastn"
		else
			return "blastx"
		end
	end
end

# metohod to set hash sequences
def setHshSeq(fasta)
	hsh = {}
	fasta.each_entry do |entry|
		hsh[entry.entry_id] = entry.seq
	end
	return hsh
end

# metohod to inform about elapsed time
def getElapsedTime(starting, ending)
	elapsed = ((ending - starting) / 60).round(2)
	return elapsed
end

# method to search BRH
def searchBRH(seq_hsh_a, factory_a, seq_hsh_b, factory_b, e_value, bit_score)
	hsh = {}
	counter = 0
	starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
	# iterate sequences
	# > http://bioruby.org/rdoc/Bio/Blast/Report/Hit.html
	seq_hsh_b.each do |key, value|
		#puts "counter: #{counter}"
		#puts "#{key} #{value}"
		report_b = factory_a.query(value)
		next if report_b.hits.empty?
		hit_b = report_b.hits.first
		next if hit_b.evalue >= e_value
		next if hit_b.bit_score <= bit_score
		gene_id = hit_b.target_def.split("|")[0].strip
		report_a = factory_b.query(seq_hsh_a[gene_id])
		next if report_a.hits.empty?
		hit_a = report_a.hits.first
		next if hit_a.evalue >= e_value
		next if hit_a.bit_score <= bit_score
		if hit_a.target_def.split("|")[0].strip == key
			hsh[gene_id] = key
		end
		# anti-anxiety messages
		if hsh.length % 10 == 0 && hsh.length > 0
			ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
			puts "#{hsh.length} hits found in #{getElapsedTime(starting, ending)} mins (#{counter}/#{seq_hsh_b.length}). Keep searching for ..."
		end
		counter += 1
	end
	ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
	puts "Total hits found: #{hsh.length} in #{getElapsedTime(starting, ending)} mins"
	return hsh
end

# method to print to a file
def printToFile(output_file_name, data_to_print, flag) # flag w = write | a = append
	File.open(output_file_name, flag) do |this_file|
		this_file.puts data_to_print
	end
	return true
end


# process
puts ""
puts "Starting process ..."

# check if the directory where we want to store the db exists
puts "Checking if '#{db_dir_name}' directory exists ..."
if !dir_exists(db_dir_name)
	# the directory does not exist => we create it
	Dir.mkdir db_dir_name
	puts "Created directory > #{db_dir_name}"
else
	puts "Directory found > #{db_dir_name}"
end

puts "Checking if databases and factories exists ..."
# from the two inputs we perform different tasks
for i in 0..(input_data_arr.length - 1)

	# create the databases
	db_path = createDatabaseFiles(input_data_arr[i], db_dir_name, db_name_arr[i])

	# load the corresponding sequence type in seq_type_arr
	seq_type_arr.push(getSeqType(input_data_arr[i]))

	# create objects, factories and hash sequence
	# > http://bioruby.org/rdoc/Bio/FlatFile.html
	# > http://bioruby.org/rdoc/Bio/Blast.html
	if i == 0
		arabid_fasta = Bio::FlatFile.auto(input_data_arr[i])
		arabid_seq_hsh = setHshSeq(arabid_fasta)
		puts "Created seq hash > arabid_seq_hsh (#{arabid_seq_hsh.length})"
		arabid_factory = Bio::Blast.local(getBlastProgram(seq_type_arr, i), db_path)
		puts "Created factory > arabid_factory"
	else
		spombe_fasta = Bio::FlatFile.auto(input_data_arr[i])
		spombe_seq_hsh = setHshSeq(spombe_fasta)
		puts "Created seq hash > spombe_seq_hsh (#{spombe_seq_hsh.length})"
		spombe_factory = Bio::Blast.local(getBlastProgram(seq_type_arr, i), db_path)
		puts "Created factory > spombe_factory"
	end
end

puts "Starting reciprocal hits search ..."
puts "Filtering values: hit.evalue <= #{e_value} AND hit.bit_score >= #{bit_score} "
puts "This task could take several minutes. Please be patient."

orthologs_hsh = searchBRH(arabid_seq_hsh, arabid_factory, spombe_seq_hsh, spombe_factory, e_value, bit_score)

puts "Printing #{orthologs_file_name} ... "
# print the report
header = "#.> ASSIGNMENT 4 - Orthologs as reciprocal best hits\n"
header += "#.> Candela Migoyo Bettoni - #{DateTime.now.strftime("%d.%m.%Y")}\n"
header += "#.> Found #{orthologs_hsh.length} potential orthologues using the Best Reciprocal Hit technique with the following filtering parameters:\n"
header += "#.> \thit.evalue <= #{e_value}\n"
header += "#.> \thit.bit_score >= #{bit_score}\n"
header += "\n\n"
header += "Arabidopsis\t\tS. pombe"
x = printToFile(orthologs_file_name, header, "w")
if orthologs_hsh.length > 0
	orthologs_hsh.each do |key, value|
		str = "#{key}\t\t#{value}"
		x = printToFile(orthologs_file_name, str, "a")
	end
end

puts "Completed process."
