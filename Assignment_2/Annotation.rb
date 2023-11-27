
class Annotation

	attr_accessor :gene_id # AGI code
	attr_accessor :prot_id # UniProt IDs
	attr_accessor :network_id # array containing the network ID in which the gene participates 
	attr_accessor :go 
	attr_accessor :kegg
	attr_accessor :interactions
	@@all_objects = Array.new
  
  
	def initialize (params = {})

		@gene_id = params.fetch(:gene_id, "AT0G00000")
		unless @gene_id.match(/A[Tt]\d[Gg]\d\d\d\d\d/) #if the code does not match the regular expression, raise an error
			raise "\n Error: invalid gene ID format: #{@gene_id} \n Make sure ALL gene IDs have ATxGxxxxx format"
		end
		@prot_id = params.fetch(:prot_id, Array.new) #UniProt IDs
		@network_id = params.fetch(:network_id, Array.new)
		@kegg = params.fetch(:kegg, Array.new) #Array with KEGG's ID and pathway name
		@go = params.fetch(:go, Array.new) #Array with GO's ID and term name
		@interactions = params.fetch(:interactions, Array.new) #Array with GO's ID and term name
		@@all_objects << self

	end

#	def show_all_objects
#		return @@all_objects
#	end

	def getInfo(id)
		@@all_objects.each do |object|
			if object.gene_id == id
				return [object.gene_id, object.network_id, object.prot_id, object.kegg, object.go, object.interactions]
				#return print "Gene's ID : #{object.gene_id}\nProteins's UniProt name: #{object.prot_id}\nKEGG's ID and pathway name: #{object.kegg}\nGO's ID and term name: #{object.go}\nProtein interactions: #{object.interactions}"
			end
		end
	end
  
end	# end class