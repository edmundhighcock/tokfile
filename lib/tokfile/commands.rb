
class TokFile
	class << self

		#######################################
		# Class methods that implement commands
		#######################################

		def display_summary_graph(inputfile, copts)
			summary_graphkit(inputfile, copts).gnuplot
		end

		###############################
		# Other class methods
		###############################


		def file_object(file, format)
			case format
			when 'eqdsk'
				TokFile::Eqdsk.new(file)
			else
				raise "Can't read this file format yet: #{format}"
		  end
		end

		def summary_graphkit(inputfile, copts)
			file_object(inputfile, copts[:f]).summary_graphkit
		end
	end
end
