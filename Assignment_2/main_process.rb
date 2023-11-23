#!/usr/bin/env ruby

# main_process.rb

require "rest-client"
require "json"
require "date"
require "./Functions.rb"
require "./InteractionNetwork.rb"
require "./Annotation.rb"


# VARIABLES
input_file_name = "gene_20.txt"
input_file_name = "ArabidopsisSubNetwork_GeneList.txt"
output_file_name = "Network_report_#{DateTime.now.strftime("%Y%m%d%H%M")}.txt"
$gene_arr = []
$f_intrctns_arr = []
$s_intrctns_arr = []
$t_intrctns_arr = []
$networks_arr = []
$miscore_q = 0.485


puts "Starting data processing"

$gene_arr = loadDataFromFile(input_file_name)
#puts "$gene_arr.length: " + $gene_arr.length.to_s

$f_intrctns_arr = getInteractions($gene_arr)
#puts "$f_intrctns_arr.length: " + $f_intrctns_arr.length.to_s

$s_intrctns_arr = getNotDupleInteractions($f_intrctns_arr, $gene_arr)
#puts "$s_intrctns_arr.length: " + $s_intrctns_arr.length.to_s

$t_intrctns_arr = getInteractions($s_intrctns_arr)
#puts "$t_intrctns_arr.length: " + $t_intrctns_arr.length.to_s

$networks_arr = getNetworks($gene_arr, $f_intrctns_arr, $s_intrctns_arr, $t_intrctns_arr)
#puts "$networks_arr.length: " + $networks_arr.length.to_s

puts "End of data processing"
puts "..."
puts "Init report generation"

$interaction_network = InteractionNetwork.new(:my_networks => $networks_arr, :all_genes => $gene_arr)

report = File.open(output_file_name,"w")
report.puts "# REPORT BY Candela Migoyo"
report.puts "# Input file name: #{input_file_name}"
report.puts "# Input data length: #{$gene_arr.length} genes"
report.puts "# Interactions filters: only Arabidopsis thaliana"
report.puts "# Intact MI-score: > #{$miscore_q}"
report.puts "# Networks depth: 2"
report.puts "# Total Networks: #{$networks_arr.length}"
report.puts "\n\n"

$report_data = $interaction_network.net_members
$report_data.keys.each_with_index do |key, index|
	nt = index + 1
#	if index < 3
		report.puts "----------------------------------------\n"
		report.puts ".-> Network #{nt} has the following genes #{$report_data[key].length}:\n\n"
		i = 0
		$report_data[key].each do |gene|
			i += 1
			report.puts "#{i}. Gene ID: #{$annotated_members_array[0].getInfo(gene)[0]}"
			report.puts "-> Protein IDs: #{$annotated_members_array[0].getInfo(gene)[2]}"
			report.puts "-> KEGG ID and pathways: #{$annotated_members_array[0].getInfo(gene)[3]}"
			report.puts "-> GO ID and pathways: #{$annotated_members_array[0].getInfo(gene)[4]}"
			report.puts "-> Interactions with genes from the co-expressed file: #{($annotated_members_array[0].getInfo(gene)[5])&$gene_arr}"
			report.puts "-> Networks: #{$annotated_members_array[0].getInfo(gene)[1]}"
			report.puts "\n\n"
		end
#	end
end
report.puts "\n\n# End report"
report.close
puts "End report generation"
puts "..."
puts "Save file as #{output_file_name}"