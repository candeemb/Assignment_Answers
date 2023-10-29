#!/usr/bin/env ruby

# ruby task01_main_process.rb
# irb -r ./task01_main_process.rb
# https://ib.bioninja.com.au/higher-level/topic-10-genetics-and-evolu/102-inheritance/chi-squared-test.html


# incluimos la libreria date, necesaria para actualizar la fecha de la ultima plantacion
require "date"
# VARIABLES
# cabecera de los ficheros
$cross_data_header = []
$gene_information_header = []
$seed_stock_data_header = ""
# hashes que contendran los objetos (globales)
$cross_data = {}
$gene_information = {}
$seed_stock_data = {}
# @simulacion
# nro de gramos de la simulacion, 7 en nuestro caso NOTA: variable NO global, hay que pasarsela al metodo
grams = 7
# en caso de no tener stock suficiente, plantamos igual?
$planting_anyway = true
# actualizamos la fecha de ultima plantacion en el fichero de salida?
$update_last_planted = true
$today = DateTime.now.strftime("%d/%m/%Y")
# fichero de salida
$create_new_stock_file = true
$new_stock_file_tsv = "new_stock_file_#{DateTime.now.strftime("%Y%m%d%H%M")}.tsv"
# @chi-squared
$chi_squared_data = {}
# show mensages
$err_prnt = true
$wrng_prnt = true
$ntc_prnt = true
$msg_prnt = true


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

# definimos la Clase GeneInformation
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

# definimos la Clase SeedStockData
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


# METODOS
# metodo sencillo para restar
def minusValue(value, minus)
	value = value.to_i - minus.to_i
	return value
end

# metodo para simulacion de plantacion
def plantingSimulation(grams)

	# comprobamos que el fichero se ha cargado y si el objeto seed_stock_data tiene datos
	if $seed_stock_data.length > 0

		#puts "a plantar !"

		# recorremos los valores de $seed_stock_data
		$seed_stock_data.each do |clave, dato|
			#puts "#{clave} #{dato}" + dato.mutant_gene_id	# seed_stock   grams_remaining
			
			# convertimos el dato de gramos a un Integer
			grams_remaining = dato.grams_remaining.to_i
			
			# Escenarios:
				# puede haber 0					=> no se planta + WARNING
				# puede no haber suficiente		=> depende de $planting_anyway
				# puede quedarse en cero		=> se planta y se avisa
				# normal						=> se planta
			
			# Actualizar los datos: en cada caso podemos ....
				# actualizar directamente utilizando el objeto
					# dato.grams_remaining = grams_remaining - grams
					# dato.glast_planted = $today
				# o utilizando para la resta metodo minusValue(value, minus)
					# dato.grams_remaining = minusValue(grams_remaining, grams)
				# o mediante los metodos de la clase SeedStockData, que es lo que vamos a hacer

			# implementamos un case .. when
			case 
			when grams_remaining == 0

				if $wrng_prnt
					puts "WARNING: It is not possible to perform the #{dato.seed_stock} planting -> No stock (0)"
				end

			when grams_remaining < grams

				if $planting_anyway

					# actualizamos gramos
					dato.updateGramsRemaining(grams_remaining)

					# actualizamos fecha si true
					if $update_last_planted
						dato.updateLastPlanted
					end

					if $ntc_prnt
						puts "NOTICE: #{dato.seed_stock} planting performed with insufficient stock -> (planting_anyway = True)(#{grams_remaining} < #{grams})"
					end

				else

					if $ntc_prnt
						puts "NOTICE: It is not possible to perform the #{dato.seed_stock} planting due insufficient stock -> (planting_anyway = False)(#{grams_remaining} < #{grams})"
					end

				end

			when grams_remaining == grams

				# actualizamos gramos
				dato.updateGramsRemaining(grams)
				
				# actualizamos fecha si true
				if $update_last_planted
					dato.updateLastPlanted
				end

				if $ntc_prnt
					puts "NOTICE: #{dato.seed_stock} stock at zero (0) after perform the planting"
				end

			else

				# actualizamos gramos
				dato.updateGramsRemaining(grams)
				
				# actualizamos fecha si true
				if $update_last_planted
					dato.updateLastPlanted
				end

				if $msg_prnt
					puts "MESSAGE: Performed the #{dato.seed_stock} planting"
				end

			end

		end

		# si todo ha ido OK, generamos el fichero de salida con datos actualizados
		if $create_new_stock_file
			createNewStockFile
		else
			if $msg_prnt
				puts "MESSAGE: No new file has been created (create_new_stock_file = FALSE)"
			end
		end

	else

		if $err_prnt
			puts "ERROR! It is not possible to perform the simulation"
		end

	end

end

# metodo para generar un nuevo fichero tras simulacion
def createNewStockFile

	if $create_new_stock_file
		# definimos un array para almacenar las lineas
		updated_lines = []

		# cargamos el HEADER original
		updated_lines << $seed_stock_data_header

		# cargamos los datos desde el objeto
		$seed_stock_data.each do |clave, dato|
			#puts dato.seed_stock
			updated_lines << [dato.seed_stock, dato.mutant_gene_id, dato.last_planted, dato.storage, dato.grams_remaining].join("\t")
		end

		# creamos el fichero de salida y volcamos la informacion actualizada 
		File.open($new_stock_file_tsv, 'w') do |output_data_file|
			output_data_file.puts(updated_lines)
		end

		if $msg_prnt
			puts "MESSAGE: New file #{$new_stock_file_tsv} created"
		end
	end

end

# metodo para calcular chi-squared
def chiSquaredTest

	if $cross_data.length > 0

		# variables
		ratio9_16 = 9.0 / 16
		ratio3_16 = 3.0 / 16
		ratio1_16 = 1.0 / 16
		
		# minimum statistically significant value
		min_stat_signf_value = 7.815

		$cross_data.each do |clave, dato|

			# contador temporal de chi_squared
			chi_squared = 0

			# valor total observado
			observed_total = dato.f2_wild.to_i + dato.f2_p1.to_i + dato.f2_p2.to_i + dato.f2_p1p2.to_i
			
			# cargamos observed = dato de partida
			observed = [
				dato.f2_wild.to_i,
				dato.f2_p1.to_i,
				dato.f2_p2.to_i,
				dato.f2_p1p2.to_i
			]

			# calculamos expected = observed_total * ratioX_XX
			expected = [
					observed_total * ratio9_16,
					observed_total * ratio3_16,
					observed_total * ratio3_16,
					observed_total * ratio1_16
				]
			
			# calculamos diff = observed - expected (O - E)
			diff = [
					observed[0] - expected[0],
					observed[1] - expected[1],
					observed[2] - expected[2],
					observed[3] - expected[3]
				]
			
			# calculamos exponente 2 de diff (O - E)^2
			diffexp2 = [
					diff[0] ** 2,
					diff[1] ** 2,
					diff[2] ** 2,
					diff[3] ** 2
				]

			# definimos arr = diffexp2 / expected (O - E)^2/E
			arr = [
					diffexp2[0] / expected[0],
					diffexp2[1] / expected[1],
					diffexp2[2] / expected[2],
					diffexp2[3] / expected[3],
				]
			
			for i in arr do
				chi_squared = chi_squared + i
			end

			#puts "#{clave} > chi_squared = #{chi_squared}"

			# cargamos los datos en un hash, por las dudas
			$chi_squared_data[clave] = chi_squared

			# actualizamos el objeto CrossData
			$cross_data[clave].chi_squared = chi_squared

			if chi_squared >= min_stat_signf_value

				# almacenamos la relacion en gene_information.linked_to
				$gene_information[$seed_stock_data[clave].mutant_gene_id].linked_to = $seed_stock_data[dato.parent2].mutant_gene_id
				$gene_information[$seed_stock_data[dato.parent2].mutant_gene_id].linked_to = $seed_stock_data[clave].mutant_gene_id

				# mostramos mensajes
				puts "RECORDING: #{$gene_information[$seed_stock_data[clave].mutant_gene_id].gene_name} is genetically linked to #{$gene_information[$seed_stock_data[dato.parent2].mutant_gene_id].gene_name} with chi-square score #{chi_squared}"

			end
		
		# end del bucle
		end

		# Final Report
		finalReport

	else

		if $err_prnt
			puts "ERROR! It is not possible to calculate chi-squared"
		end

	end

end

# metodo FInal Report
def finalReport

	report = []
	$gene_information.each do |clave, dato|

		if dato.linked_to != ""
			report.push "#{$gene_information[dato.linked_to].gene_name} is linked to #{dato.gene_name}"
		end

	end

	puts "Final Report:"
	for i in report do
		puts i
	end

	if report.length == 0
		puts "There are no linked genes"
	end

end

# inciamos simulacion de plantacion
# grams = los gramos de esta siluacion
plantingSimulation(grams)

# calculo Chi-Squared Test
chiSquaredTest


