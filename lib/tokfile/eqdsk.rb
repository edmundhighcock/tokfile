
class TokFile::Eqdsk
	attr_accessor :nrbox, :nzbox
	#attr_accessor :rboxlen, :zboxlen, :r0exp, :rboxlft
	DATANAMES = [
		:rboxlen, :zboxlen, :r0exp, :rboxlft, :dummy,
		:raxis, :zaxis, :psiaxis, :dummy, :b0exp,
		:current, :dummy, :dummy, :dummy, :dummy,
		:dummy, :dummy, :dummy, :dummy, :dummy,
		:t, 
		:pr, 
		:ttprime, 
		:pprime, 
		:psi, 
		:q, 
		:nbound, :nlimiter, 
		:bound,
	  :limiter
	]
	attr_accessor :rbound, :zbound, :rlimiter, :zlimiter, :nbound, :nlimiter, :bound, :limiter
	
	require 'scanf'
	def read(line)
			#@lines_columns[i] = @lines[i].split(/\s+|(?<=\d)[+-]/).map{|s| eval(s)}
		line.sub(/\A\s+/, '').sub(/\s+\Z/, '').split(/\s+|(?<=\d)(?=[+-])/).map{|s| eval(s)}
		#line.scan(/.{15}/).map{|s| eval(s)}
		
		#ep ['line', line]
		#arr = []
		#res = line.scanf("%16.9E"){|n| arr.push n}
		#line.scanf("%E"){|n| arr.push n[0]}
		#ep ['res', res, arr]
		#ep ['res', arr]
		#arr

	end

  def convert(format)
    case format
    when 'eqdsk'
      self.dup
    else
      raise "Conversion from eqdsk to #{format} not implemented yet"
    end
  end


	def initialize(file)

		iline = 0
		counter = 0

		#filehandle = File.open(file, 'r')

		lines = File.read(file).split("\n")
		#@datastarts = DATANAMES.inject({}){|h, name| h[name] = nil; h}

		#line1 = filehandle.gets
		#@nrbox, @nzbox  = filehandle.gets.split(/\s+/).slice(-2..-1).map{|s| eval(s)}
		@nrbox, @nzbox  = lines[0].split(/\s+/).slice(-2..-1).map{|s| eval(s)}
		#@rboxlen, @zboxlen, @r0exp, @rboxlft, dummy = read(filehandle.gets)
		#@raxis, @zaxis, @psiaxis, dummy, @b0exp = read(filehandle.gets)
		#@current, dummy, dummy, dummy, dummy = read(filehandle.gets)
		#dummy, dummy, dummy, dummy, dummy = read(filehandle.gets)
		array = []
		i = 1
		vb2 = TokFile.verbosity > 1
		
		if vb2
			eputs
			eputs "Reading data from eqdsk file #{file}."
			eputs
		end
		total_size = 0
		DATANAMES.each do |name|
			sz = size(name)
			total_size += sz
			#ep ['name', name, 'size', sz]
			if vb2
				Terminal.erewind(1)
				eputs "#{name}(#{sz})#{Terminal::CLEAR_LINE}" if vb2
			end
			if array.size < sz
				#array += read(filehandle.gets)
				#array += read(lines[i])
				#i+=1
        begin
          array += read(lines.slice(i...(i+=(sz.to_f/5.0).ceil)).join(' '))
        rescue NoMethodError
          $stderr.puts "Finished reading at #{name}"
          break
        end
				#array += lines.slice(i...(i+=(sz.to_f/5.0).ceil)).join(' ')

				#filehandle.gets.scanf("%e"){|scan| array.push scan[0]}
			end
			if array.size == sz
				data = array
				array = []
			else
			  data = []
				while data.size < sz
					data.push array.shift
				end
			end
			self.class.attr_accessor name
			case name
			when :psi
				set(name, GSL::Matrix.alloc(*data.pieces(@nzbox)).transpose)
			when :bound
				data = data.pieces(@nbound).transpose
				set(:rbound, data[0].to_gslv)
				set(:zbound, data[1].to_gslv)
			when :limiter
				data = data.pieces(@nlimiter).transpose
				set(:rlimiter, data[0].to_gslv)
				set(:zlimiter, data[1].to_gslv)
			else
				case sz
				when 1
          #p [name, 'yy', data]
					set(name, data[0])
				else
          #p [name,'xx', data.inspect[0..2000]]
          #p [name,data.to_gslv.inspect[0..10]]
					set(name, data.to_gslv)
				end
			end
		end
		@r = GSL::Vector.linspace(@rboxlft, @rboxlft+@rboxlen, @nrbox)
		@z = GSL::Vector.linspace(-@zboxlen/2.0, @zboxlen/2.0, @nzbox)

		if vb2
		  Terminal.erewind(1)
			eputs  "Read total data size of #{total_size.to_f * 8.0/1.0e6} MB"
		end

		if TokFile.verbosity > 0
		eputs <<EOF
--------------------------------------
               Tokfile
--------------------------------------
Successfully read an eqdsk file called
#{file}
with the following parameters:

nrbox = #@nrbox
nzbox = #@nzbox
nbound = #@nbound
raxis = #@raxis
--------------------------------------
EOF

		end







		#@lines = File.read(file).split("\n").map{|str| str.sub(/\A\s+/, '').sub(/\s+\Z/, '')}
		#@nrbox, @nzbox  = @lines[0].split(/\s+/).slice(-2..-1).map{|s| eval(s)}
		#in_data = true; i = 1
		#@atoms = []
		#@lines_columns = []
		#while in_data
			#@lines_columns[i] = @lines[i].split(/\s+|(?<=\d)[+-]/).map{|s| eval(s)}
			#@atoms += @lines_columns[i]
			#if @nbound = @atoms[start(:nbound)] 
				#if @atoms.size > start(:limiter) 
					#in_data = false
				#end
			#end
			#i+=1
		#end

		#[:t, :p, :pprime, :ttprime, :psi, :q, :rzbound].each do |var|
			#attr_accessor var
			#st = start(var)
			#set(var, @atoms.slice(st...(st+@nrbox))).to_gslv
		#end


		#@rboxlen, @zboxlen, @r0exp, @rboxlft, dummy = @lines_columns[1]
		#ep ['lines_columns', @lines_columns[1], @lines[1]]
		

    if not send(:nbound)
      $stderr.puts("Boundary missing: trying to reconstruct")
      reconstruct_boundary
    end
	end
  FMT="%16.9e" * 5 + "\n"
  def write_file(filename)
    File.open(filename, 'w') do |file|
      printf(file, " EQDSK GEN.BY TOKFILE %d %d\n", @nrbox, @nzbox)
      array = []
      DATANAMES.each do |dname|
        next if [:zlimiter, :nlimiter].include? dname
        sz = size(dname)
        data = sz==1 ? [send(dname)] : send(dname).to_a
        case dname
        when :psi
          data = data.transpose.flatten
        when :bound
          data = [send(:rbound).to_a, send(:zbound).to_a].transpose.flatten
        when :limiter
          data = [send(:rlimiter).to_a, send(:zlimiter).to_a].transpose.flatten
        end
        unless dname==:nbound
          array += data
        end
        #p [dname]
        while array.size > 5 
          out = []
          5.times{out.push(array.shift)}
          printf(file, FMT, *out)
        end
        if [:nbound, :limiter].include? dname
          # Clear buffer
          printf(file, "%16.9e"*array.size + "\n", *array)
          array = []
        end
        if dname == :nbound
          printf(file, "%5d%5d\n", data[0], send(:nlimiter))
        end
      end
    end
  end
  def reconstruct_boundary
    require 'gsl_extras'
    $stderr.puts "Reconstructing boundary"
    contour = GSL::Contour.new(@r, @z, @psi)
	  #psikit = GraphKit.quick_create([@r, @z, @psi])
		#psikit.data[0].gp.with = 'pm3d'
		#psikit.gp.view = "map"
    ck = contour.graphkit(0.0)
    #psikit+= GraphKit.quick_create([ck.data[0].x.data, ck.data[0].y.data, ck.data[0].y.data.collect{0.0}])
    #psikit.gnuplot
    @nbound = @nlimiter = ck.data[0].x.data.size
    @rbound = @rlimiter = ck.data[0].x.data
    @zbound = @zlimiter = ck.data[0].y.data
  end
	def summary_graphkit
		psivec = GSL::Vector.linspace(@psi.min, 0.0, @nrbox)
		multkit = GraphKit::MultiWindow.new([:pr, :pprime, :t, :ttprime, :q].map{|name|
			kit = GraphKit.quick_create([psivec, send(name)])
			kit.title = name.to_s
			kit.ylabel = nil
			kit.xlabel = 'psi'
			kit
		})
	  psikit = GraphKit.quick_create([@r, @z, @psi])
		psikit.data[0].gp.with = 'pm3d'
		psikit.gp.view = "map"
		boundkit = GraphKit.quick_create([@rbound, @zbound, @rbound.collect{0.0}])
		psikit += boundkit
		psikit.gp.key = "off"
		psikit.title = 'psi'
		psikit.xlabel = 'R'
		psikit.ylabel = 'Z'
		multkit.push psikit
		multkit.gp.multiplot = "layout 2,3"
		multkit
	end
  def size(var)
		case var
		#when :nbound, :nlimiter
		 #1
		when :bound
		 @nbound * 2
		when :limiter
			@nlimiter * 2
		when :psi
		 @nrbox * @nzbox
		when :t, :pr, :pprime, :ttprime, :q 
		 @nrbox
		else
			1
		end
	end

	#def start(var)
		#case var
		#when :t
			#20
		#when :p
			#start(:t) + @nrbox
		#when :ttprime
			#start(:p) + @nrbox
		#when :pprime
			#start(:ttprime) + @nrbox
		#when :psi
			#start(:pprime) + @nrbox
		#when :q
			#start(:psi) + @nrbox * @nzbox
		#when :nbound
			#start(:q) + @nrbox + 1
		#when :rzbound
			#start(:q) + @nrbox + 3
		#when :limiter
			#start(:rzbound) + @nbound * 2
		#else
			#raise "Start of #{var} unknown"
		#end
	#end


	#def 
	#def get_int(line, col)
	#end
		

end
