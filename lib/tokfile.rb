
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
	
  This test utility is written to test the command-line-flunky gem.
  
EXAMPLES

   $ test_utility hello_world
   
   $ test_utility test_bool -b
   
EOF
	
	COMMANDS_WITH_HELP = [
		['hello_world', 'hello', 0, 'Say hello to the world', [], []],
		['test_bool', 'tbool', 0,  'Test whether the boolean flag works', [], [:b]],
		['test_arguments', 'args', 1,  'Test passing an argument to a command and an argument to an option', ['command_argument'], [:a]],

	]
	
	COMMAND_LINE_FLAGS_WITH_HELP = [
		['--boolean', '-b', GetoptLong::NO_ARGUMENT, 'A boolean option'],		
		['--argument', '-a', GetoptLong::REQUIRED_ARGUMENT, 'An option which requires an argument '],		

		]

	LONG_COMMAND_LINE_OPTIONS = [
	["--no-short-form", "", GetoptLong::NO_ARGUMENT, %[This boolean option has no short form]],
	] 
		
	# specifying flag sets a bool to be true

	CLF_BOOLS = [:b, :no_short_form]

	CLF_INVERSE_BOOLS = [] # specifying flag sets a bool to be false
	
	PROJECT_NAME = 'command_line_flunky_test_utility'
		
	def self.method_missing(method, *args)
# 		p method, args
		CommandLineFlunkyTestUtility.send(method, *args)
	end
	
	#def self.setup(copts)
		#CommandLineFlunkyTestUtility.setup(copts)
	#end
	
	SCRIPT_FILE = __FILE__
end

class CommandLineFlunkyTestUtility
	class << self
		def hello_world(copts)
			puts "Hello World"
		end
		def test_bool(copts)
			puts "Bool is #{copts[:b]}"
			puts "no-short-form is #{copts[:no_short_form]}"
		end
		def test_arguments(argument, copts)
			puts "command argument was #{argument} and option argument was #{copts[:a]}"
		end
		# This function gets called before every command
		# and allows arbitrary manipulation of the command
		# options (copts) hash
		def setup(copts)
			# None neededed
	  end
	end
end


######################################
# This must be at the end of the file
#
require 'command-line-flunky'
###############################
