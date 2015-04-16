
# A class for interacting with files of format ogyropsi,
# an input format for GENE and GYRO that is output by CHEASE
#
class TokFile::Ogyropsi
	# Create the object. Read data from filename if it exists.
	# Otherwise do nothing.
	def initialize(filename)
		@filename = filename
		return unless FileTest.exist? @filename
		@lines = File.read(filename).split("\n")
		#for i in 1...@lines.size
		vb2 = TokFile.verbosity > 1
		if vb2
			eputs
			eputs "Reading data from ogyropsi filename #{filename}."
			eputs
		end
	  i = 0
		sz = @lines.size
		total_size = 0
		while i < sz

			var = @lines[i].gsub(/\s/, '').downcase.to_sym
			var = :pr if var == :p
			j=i+1
			j+=1 while j < sz and not @lines[j][0] =~ /^\s*[A-Za-z]/
			val = @lines.slice(i+1...j).join(' ').sub(/\A\s+/, '').sub(/\s+\Z/, '').split(/\s+/).map{|s| eval(s)}
			vsz = val.size
			total_size += vsz
			if vb2
				Terminal.erewind(1)
				eputs "#{var}(#{vsz})#{Terminal::CLEAR_LINE}" if vb2
			end
			self.class.attr_accessor var
			case val.size
			when 1
				set(var, val[0])
			when @npsi, @nchi
				set(var, val.to_gslv)
			when @npsi*@nchi
				set(var, GSL::Matrix.alloc(*val.pieces(@nchi)))
			else
				raise "Unknown size for #{var}"
			end
			i=j
		end	

		if vb2
		  Terminal.erewind(1)
			eputs  "Read total data size of #{total_size.to_f * 8.0/1.0e6} MB"
		end
		if TokFile.verbosity > 0
		eputs <<EOF
-----------------------------------------
                 Tokfile
-----------------------------------------
Successfully read an ogyropsi file called
#{filename}
with the following parameters:

npsi = #@npsi
nchi = #@nchi
-----------------------------------------
EOF

		end

		# A GraphKit::MultiKit containing summary information about the 
		# contents of the file.
		def summary_graphkit
			multkit = GraphKit::MultiKit.new([:pr, :dpdpsi, :f, :fdfdpsi, :q, :shear, :ti, :te].map{|name|
				kit = GraphKit.quick_create([@psi, send(name)])
				kit.title = name.to_s
				kit.ylabel = nil
				kit.xlabel = 'psi'
				kit
			})
		  multkit.gp.multiplot = "layout 3,3"
			kit = @npsi.times.map{|i| GraphKit.quick_create([@r.col(i), @z.col(i)])}.sum
			kit.data.each{|dk| dk.gp.with = 'l'}
			multkit.push kit
			multkit
		end

		# Read selected data from the given file object,
		# overwriting current values where present.
		def read_data(file_object, data_group, time)
			# Convert to an object of class Tokfile::Ogyropsi if necessary
			file_object = file_object.internal_representation(time).to_ogyropsi unless file_object.kind_of? TokFile::Ogyropsi
			VARIABLES.each do |var|
				next unless in_data_group(data_group, var)
				varname = instance_varname(var)
				if data_group=="all"
				 	set(varname, file_object.send(varname)) if file_object.send(varname)
				else
					if file_object.send(varname)
						input = file_object.send(varname)
						case input
						when Integer, Float
							set(varname, input)
						when GSL::Vector
							case input.size
							when file_object.npsi
								#interp = GSL::Interp.alloc('cspline', file_object.npsi)
								#ep [file_object.psi.max, file_object.psi.min, @psi.max, @psi.min, 'end']
								#ep input
								#set(varname, interp.eval(file_object.psi, input, @psi))
								interp = GSL::ScatterInterp.alloc(:linear, [file_object.psi, input], false)
								set(varname, @psi.collect{|ps| interp.eval(ps)})
							end
						end
					end
				end

			end

		end

		def instance_varname(var)
				varname = var.downcase.to_sym
				varname = :pr if varname == :p
				varname
		end

		def in_data_group(data_group, var)
			return true if data_group == "all"
			case var
			when /D?[NT][IE](DPSI)?/i, /ZEFF/i, /^p$|dpdpsi/i
				data_group == 'profiles'
			else
				data_group == 'geometry'
			end
		end

		# Write contents to @filename
		def write
			File.open(@filename, 'w') do |file|
				VARIABLES.each do |var|
				  varname = instance_varname(var)
					file.puts var
					val = send(varname)
					case val
					when Integer, Float
						file.puts " #{val}"
					when GSL::Vector
						for i in 0...val.size
							file.print(sprintf(" %16.9E", val[i]))
							file.print("\n") if (i+1)%5 == 0
						end
						file.print("\n") unless val.size%5==0
					when GSL::Matrix
						# Note that fortran and hence this file is column major
						k = 0
							for i in 0...val.shape[0]
						for j in 0...val.shape[1]
								file.print(sprintf(" %16.9E", val[i,j]))
								file.print("\n") if (k+=1)%5 == 0
							end
						end
						file.print("\n") unless k%5==0
					end
				end
			end
		end






	end

	VARIABLES = %w{

NPSI
NCHI
R0EXP
B0EXP
PSI
CHI
Rgeom
ageom
q
dqdpsi
d2qdpsi2
p
dpdpsi
f
fdfdpsi
V
rho_t
shear
dsheardpsi
kappa
delta_lower
delta_upper
dVdpsi
dpsidrhotor
GDPSI_av
radius_av
R_av
TE                                                                                                                                  
DTEDPSI                                                                                                                             
NE                                                                                                                                  
DNEDPSI                                                                                                                             
TI                                                                                                                                  
DTIDPSI                                                                                                                             
NI                                                                                                                                  
DNIDPSI                                                                                                                             
ZEFF                                                                                                                                
SIGNEO                                                                                                                              
JBSBAV                                                                                                                              
g11
g12
g22
g33
B
dBdpsi
dBdchi
dPsidR
dPsidZ
dChidR
dChidZ
Jacobian
R
Z

	}
end
