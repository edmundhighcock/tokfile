
class TokFile
	class << self

		#######################################
		# Class methods that implement commands
		#######################################

		def display_summary_graph(inputfiles, copts)
			summary_graphkit(inputfiles, copts).gnuplot
		end

		###############################
		# Other class methods
		###############################


		def file_object(file, format)
			case format
			when 'eqdsk'
				TokFile::Eqdsk.new(file)
			when 'ogyropsi'
				TokFile::Ogyropsi.new(file)
			else
				raise "Can't read this file format yet: #{format}"
		  end
		end

		def summary_graphkit(inputfiles, copts)
			raise 'Only one format allowed for summary_graphkit ' if copts[:f] =~ /,/
			inputfiles = inputfiles.split(',')
			inputfiles.map{|inputfile|
				file_object(inputfile, copts[:f]).summary_graphkit
			}.inject{|o,n| o.merge(n)}
		end
	end
end
