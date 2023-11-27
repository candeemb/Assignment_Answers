

def loadDataFromFile(file_name)
	if File.exists?(file_name) && File.readable?(file_name)
		gene_arr = []
		gene_value = File.readlines(file_name)
		gene_value.each do |gene|
			#puts "gene: #{gene.upcase.chomp}"
			gene_arr.push(gene.chomp.upcase)
		end
		return gene_arr
	else
		puts "ERROR! File with input data #{file_name} not found"
	end
end

# Mark's fuction
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

def getInteractions(gene_arr) #	def interactions(mygenes_array)
	return_arr = []
	gene_arr.each_with_index do |gene, index|
		tmp_interactions = getInteractionsByGen(gene, gene_arr)
		if tmp_interactions != []
			return_arr.push([gene,tmp_interactions].flatten)
		end
	end
	return return_arr
end

def getInteractionsByGen(gene, gene_arr)	# def get_interactions(my_gene,all_genes)
	interact_arr = []
	address = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/query/#{gene}?format=tab25"
	response = fetch(address)
	if response
		data = response.body.split("\n")
		(0..data.length-1).each do |i|
			data[i] = data[i].split("\t")

			unless data[i][9].include?("3702") && data[i][10].include?("3702")
				next
			end

			intact_miscore = data[i][14].split(":")[1]
			if intact_miscore.to_f < $miscore_q
				next
			end

			data[i] = data[i][4..5]
			(0..data[i].length-1).each do |k|
				interact_arr.push(data[i][k].scan(/A[Tt]\d[Gg]\d\d\d\d\d/))
			end
		end
		interact_arr = interact_arr.flatten.uniq
		interact_arr.map!(&:upcase)
		interact_arr = interact_arr- [gene.upcase]
		return interact_arr
	end
end

def getKEGG(gene)
	address = "http://togows.org/entry/kegg-genes/ath:#{gene}/pathways.json"
	my_KEGG_list = []
	response = fetch(address)  
	if response
		body = response.body
		data = JSON.parse(response.body)
		my_KEGG_list.push(data[0].to_a)
		unless data[0].nil?
			if data[0].length != 0
				my_KEGG_list = data[0].to_a
			end
		end
		return my_KEGG_list
	else 
		return Array.new
	end
end

def getProtId(gene)
	address="http://togows.org/entry/ebi-uniprot/#{gene}/accessions.json"
	response = fetch(address)  
	if response  # if there is a response to calling that URI
		body = response.body  # get the "body" of the response
		data = JSON.parse(response.body)
		return data[0]
	end
end

def getGO(gene)
	address = "http://togows.dbcls.jp/entry/uniprot/#{gene}/dr.json"
	my_GO_list = []
	response = fetch(address)  
	if response  # if there is a response to calling that URI
		body = response.body  # get the "body" of the response
		data = JSON.parse(response.body)
		if data[0]["GO"]
			data[0]["GO"].each do |go| 
				if go[1] =~ /P:/#if its a biological process it will have the key 'P'
					my_GO_list.push(go[0..1])
				end
			end
			return my_GO_list
		end
	else 
		return Array.new
	end
end

def getNotDupleInteractions(f_intrctns_arr, gene_arr)
	s_intrctns_arr = []
	f_intrctns_arr.each do |int|
		s_intrctns_arr.push(int[1..-1])
	end
	s_intrctns_arr.flatten!.uniq!
	s_intrctns_arr = s_intrctns_arr - (s_intrctns_arr & gene_arr)
	return s_intrctns_arr
end

def getNetworks(gene_arr, f_intrctns_arr, s_intrctns_arr, t_intrctns_arr)
	flttn_arr = [gene_arr,s_intrctns_arr].flatten!
	second_interactions_arr = []
	t_intrctns_arr.each do |int|
		interactions_arr = []
		int[1..-1].each do |gen_inter|
			if flttn_arr.include? gen_inter
				interactions_arr.push(gen_inter)
			end
		end
		second_interactions_arr.push([int[0],interactions_arr].flatten)
	end

	all_arr = [f_intrctns_arr,second_interactions_arr].flatten!(1)

	## create network's arrays
	networks_arr = []
	all_arr.each do |item| # get one array of interactions, for example [gene1 , gene2, gene3]
		net = []
		item.each do |elem| # get one of those genes, for example gene1
			(0..all_arr.length-1).each do |i| #iterate over the arrays again (like all_arr[0] = [gene1 , gene2, gene3])
				if all_arr[i].any? elem #if the array contains that gene (for example gene1 is in all_arr[0])
					net.push(all_arr[i].flatten) # include that array of interactions to my new array 
				end
			end
		end
		net.flatten!
		net.uniq!
		net.sort!
		if net.length > 2 && (gene_arr&net).length > 1
			networks_arr.push(net)
		end
	end

	networks_arr.uniq!
	return networks_arr
end