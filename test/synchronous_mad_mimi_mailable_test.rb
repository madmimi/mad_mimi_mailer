require File.dirname(__FILE__) + '/test_helper'

class VanillaMailer < ActionMailer::Base
  include MadMimiMailable

  self.template_root = File.dirname(__FILE__) + '/templates/'
  
  def hola(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    body :message => greeting    
  end
end

class ChocolateErbMailer < ActionMailer::Base
  include MadMimiMailable
  self.method_prefix = "sugary"
  self.use_erb = true

  self.template_root = File.dirname(__FILE__) + '/templates/'
  
  def sugary_hola(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    body :message => greeting    
  end
end

class SynchronousMadMimiMailableTest < Test::Unit::TestCase

  def setup
    ActionMailer::Base.deliveries.clear
    ActionMailer::Base.delivery_method = :smtp

    MadMimiMailer.synchronization_settings = { :synchronous => true}

    @ok_reponse = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @ok_reponse.stubs(:body).returns('123435')
    
    @ok_get_response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @ok_get_response.stubs(:body).returns('ignorant', 'sending', 'sent')
  end
  
  def teardown
    MadMimiMailer.synchronization_settings = { :synchronous => false}
  end

  def test_typical_synchronous_request
    VanillaMailer.stubs(:sleep_period).returns(0)
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hola",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            nil,
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \nmessage: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    VanillaMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)
    
    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )

    VanillaMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@ok_get_response)
    VanillaMailer.deliver_hola("welcome to mad mimi")
  end

  def test_synchronous_erb_request_with_custom_method_prefix
    ChocolateErbMailer.stubs(:sleep_period).returns(0)
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hola",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            nil,
      'from' =>           "dave@obtiva.com",
      'raw_html' =>       "hi there, welcome to mad mimi [[peek_image]]",
      'raw_plain_text' =>     nil,
      'hidden' =>         nil
    )
    ChocolateErbMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)
  
    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )

    ChocolateErbMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@ok_get_response)
  
    ChocolateErbMailer.deliver_sugary_hola("welcome to mad mimi")
  end

end
