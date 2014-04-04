
class TokFile::Ogyropsi
	def initialize(file)
		@lines = File.read(file).split("\n")
		#for i in 1...@lines.size
		vb2 = TokFile.verbosity > 1
		if vb2
			eputs
			eputs "Reading data from ogyropsi file #{file}."
			eputs
		end
	  i = 0
		sz = @lines.size
		total_size = 0
		while i < sz

			var = @lines[i].gsub(/\s/, '').downcase.to_sym
			var = :pr if var == :p
			j=i+1
			j+=1 while j < sz and not @lines[j][0] =~ /^[A-Za-z]/
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
#{file}
with the following parameters:

npsi = #@npsi
nchi = #@nchi
-----------------------------------------
EOF

		end

		def summary_graphkit
			multkit = GraphKit::MultiWindow.new([:pr, :dpdpsi, :f, :fdfdpsi, :q].map{|name|
				kit = GraphKit.quick_create([@psi, send(name)])
				kit.title = name.to_s
				kit.ylabel = nil
				kit.xlabel = 'psi'
				kit
			})
		  multkit.gp.multiplot = "layout 2,3"
			kit = @npsi.times.map{|i| GraphKit.quick_create([@r.col(i), @z.col(i)])}.sum
			multkit.push kit
			multkit
		end






	end
end
