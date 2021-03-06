require 'helper'

class TestTokfileEqdsk < MiniTest::Test
	def test_eqdsk_read
		nr = 100
		eq = TokFile::Eqdsk.new('test/data/EQDSK')
		assert_equal(nr, eq.nzbox)
		assert_equal(nr, eq.nrbox)
		assert_equal(1.0, eq.b0exp)
		assert_equal(6.870049145e+04,eq.current)
		assert_equal(0.9876379625, eq.t[4])
		assert_equal(12429.40334, eq.pr[4])
		assert_equal(5.055122666E+00, eq.pr[-1])
		assert_equal(1.269946123,eq.rbound[2])
		assert_equal(0.5079056676,eq.ttprime[1])
	end
	#def test_eqdsk_display
		#TokFile.write_summary_graph('test/data/EQDSK', 'eqdsk.ps', f: 'eqdsk')
#
	#end
  def test_eqdsk_dummy_convert
		TokFile.convert('test/data/EQDSK', 'test/data/EQDSK_OUT', f: 'eqdsk')
		TokFile.convert('test/data/EQDSK_NO_BOUNDARY', 'test/data/EQDSK_OUT_FIXED', f: 'eqdsk')
		TokFile.display_summary_graph('test/data/EQDSK_OUT_FIXED,test/data/EQDSK', f: 'eqdsk')
  end

	#def test_ogyropsi_read
		#og = TokFile::Ogyropsi.new('test/data/ogyropsi.dat')
		#assert_equal(og.npsi, 41)
	#end
	#def test_ogyropsi_display
		#TokFile.write_summary_graph('test/data/ogyropsi.dat,test/data/ogyropsi.dat', 'ogyropsi.ps', f: 'ogyropsi')
	#end
	#def test_merge
		#TokFile.merge('test/data/ogyropsi.dat,test/data/ogyropsi_nobal.dat', 'test/data/ogyropsi_out.dat', f: 'ogyropsi', m: 'all,profiles')
		#TokFile.display_summary_graph('test/data/ogyropsi_out.dat,test/data/ogyropsi.dat,test/data/ogyropsi_nobal.dat', f: 'ogyropsi')
	#end
end
