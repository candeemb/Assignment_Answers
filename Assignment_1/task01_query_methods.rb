
# METODOS DE CONSULTA

# CrossData
def getCrossDataAllData
	return_arr = []
	$cross_data.each do |clave, dato|
		if return_arr.length == 0
			$cross_data_header.push "Chi_squared"
			return_arr << $cross_data_header.join("\t")
		end
		return_arr << [dato.parent1, dato.parent2, dato.f2_wild, dato.f2_p1, dato.f2_p2, dato.f2_p1p2, dato.chi_squared].join("\t")
	end
	return puts return_arr
end

def getCrossDataChiSquared(id)
	return puts $cross_data[id].chi_squared
end

# GeneInformation
def getGeneInformationAllData
	return_arr = []
	$gene_information.each do |clave, dato|
		if return_arr.length == 0
			$gene_information_header.push "Linked_To"
			return_arr << $gene_information_header.join("\t")
		end
		return_arr << [dato.gene_id, dato.gene_name, dato.mutant_phenotype, dato.linked_to].join("\t")
	end
	return puts return_arr
end

def getGeneInformationGeneName(id)
	return puts $gene_information[$seed_stock_data[id].mutant_gene_id].gene_name
end

def getGeneInformationMutantPhenotype(id)
	return puts $gene_information[$seed_stock_data[id].mutant_gene_id].mutant_phenotype
end

def getGeneInformationLinkedTo(id)
	return puts $gene_information[$seed_stock_data[id].mutant_gene_id].linked_to
end


# SeedStock
def getSeedStockAllData
	return_arr = []
	$seed_stock_data.each do |clave, dato|
		if return_arr.length == 0
			return_arr << $seed_stock_data_header
		end
		return_arr << [dato.seed_stock, dato.mutant_gene_id, dato.last_planted, dato.storage, dato.grams_remaining].join("\t")
	end
	return puts return_arr
end

def getSeedStockMutantGeneId(id)
	return puts $seed_stock_data[id].mutant_gene_id
end

def getSeedStockLastPlanted(id)
	return puts $seed_stock_data[id].last_planted
end

def getSeedStockStorage(id)
	return puts $seed_stock_data[id].storage
end

def getSeedStockGramsRemaining(id)
	return puts $seed_stock_data[id].grams_remaining
end

def searchSeedStockLastPlanted(fecha)
	return_arr = []
	$seed_stock_data.each do |clave, dato|
		if dato.last_planted.to_s == fecha.to_s
			if return_arr.length == 0
				return_arr << $seed_stock_data_header
			end
			return_arr << [dato.seed_stock, dato.mutant_gene_id, dato.last_planted, dato.storage, dato.grams_remaining].join("\t")
		end
	end
	return puts return_arr
end












