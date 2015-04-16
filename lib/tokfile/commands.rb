
class TokFile
	class << self

		#######################################
		# Class methods that implement commands
		#######################################

		def display_summary_graph(inputfiles, copts)
			summary_graphkit(inputfiles, copts).gnuplot
		end

		def merge(inputfiles, outputfile, copts)
			inputfiles = inputfiles.split(/,/)
			formats = copts[:f].split(/,/)
			formsize = inputfiles.size + 1
			case formats.size
			when 1
				formats = formats * formsize
			when formsize 
			else
				raise "Number of formats should be either 1 for all the same or #{formsize}"
			end
			raise "Please specify merges as a comma separated list" unless copts[:m].kind_of? String and copts[:m] =~ /,/
			merges = copts[:m].split(/,/)
			raise "Please specify the same number of merges as inputfiles" unless merges.size == inputfiles.size
			output = file_object(outputfile, formats[inputfiles.size] )
			inputfiles.each_with_index do |file,i|
				input = file_object(file, formats[i])
				output.read_data(input, merges[i], copts[:t])
			end
			output.write
		end

		def write_summary_graph(inputfiles, graphname, copts)
			summary_graphkit(inputfiles, copts).gnuplot_write graphname
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
			kit = inputfiles.map{|inputfile|
				file_object(inputfile, copts[:f]).summary_graphkit
			}.inject{|o,n| o.merge(n)}
      kit.instance_eval(copts[:w]) if copts[:w]
      kit
		end
	end
end
