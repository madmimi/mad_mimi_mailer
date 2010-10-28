require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SynchronizationParametersTest < Test::Unit::TestCase
  
  def test_default_sleep_time_set_to_1_sec
    MadMimiMailer.synchronization_settings = {}
    assert_equal MadMimiMailer.max_sleep, 1    
  end                                          
                                               
  def test_default_max_attempts_set_to_5       
    MadMimiMailer.synchronization_settings = {}
    assert_equal MadMimiMailer.max_attempts, 5 
  end                                          
                                               
  def test_can_set_sleep_time                  
    MadMimiMailer.synchronization_settings = { :sleep_between_attempts => 2 }
    assert_equal MadMimiMailer.max_sleep, 2    
  end                                          
                                               
  def test_can_set_number_max_attempts         
    MadMimiMailer.synchronization_settings = { :number_attempts => 3 }
    assert_equal MadMimiMailer.max_attempts, 3 
  end                                          
                                               
  def test_bad_sleep_value_defaults_to_1_sec   
    MadMimiMailer.synchronization_settings = { :sleep_between_attempts => 0.3 }
    assert_equal MadMimiMailer.max_sleep, 1    
  end                                          
                                               
  def test_bad_numer_attempts_defaults_to_5    
    MadMimiMailer.synchronization_settings = { :number_attempts => 30 }
    assert_equal MadMimiMailer.max_attempts, 5 
  end
  
end