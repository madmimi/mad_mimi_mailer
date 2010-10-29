require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SynchronousMadMimiMailerTest < Test::Unit::TestCase

  def setup
    ActionMailer::Base.deliveries.clear
    
    MadMimiMailer.synchronization_settings = { :synchronous => true}
    MadMimiMailer.stubs(:sleep_period).returns(0)
    
    @ok_reponse = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @ok_reponse.stubs(:body).returns('123435')
    
    @ok_get_response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @ok_get_response.stubs(:body).returns('ignorant', 'sending', 'sent')
  end
  
  def test_synchronous_custom_promotion
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \nmessage: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)
    
    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )
    MadMimiMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@ok_get_response)

    MadMimiMailer.deliver_mimi_hola("welcome to mad mimi")
  end

  def test_synchronous_happy_path
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \nmessage: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )
    MadMimiMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@ok_get_response)

    promotion_attempt_id = MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    assert_equal "123435", promotion_attempt_id
  end
  
  def test_synchronous_raises_exception_if_max_attempts_exceeded
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \nmessage: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    @exceeded_get_response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @exceeded_get_response.stubs(:body).returns('ignorant')

    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )
    MadMimiMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@exceeded_get_response)
    MadMimiMailer.stubs(:timeout_period).returns(0.1)    
    assert_raise(MadMimiMailer::TimeoutExceeded) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end
  
  def test_synchronous_raises_exception_if_failed_status_returned
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \nmessage: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    @failed_get_response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @failed_get_response.stubs(:body).returns('ignorant', 'sending', 'failed')

    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )
    MadMimiMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@failed_get_response)
    
    assert_raise(Net::HTTPError) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end
  
  def test_synchronous_is_still_in_happy_path_if_opted_out_status_returned
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \nmessage: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    @opt_out_get_response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @opt_out_get_response.stubs(:body).returns('ignorant', 'sending', 'opted_out')

    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )
    MadMimiMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@opt_out_get_response)
    
    assert_nothing_raised do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end
  
  def test_synchronous_blank_bcc
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello_sans_bcc",
      'recipients' =>     "tyler@obtiva.com",
      'bcc' =>            nil,
      'subject' =>        "welcome to mad mimi",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \nmessage: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)
  
    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )
    MadMimiMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@ok_get_response)
  
    MadMimiMailer.deliver_mimi_hello_sans_bcc("welcome to mad mimi")
  end
  
  def test_synchronous_erb_render
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "w00t",
      'recipients' =>     "tyler@obtiva.com",
      'bcc' =>            nil,
      'subject' =>        "welcome to mad mimi",
      'from' =>           "dave@obtiva.com",
      'raw_html' =>       "hi there, welcome to mad mimi [[peek_image]]",
      'hidden' =>         nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )
    MadMimiMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@ok_get_response)
  
    MadMimiMailer.deliver_mimi_hello_erb("welcome to mad mimi")
  end
  
  def test_synchronous_multipart_erb_render
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => 'w00t',
      'recipients' =>     "sandro@hashrocket.com",
      'bcc' =>            nil,
      'subject' =>        "welcome to mad mimi",
      'from' =>           "stephen@hashrocket.com",
      'raw_html' =>       "hi there, welcome to mad mimi [[tracking_beacon]]",
      'raw_plain_text' => "hi there, welcome to mad mimi!",
      'hidden' =>         nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )
    MadMimiMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@ok_get_response)
  
    MadMimiMailer.deliver_mimi_multipart_hello_erb("welcome to mad mimi")
  end
  
  def test_synchronous_delivers_contain_unconfirmed_param_if_unconfirmed_is_set
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'body' => "--- \nmessage: welcome unconfirmed user\n",
      'promotion_name' => "woot",
      'recipients' =>     'egunderson@obtiva.com',
      'bcc' =>            nil,
      'subject' =>        "welcome unconfirmed user",
      'from' =>           "mimi@obtiva.com",
      'hidden' =>         nil,
      'unconfirmed' =>    '1'
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)
  
    get_mock_request = mock("get_request")
    get_mock_request.expects(:set_form_data).at_least_once.with(
      'api_key' =>  "w00tb4r",
      'username' => "testy@mctestin.com"
    )
    MadMimiMailer.expects(:status_get_request).at_least_once.with('123435').yields(get_mock_request).returns(@ok_get_response)
  
    MadMimiMailer.deliver_mimi_unconfirmed("welcome unconfirmed user")
  end
  
  def test_synchronous_deliveries_contain_tmail_objects_when_use_erb_in_test_synchronous_mode
    ActionMailer::Base.delivery_method = :test
    MadMimiMailer.deliver_mimi_multipart_hello_erb("welcome to mad mimi")
    ActionMailer::Base.delivery_method = :smtp
  
    assert ActionMailer::Base.deliveries.all?{|m| m.kind_of?(TMail::Mail)}
  end
  
  def test_synchronous_erb_render_fails_without_peek_image
    assert_raise MadMimiMailer::ValidationError do
      MadMimiMailer.deliver_mimi_bye_erb("welcome to mad mimi")
    end
  end
  
  def test_synchronous_bad_promotion_name
    mock_request = mock("request")
    mock_request.stubs(:set_form_data)
    response = Net::HTTPNotFound.new('1.2', '404', 'Not found')
    response.stubs(:body).returns("Could not find promotion by that name")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)
  
    assert_raise(Net::HTTPServerException) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end
  
  def test_synchronous_no_more_audience_space
    mock_request = mock("request")
    mock_request.stubs(:set_form_data)
    response = Net::HTTPPaymentRequired.new('1.2', '402', 'Payment required')
    response.stubs(:body).returns("Please upgrade")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)
  
    assert_raise(Net::HTTPServerException) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end
  
  def test_synchronous_no_mailer_api_enabled
    mock_request = mock("request")
    mock_request.stubs(:set_form_data)
    response = Net::HTTPUnauthorized.new('1.2', '401', 'Unauthorized')
    response.stubs(:body).returns("Please get an mailer api subscription")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)
  
    assert_raise(Net::HTTPServerException) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end
  
  def test_synchronous_normal_non_mimi_email
    ActionMailer::Base.delivery_method = :test
    MadMimiMailer.expects(:post_request).never
    MadMimiMailer.deliver_normal_non_mimi_email    
    ActionMailer::Base.delivery_method = :smtp
  end
  
  def test_synchronous_assert_mail_sent
    ActionMailer::Base.delivery_method = :test
    MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    ActionMailer::Base.delivery_method = :smtp
  
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal "MadMimiMailer", ActionMailer::Base.deliveries.last.class.name
  end
end