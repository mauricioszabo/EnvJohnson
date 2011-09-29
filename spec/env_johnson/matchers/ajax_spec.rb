require "spec/helper"

describe Matchers::Ajax do
  let(:ajax_call) { 
    <<-EOF
      xmlhttp=new XMLHttpRequest();
      xmlhttp.open("GET","example",true);
      xmlhttp.send();
    EOF
  }

  it 'should identify an ajax call' do
    js_for ajax_call do |js|
      js.should be_an_ajax
      js.should be_an_ajax.to('example')
      js.should_not be_an_ajax.to(/example2/)
    end

    js_for("") { |js| js.should_not be_an_ajax }
  end
end
