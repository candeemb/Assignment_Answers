
class InteractionNetwork

	attr_accessor :my_networks 
	attr_accessor :net_members 
	attr_accessor :genes
	
	def initialize (params = {})
		@my_networks = params.fetch(:my_networks, Array.new) # [ [genes in network 1], [genes in network 2], ...]
		@net_members = params.fetch(:net_members, Hash.new)  # {net_1 => [genes], network_2 => [genes], ...}
		@genes = params.fetch(:genes, Array.new)  # [[geneA, net_1, net_2], [geneB, net_3, net_8], ... ]
	  
		if @my_networks != [] && @net_members == Hash.new
			i = 1
			@my_networks.each do |network|
				@net_members.merge!("network_#{i}" => network)
				i += 1
			end
		end
	  
		if @net_members != Hash.new && @genes == Array.new
			@genes = getMembersNetworks
		end
	  
		if @members_networks!=[]
			annotateMembers
		end
	end

	def getMembersNetworks #find all member's networks ->  [[geneA, net_1, net_2], [geneB, net_3, net_8], ...]
		a= @net_members.values.flatten.uniq #create array 'a' with all members of all networks
		gen_net = []
		a.each do |gene|
			w=[gene]
			@net_members.each_key do |net_id| #iterate over the hash @members
				if @net_members[net_id].include? gene 
					w.push(net_id)
				end
			end
			gen_net.push(w)
		end
		return gen_net
	end
	
	def annotateMembers 
		member_o = Array.new
		#puts "I will iterate over #{@members_networks}"
		@genes.each do |members|
			member_o.push("new")
			#puts "I try to annotate #{members[0]}"
			member_o[-1] = Annotation.new(
				:gene_id => members[0],
				:network_id => members[1..-1], #takes all but the first element because that's the gene_id
				:prot_id => getProtId(members[0]),
				:kegg => getKEGG(members[0]),
				:go => getGO(members[0]),
				:interactions => getInteractionsByGen(members[0],@all_genes)
			)
		end
		$annotated_members_array = member_o
		return $annotated_members_array
	end
end	# end class