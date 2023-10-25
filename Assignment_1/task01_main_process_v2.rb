#!/usr/bin/env ruby


# cd /home/oliverio/Downloads/Candela/EjercicioRuby_25/
# ruby task01_main_process_v2.rb
# irb -r ./task01_main_process_v2.rb
# https://ib.bioninja.com.au/higher-level/topic-10-genetics-and-evolu/102-inheritance/chi-squared-test.html


# INIT Variables

# @process
use_default_values = false
run_process = false

# @simulacion
# nro de gramos de la simulacion, 7 en nuestro caso NOTA: variable NO global, hay que pasarsela al metodo
grams = 7
# en caso de no tener stock suficiente, plantamos igual?
$planting_anyway = true
# actualizamos la fecha de ultima plantacion en el fichero de salida?
$update_last_planted = true
# creamos fichero de salida con datos actualizados?
$create_new_stock_file = true

# Get data from user
puts "Default process values:"
puts "->  Grams destined to perform the planting: #{grams} grams"
puts "->  Execute the planting with less stock anyway: Yes"
puts "->  Update Last_Planted value: Yes"
puts "->  Create new stock file: Yes"
print "Use defaults values? [Y/n] "
use_default_values_input = gets.chomp

case 
when use_default_values_input == ""
	use_default_values = true
	run_process = true
when use_default_values_input.downcase == "y"
	use_default_values = true
	run_process = true
when use_default_values_input.downcase == "n"
	use_default_values = false
	run_process = true
else
	puts "The value entered is incorrect"
	puts "The simulation will not run"
	use_default_values = false
	run_process = false
end

if !use_default_values && run_process

	# seteamos los gramos
	print "Grams destined to perform the planting? "
	grams_input = gets.chomp
	if grams_input.to_i != 0

		# seteamos grams
		grams = grams_input

		# en caso de no tener stock suficiente, plantamos igual?
		print "If the stock of any seed is less than #{grams_input}, execute the planting anyway? [Y/n] "
		planting_anyway_input = gets.chomp.to_s
		if planting_anyway_input == "" || planting_anyway_input.downcase == "y"
			#puts "Setting planting_anyway to true"
			$planting_anyway = true
		else
			if planting_anyway_input.downcase != "n"
				puts "The input #{planting_anyway_input} has been interpreted as no"
			end
			#puts "Setting planting_anyway to false"
			$planting_anyway = false
		end

		# actualizamos la fecha de ultima plantacion en el fichero de salida?
		print "Update Last_Planted value? [Y/n] "
		update_last_planted_input = gets.chomp.to_s
		if update_last_planted_input == "" || update_last_planted_input.downcase == "y"
			#puts "Setting update_last_planted to true"
			$update_last_planted = true
		else
			if update_last_planted_input.downcase != "n"
				puts "The input '#{update_last_planted_input}' has been interpreted as no"
			end
			#puts "Setting update_last_planted to false"
			$update_last_planted = false
		end

		# creamos fichero de salida con datos actualizados?
		print "Create new stock file with updated data? [Y/n] "
		create_new_stock_file_input = gets.chomp.to_s
		if create_new_stock_file_input == "" || create_new_stock_file_input.downcase == "y"
			#puts "Setting create_new_stock_file to true"
			$create_new_stock_file = true
		else
			if create_new_stock_file_input.downcase != "n"
				puts "The input '#{create_new_stock_file_input}' has been interpreted as no"
			end
			#puts "Setting create_new_stock_file to false"
			$create_new_stock_file = false
		end

	else
		puts "The value entered is zero (0) or a String"
		puts "The simulation will not run"
		run_process = false
	end

end

if run_process

	puts "Initiating process ..."
	puts ""

	# incluimos la libreria date, necesaria para actualizar la fecha de la ultima plantacion y el nombre del fichero de salida
	require "date"
	# fecha de hoy 
	$today = DateTime.now.strftime("%d/%m/%Y")
	# nombre fichero de salida
	$new_stock_file_tsv = "new_stock_file_#{DateTime.now.strftime("%Y%m%d%H%M")}.tsv"

	# @classes
	# cabecera de los ficheros
	$cross_data_header = []
	$gene_information_header = []
	$seed_stock_data_header = ""
	# hashes que contendran los objetos (globales)
	$cross_data = {}
	$gene_information = {}
	$seed_stock_data = {}

	# @chi-squared
	$chi_squared_data = {}

	# show mensages
	$err_prnt = true
	$wrng_prnt = true
	$ntc_prnt = true
	$msg_prnt = true

	# convertimos la entrada a int
	grams = grams.to_i
	# grams string
	$grams_str = (grams == 1) ? "gram" : "grams"

	# cargamos fichero con la definicion de las clases
	require "./task01_classes.rb"
	# cargamos fichero con los metodos del proceso
	require "./task01_process_methods.rb"
	# cargamos fichero con los metodos de consulta
	require "./task01_query_methods.rb"

	# inciamos @simulacion
	$planting_simulation_status = plantingSimulation(grams)

	# calculo Chi-Squared Test
	$chi_squared_status = chiSquaredTest

	puts ""

	if $planting_simulation_status
		if $create_new_stock_file
			puts "Created new file #{$new_stock_file_tsv}"
		else
			puts "No new file has been created (create_new_stock_file = false)"
		end
	end


	if $planting_simulation_status && $chi_squared_status
		puts "Process completed"
	else
		puts "Some processes have not been completed"
	end

	puts ""

end

=begin

# CONSULTAS

.- desde el terminal, cargamos el fichero 

		irb -r ./task01_main_process_v2.rb

.- ejecutamos las consultas, por ejemplo

getCrossDataAllData
getCrossDataChiSquared("B52")

getGeneInformationAllData
getGeneInformationGeneName("B3334")
getGeneInformationMutantPhenotype("A51")
getGeneInformationLinkedTo("A348")


getSeedStockAllData
getSeedStockMutantGeneId("A51")
getSeedStockLastPlanted("B3334")
getSeedStockStorage("A334")
getSeedStockGramsRemaining("A348")
searchSeedStockLastPlanted("23/10/2023")


=end
