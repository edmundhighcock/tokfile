require 'helper'

class TestTokfile < Test::Unit::TestCase
	def test_eqdsk_read
		nr = 400
		eq = TokFile::Eqdsk.new('test/data/EQDSK')
		assert_equal(nr, eq.nzbox)
		assert_equal(nr, eq.nrbox)
		assert_equal(1.0, eq.b0exp)
		assert_equal(1.269946123,eq.rbound[2])
	end
end
