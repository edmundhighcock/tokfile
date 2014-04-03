require 'helper'

class TestTokfileEqdsk < Test::Unit::TestCase
	def test_eqdsk_read
		nr = 400
		eq = TokFile::Eqdsk.new('test/data/EQDSK')
		assert_equal(nr, eq.nzbox)
		assert_equal(nr, eq.nrbox)
		assert_equal(1.0, eq.b0exp)
		assert_equal(6.870049145e+04,eq.current)
		assert_equal(9.863615364e-01, eq.t[4])
		assert_equal(1.355216574e+04, eq.pr[4])
		assert_equal(5.055122666E+00, eq.pr[-1])
		assert_equal(1.269946123,eq.rbound[2])
		assert_equal(-1.223339500E+00,eq.ttprime[1])
	end
	def test_eqdsk_display
		TokFile.display_summary_graph('test/data/EQDSK', f: 'eqdsk')

	end
end
