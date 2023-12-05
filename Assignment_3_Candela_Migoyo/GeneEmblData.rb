
# CLASS
class GeneEmblData

	attr_accessor :gene
	attr_accessor :gene_sequence
	attr_accessor :chromosome
	attr_accessor :chrm_ini_coord
	attr_accessor :chrm_end_coord
	attr_accessor :gen_mtch_p_ini_coord_arr
	attr_accessor :gen_mtch_m_ini_coord_arr
	attr_accessor :chrm_mtch_p_ini_coord_arr
	attr_accessor :chrm_mtch_m_ini_coord_arr

	def initialize(
			gene, gene_sequence, chromosome, chrm_ini_coord, chrm_end_coord, 
			gen_mtch_p_ini_coord_arr, gen_mtch_m_ini_coord_arr, 
			chrm_mtch_p_ini_coord_arr, chrm_mtch_m_ini_coord_arr
		)

        @gene = gene
        @gene_sequence = gene_sequence
        @chromosome = chromosome
        @chrm_ini_coord = chrm_ini_coord
        @chrm_end_coord = chrm_end_coord
		@gen_mtch_p_ini_coord_arr = gen_mtch_p_ini_coord_arr
		@gen_mtch_m_ini_coord_arr = gen_mtch_m_ini_coord_arr
		@chrm_mtch_p_ini_coord_arr = chrm_mtch_p_ini_coord_arr
		@chrm_mtch_m_ini_coord_arr = chrm_mtch_m_ini_coord_arr

    end

	def self.getEmblData(gene)
		address = URI("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene}")
		response = fetch(address)
		if response
			response = response.body
			entry = Bio::EMBL.new(response)
			gene_sequence = entry.to_biosequence
			
			if $print_embl_file
				entry_file = printToFile("./datafiles/#{gene}_embl_data.txt", response, "w")
			end
			#gene_sequence_file = printToFile("./datafiles/#{gene}_sequence.txt", gene_sequence, "w")
			
			return entry, gene_sequence
		end
	end

	def self.getValueFromEntry(gene, entry, param, print_output)
		code = 'value = entry.' + param
		result = eval(code)
		if print_output
			puts "@ #{gene} -> #{param}: #{result}"
		end
		return result
	end
end