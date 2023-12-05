

# main.rb


# SOURCES
#
# Lesson 6 - BioRuby and Biogems.ipynb
# > http://bioruby.org
# > http://gmod.org/wiki/GFF3


require 'rest-client'
require 'bio'
# incluimos la libreria date para utilizarla en los nombres de los ficheros de salida
require "date"
require './auxmethods.rb'
require './GeneEmblData.rb'

# Vars
# input data file name
input_file_name = "ArabidopsisSubNetwork_GeneList.txt"

# array to store the genes that come in the input file
gene_arr = []
# global array for exon control
$exon_cntrl_arr = []
# length adapted from search string CTTCTT
$rep_str_len = 5
# hash where we store the instances of Bio::Feature.new() of all the occurrences found (coordinates with respect to the gene)
$gene_data_features_hsh = {}
# hash where we store the instances of Bio::Feature.new() of all the occurrences found (coordinates with respect to the chromosome).
$chrm_data_features_hsh = {}
# variables for task_4a -> create a gff3 file with the occurrences found (coordinates with respect to the gene)
task_4a_file_name = "task_4a_file.gff"
# variables for task_4b -> genes without exons with CTTCTT repeats
$task_4b_arr = []
task_4b_file_name = "task_4b_report.txt"
# variables for task_5 -> create a gff3 file with the occurrences found (coordinates with respect to the chromosome)
task_5_file_name = "task_5_file.gff"
# print_embl_file -> controls the printing to file of embl queries.
$print_embl_file = false

# main method: performs several operations, loads all the info in an instance of GeneEmblData and returns it to the loop that goes through the list of genes.
def getGeneData(gene)

	# get entry and gene_sequence to the gene
	# entry is a Bio::EMBL object
	# gene_sequence is entry.to_biosequence = complete sequence of the gene
	entry, gene_sequence = GeneEmblData.getEmblData(gene)
	# we get the chromosome and chrm_ini_coord data
	entry_sv = GeneEmblData.getValueFromEntry(gene, entry, 'sv', false)
	value = entry_sv.split(":").map{ |str| str.to_i }
	# chromosome value
	chromosome = value[2]
	# sequence start position of this gene within the chromosome
	chrm_ini_coord = value[3]
	# end position of the sequence of this gene within the chromosome
	chrm_end_coord = value[4]
	# reset the global array $exon_cntrl_arr
	$exon_cntrl_arr = []
	exon_counter = 0
	exon_uniq_counter = 0
	# we create an array to store the coordinates of CTTCTT occurrences
	# array coordinates ini plus -> gen
	$gen_mtch_p_ini_coord_arr = []
	# array coordinates ini minus -> gen
	$gen_mtch_m_ini_coord_arr = []
	# arrays coordinates ini plus -> cromosoma
	$chrm_mtch_p_ini_coord_arr = []
	# arrays coordinates ini minus -> cromosoma
	$chrm_mtch_m_ini_coord_arr = []

	# iterate entry features
	entry.features.each_with_index do |feature, index|

		# skip values != exon
		next unless feature.feature == "exon"

		# > http://bioruby.org/rdoc/Bio/Feature.html
		feature.locations.each_with_index do |loc, locindex|

			# we increase exon_counter
			exon_counter += 1
			# we obtain the value of strand
			strand = feature.locations[0].strand
			# we store the START position of the exon within the complete sequence -> gene_sequence
			exon_coord_ini = loc.from.to_i
			# we store the END position of the exon within the complete sequence -> gene_sequence
			exon_coord_end = loc.to.to_i
			# skip equals values
			next if exon_coord_ini == exon_coord_end

			# we create a string with the coordinates ini and end to check that we are not working with repeated exons
			exon_coords_str = exon_coord_ini.to_s + "#" + exon_coord_end.to_s
			# we check if we have already analyzed this exon
			exon_analized_before = getExonAnalyzedBefore(exon_coords_str)
			# skip if true
			next if exon_analized_before
			# we increase exon_uniq_counter
			exon_uniq_counter += 1
			# we obtain the sequence of the exon by "extracting" from the complete sequence (gene_sequence) the nucleotides between the start and end positions of the exon
			exon_sequence = gene_sequence.subseq(exon_coord_ini, exon_coord_end)
			# we check that the sequence of the exon is not null
			next if exon_sequence == nil
			# plus_strand
			if strand == 1
				# we search for occurrences of 'CTTCTT' in the sequence of the exon
				matches = exon_sequence.enum_for(:scan, /(?=(CTTCTT))/i).map { Regexp.last_match }
				# skip if empty
				next if matches.empty?
				# we iterate each occurrence to obtain the start and end coordinates of 'CTTCTT' within exon_sequence
				matches.each_with_index do |match, matchindex|
					# start coordinate of the repeat inside the exon
					# we add 1 to adjust to the biological coordinate numbering, this implies that rpt_init_pos = 'c'.
					rep_coord_ini = match.begin(0) + 1
					# load value in $gen_mtch_p_ini_coord_arr
					pos_tmp = exon_coord_ini.to_i + rep_coord_ini.to_i - 1
					$gen_mtch_p_ini_coord_arr << pos_tmp
				end
			end
			# minus_strand
			if strand == -1			

				# we search for occurrences of 'AAGAAG' in the sequence of the exon
				matches = exon_sequence.enum_for(:scan, /(?=(AAGAAG))/i).map { Regexp.last_match }
				# skip if empty
				next if matches.empty?
				# we iterate each occurrence to obtain the start and end coordinates of 'AAGAAG' within exon_sequence
				matches.each_with_index do |match, matchindex|
					rep_coord_ini = match.begin(0) + 1
					# load value in $gen_mtch_m_ini_coord_arr
					pos_tmp = exon_coord_ini.to_i + rep_coord_ini.to_i - 1
					$gen_mtch_m_ini_coord_arr << pos_tmp
				end
			end
		end
	end
	# last tasks before initializing a GeneEmblData object
	# we sort, remove duplicate values and remove overlaps
	$gen_mtch_p_ini_coord_arr = optimizeMatches(gene, $gen_mtch_p_ini_coord_arr, $rep_str_len)
	$gen_mtch_m_ini_coord_arr = optimizeMatches(gene, $gen_mtch_m_ini_coord_arr, $rep_str_len)
	# we calculate the coordinates of the forward occurrences (strand +1) with respect to the chromosome
	$chrm_mtch_p_ini_coord_arr = getLocationsInChromosome(gene, chrm_ini_coord, $gen_mtch_p_ini_coord_arr)
	$chrm_mtch_m_ini_coord_arr = getLocationsInChromosome(gene, chrm_ini_coord, $gen_mtch_m_ini_coord_arr)
	# we create istance of the GeneEmblData object
	obj = GeneEmblData.new(
			gene, gene_sequence, chromosome, chrm_ini_coord, chrm_end_coord, 
			$gen_mtch_p_ini_coord_arr, $gen_mtch_m_ini_coord_arr, 
			$chrm_mtch_p_ini_coord_arr, $chrm_mtch_m_ini_coord_arr
		)
	return obj
end

puts ""
puts "Process started..."
puts ""

# we load the data from the file passed as parameter to the loadDataFromFile() method in the array gene_arr
gene_arr = loadDataFromFile(input_file_name)


# we iterate through the genes of gene_arr
gene_arr.each_with_index do |gene, top_index|
	puts "Processing ##{top_index + 1}... #{gene}"

	# we load all the gene information
	gene_data = getGeneData(gene)
	# we define a temporary array to load the information of each occurrence
	$gene_data_tmp_arr = []
	$chrm_data_tmp_arr = []
	$has_coords = false

	# we create instances of the object Bio::Feature.new()
	# > http://bioruby.org/rdoc/Bio/Feature.html
	#
	# strand +1 -> Forward
	if gene_data.gen_mtch_p_ini_coord_arr.length > 0
		$has_coords = true
		gene_data.gen_mtch_p_ini_coord_arr.each_with_index do |c_ini, c_indx|
			# gen referenced
			c_end = c_ini.to_i + $rep_str_len
			gn_feature_new = Bio::Feature.new('repeated_sequence', c_ini.to_s + '..' + c_end.to_s)
			gn_feature_new.append(Bio::Feature::Qualifier.new('type', 'Forward-CTTCTT'))
			gn_feature_new.append(Bio::Feature::Qualifier.new('gene', gene))
			$gene_data_tmp_arr << gn_feature_new
			# chromosome referenced
			c_end = gene_data.chrm_mtch_p_ini_coord_arr[c_indx].to_i + $rep_str_len
			ch_feature_new = Bio::Feature.new('repeated_sequence', gene_data.chrm_mtch_p_ini_coord_arr[c_indx].to_s + '..' + c_end.to_s)
			ch_feature_new.append(Bio::Feature::Qualifier.new('type', 'Forward-CTTCTT'))
			ch_feature_new.append(Bio::Feature::Qualifier.new('gene', gene))
			$chrm_data_tmp_arr << ch_feature_new
		end
	end
	# strand -1 -> Reverse
	if gene_data.gen_mtch_m_ini_coord_arr.length > 0
		$has_coords = true
		gene_data.gen_mtch_m_ini_coord_arr.each_with_index do |c_ini, c_indx|
			# gen referenced
			c_end = c_ini.to_i + $rep_str_len
			gn_feature_new = Bio::Feature.new('repeated_sequence', c_ini.to_s + '..' + c_end.to_s)
			gn_feature_new.append(Bio::Feature::Qualifier.new('type', 'Reverse-CTTCTT'))
			gn_feature_new.append(Bio::Feature::Qualifier.new('gene', gene))
			$gene_data_tmp_arr << gn_feature_new
			# chromosome referenced
			c_end = gene_data.chrm_mtch_m_ini_coord_arr[c_indx].to_i + $rep_str_len
			ch_feature_new = Bio::Feature.new('repeated_sequence', gene_data.chrm_mtch_m_ini_coord_arr[c_indx].to_s + '..' + c_end.to_s)
			ch_feature_new.append(Bio::Feature::Qualifier.new('type', 'Reverse-CTTCTT'))
			ch_feature_new.append(Bio::Feature::Qualifier.new('gene', gene))
			$chrm_data_tmp_arr << ch_feature_new
		end
	end

	if $has_coords
		# gen referenced
		$gene_data_features_hsh[gene] = $gene_data_tmp_arr
		# chromosome referenced
		chrm_tmp = "Chr#{gene_data.chromosome}-#{gene}"
		$chrm_data_features_hsh[chrm_tmp] = $chrm_data_tmp_arr
	else
		# list of genes for which no CTTCTT forward (strand +1) or reverse (strand -1) CTTCTT occurrences found
		$task_4b_arr.push gene_data.gene
	end

end

# we print the task_4a file
task_4a_ok = false
task_4a_ok = gffFilePrinter($gene_data_features_hsh, false, task_4a_file_name)
msgPrintFile(task_4a_file_name, task_4a_ok)
# we print the task_5 file
task_5_file_ok = false
task_5_file_ok = gffFilePrinter($chrm_data_features_hsh, true, task_5_file_name)
msgPrintFile(task_5_file_name, task_5_file_ok)
# we print gene file without occurrences
if $task_4b_arr.length > 0
	task_4b_ok = false
	header = "#.> ASSIGNMENT 3 - Task 4a\n"
	header += "#.> Candela Migoyo Bettoni - #{DateTime.now.strftime("%d.%m.%Y")}\n"
	header += "#.> Of the #{gene_arr.length} input genes, the following #{$task_4b_arr.length} have no exons with CTTCTT repeats"
	task_4b_ok = printToFile(task_4b_file_name, header, "w")
	$task_4b_arr.each do |value|
		task_4b_ok = printToFile(task_4b_file_name, value, "a")
	end
	msgPrintFile(task_4b_file_name, task_4b_ok)
end

puts ""
puts "Ended Process"
puts ""





