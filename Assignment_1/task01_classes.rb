
# CLASSES

class CrossData

	attr_accessor :parent1, :parent2, :f2_wild, :f2_p1, :f2_p2, :f2_p1p2, :chi_squared
	
	def initialize(parent1, parent2, f2_wild, f2_p1, f2_p2, f2_p1p2, chi_squared)
		@parent1 = parent1
		@parent2 = parent2
		@f2_wild = f2_wild
		@f2_p1 = f2_p1
		@f2_p2 = f2_p2
		@f2_p1p2 = f2_p1p2
		@chi_squared = chi_squared
	end

	# cargamos los datos desde el fichero
	file_name = "data/cross_data.tsv"
	if File.exists?(file_name) && File.readable?(file_name)
		$cross_data_data = File.readlines(file_name)
		$cross_data_header = $cross_data_data[0].chomp.split("\t")
		$cross_data_data[1..-1].each_with_index do |line, index|
			parent1, parent2, f2_wild, f2_p1, f2_p2, f2_p1p2 = line.chomp.split("\t")
			$cross_data[parent1] = CrossData.new(parent1, parent2, f2_wild, f2_p1, f2_p2, f2_p1p2, 0)
		end
	else
		if $err_prnt
			puts "ERROR! File with input data #{file_name} not found"
		end
	end

end


class GeneInformation

	attr_accessor :gene_id, :gene_name, :mutant_phenotype, :linked_to

	def initialize(gene_id, gene_name, mutant_phenotype, linked_to)
		@gene_id = gene_id
		@gene_name = gene_name
		@mutant_phenotype = mutant_phenotype
		@linked_to = linked_to
	end

	# cargamos los datos desde el fichero
	file_name = "data/gene_information.tsv"
	if File.exists?(file_name) && File.readable?(file_name)
		$gene_information_data = File.readlines(file_name)
		$gene_information_header = $gene_information_data[0].chomp.split("\t")
		$gene_information_data[1..-1].each_with_index do |line, index|
			gene_id, gene_name, mutant_phenotype = line.chomp.split("\t")
			$gene_information[gene_id] = GeneInformation.new(gene_id, gene_name, mutant_phenotype, "")
		end
	else
		if $err_prnt
			puts "ERROR! File with input data #{file_name} not found"
		end
	end

end


class SeedStockData

	attr_accessor :seed_stock, :mutant_gene_id, :last_planted, :storage, :grams_remaining

	def initialize(seed_stock, mutant_gene_id, last_planted, storage, grams_remaining)
		@seed_stock = seed_stock
		@mutant_gene_id = mutant_gene_id
		@last_planted = last_planted
		@storage = storage
		@grams_remaining = grams_remaining
	end

	def updateGramsRemaining(grams)
		self.grams_remaining = minusValue(self.grams_remaining, grams)
	end

	def updateLastPlanted
		self.last_planted = $today
	end

	# cargamos los datos desde el fichero
	file_name = "data/seed_stock_data.tsv"
	if File.exists?(file_name) && File.readable?(file_name)
		$seed_stock_data_data = File.readlines(file_name)
		$seed_stock_data_header = $seed_stock_data_data[0]
		$seed_stock_data_data[1..-1].each_with_index do |line, index|
			seed_stock, mutant_gene_id, last_planted, storage, grams_remaining = line.chomp.split("\t")
			$seed_stock_data[seed_stock] = self.new(seed_stock, mutant_gene_id, last_planted, storage, grams_remaining)
		end
	else
		if $err_prnt
			puts "ERROR! File with input data #{file_name} not found"
		end
	end

end