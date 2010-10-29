require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SynchronizationParametersTest < Test::Unit::TestCase
  
  def test_sleep_time_set_to_1_sec
    assert_equal MadMimiMailer::SYNCHRONOUS_SLEEP, 1
  end

  def test_default_timeout_set_to_10
    assert_equal MadMimiMailer::SYNCHRONOUS_TIMEOUT, 10
  end
  
  def test_can_set_timeout
    MadMimiMailer.synchronization_settings = {:timeout => 5}
    assert_equal MadMimiMailer.timeout_period, 5
  end

end