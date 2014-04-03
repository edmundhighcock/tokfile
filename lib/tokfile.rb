
# A tool for reading, manipulating and converting files containing 
# tokamak data.

require 'getoptlong'

module CommandLineFlunky
	
	STARTUP_MESSAGE = "\n------Tokamak File Utility (c) Edmund Highcock------"

	MANUAL_HEADER = <<EOF
			
-------------Tokamak File Utility Manual---------------

  Written by Edmund Highcock (2014)

NAME

  tokfile


SYNOPSIS
	
  tokfile <command> [arguments] [options]


DESCRIPTION
	
  Convert, manipulate and display files containing tokamak-like data, for example
  EQDSK, tokamak profile database, iterdb output files from one-two etc. 
  
EXAMPLES

  $ tokfile convert EQDSK ogyropsi.dat -f eqdsk,ogyropsi

  $ tokfile merge ogyropsi.dat,ogyropsi2.dat ogyropsi3.dat -f ogyropsi -m profiles,geometry

  $ tokfile disp EQDSK -f eqdsk 
   
   
EOF
	
	COMMANDS_WITH_HELP = [
		['convert', 'cv', 2,  'Convert files of one format into another. Not all file formats contain the same information. If information is missing from the input files, a warning will be printed and tokfile will attempt to fill in the gaps using sensible assumptions like Ti/Te = 1. More than one output file can be specified.', ['inputfile', 'outputfile(s)'], [:f, :t]],
		['display_summary_graph', 'disp', 1,  'Display a summary graph of the file using gnuplot.', ['inputfile',], [:f]],
		['merge', 'mg', 2,  'Merge data from two input files to create a single output file. ', ['inputfile', 'outputfile(s)'], [:f, :t, :m]],
		['write_summary_graph', 'wsg', 2,  'Write a summary graph of the file to disk using gnuplot. The file format is determined by the extension of the graph file', ['inputfile', 'graph file'], [:f]],

	]
	
	SUPPORTED_FORMATS = ['eqdsk', 'ogyropsi']
	SUPPORTED_MERGE_SOURCES = ['profiles', 'geometry']


	COMMAND_LINE_FLAGS_WITH_HELP = [
		#['--boolean', '-b', GetoptLong::NO_ARGUMENT, 'A boolean option'],		
		['--formats', '-f', GetoptLong::REQUIRED_ARGUMENT, "A list of formats pertaining to the various input and output files (in the order which they appear), separated by commas. If they are all the same, only one value may be given. If a value is left empty (i.e. there are two commas in a row) then the previous value will be used. Currently supported formats are #{SUPPORTED_FORMATS.inspect}. "],		
		['--merge-sources', '-m', GetoptLong::REQUIRED_ARGUMENT, "A list of which bits of information should come from which input file during a merge. Currently supported merge sources are #{SUPPORTED_MERGE_SOURCES.inspect} "],		

		]

	LONG_COMMAND_LINE_OPTIONS = [
	#["--no-short-form", "", GetoptLong::NO_ARGUMENT, %[This boolean option has no short form]],
	] 
		
	# specifying flag sets a bool to be true

	CLF_BOOLS = []

	CLF_INVERSE_BOOLS = [] # specifying flag sets a bool to be false
	
	PROJECT_NAME = 'tokfile'
		
	def self.method_missing(method, *args)
# 		p method, args
		TokFile.send(method, *args)
	end
	
	#def self.setup(copts)
		#CommandLineFlunkyTestUtility.setup(copts)
	#end
	
	SCRIPT_FILE = __FILE__
end

class TokFile
	class << self
		# This function gets called before every command
		# and allows arbitrary manipulation of the command
		# options (copts) hash
		def setup(copts)
			# None neededed
	  end
		def verbosity
			2
		end
	end
end

$has_put_startup_message_for_code_runner = true
require 'coderunner'
require 'tokfile/commands'
require 'tokfile/eqdsk'

######################################
# This must be at the end of the file
#
require 'command-line-flunky'
###############################
