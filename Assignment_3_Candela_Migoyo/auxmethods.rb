

# method to load input file information into an array
def loadDataFromFile(file_name)
	if File.exists?(file_name) && File.readable?(file_name)
		gene_arr = []
		gene_value = File.readlines(file_name)
		gene_value.each do |gene|
			gene_arr.push(gene.chomp.upcase)
		end
		return gene_arr
	else
		puts "ERROR! File with input data #{file_name} not found"
	end
end

# REST-CLIENT - Mark's fuction
def fetch(url, headers = {accept: "*/*"}, user = "", pass = "")
	response = RestClient::Request.execute({
		method: :get,
		url: url.to_s,
		user: user,
		password: pass,
		headers: headers})
	return response

	rescue RestClient::ExceptionWithResponse => e
		$stderr.puts e.response
		response = false
		return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
	rescue RestClient::Exception => e
		$stderr.puts e.response
		response = false
		return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
	rescue Exception => e
		$stderr.puts e
		response = false
		return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
end

# method to print to a file
def printToFile(output_file_name, data_to_print, flag) # flag w = write | a = append
	File.open(output_file_name, flag) do |this_file|
		this_file.puts data_to_print
	end
	return true
end

# this function checks that we are not working with an exon that we have already analyzed.
def getExonAnalyzedBefore(exon_coords_str)
    if $exon_cntrl_arr.length == 1
		$exon_cntrl_arr << exon_coords_str
        return false
    else
        if $exon_cntrl_arr.include? exon_coords_str
			return true
		else
			$exon_cntrl_arr << exon_coords_str
			return false
		end
    end
end

# method to optimize the number of hits
def optimizeMatches(gene, input_arr, diff)
	input_arr = input_arr.sort
	input_arr = input_arr.uniq
	# we eliminate overlapping entries
	for i in 0..(input_arr.length - 1)
		end_v = input_arr[i].to_i + diff.to_i
		next_v = input_arr[i + 1].to_i
		if end_v >= next_v
			input_arr -= [next_v]
		end
	 end
	return input_arr
end

# method for calculating the coordinates of the occurrences within the gene
def getLocationsInChromosome(gene, chrm_ini_coord, gen_mtch_p_ini_coord_arr)
	chrm_mtch_p_ini_coord_arr = []
	gen_mtch_p_ini_coord_arr.each do |crd_ini|
		# calculate the start location within the chromosome according to the formula: chrm_ini_coord + gen_mtch_p_ini_coord_arr - 1
		ini_loc_coord = chrm_ini_coord.to_i + crd_ini.to_i - 1
		# load in arr
		chrm_mtch_p_ini_coord_arr << ini_loc_coord
	end
	return chrm_mtch_p_ini_coord_arr
end

# method for printing GFF files
def gffFilePrinter(input_hsh, is_chrm, file_name)
	prnt = false
	hdr = "##gff-version 3"
	prnt = printToFile(file_name, hdr, "w")
	input_hsh.each do |key, input_arr|
		input_arr.each_with_index do |ftr, c|
			str = ""
			if is_chrm
				str += key.split('-')[0]
			else
				str += "#{key}"
			end
			str += "\t."
			str += "\t#{ftr.feature}"
			str += "\t#{ftr.position.split('..')[0]}"
			str += "\t#{ftr.position.split('..')[1]}"
			str += "\t."
			ftr.each do |qualifier|
				if qualifier.qualifier == "type"
					if qualifier.value.include? "Forward-CTTCTT"
						str += "\t+"
					else
						str += "\t-"
					end
				end
			end
			str += "\t."
			str += "\t"
			ftr.each do |qualifier|
				str += "#{qualifier.qualifier}=#{qualifier.value};"
			end
			str.delete_suffix!(';')
			prnt = printToFile(file_name, str, "a")
		end
	end
	return prnt
end

# method to print result message generation of files
def msgPrintFile(file_name, boo)
	if boo
		puts "Created and saved file #{file_name}"
	else
		puts "Error creating file #{file_name}"
	end
end