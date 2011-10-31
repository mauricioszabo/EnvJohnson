require "spec/helper"

describe Matchers::Elements do
  let(:link_js) { 
    <<-EOF
      function remote() {
        xmlhttp=new XMLHttpRequest();
        xmlhttp.open("GET","example?id=20&ba=foo%20bar",true);
        xmlhttp.send();
      }

      document.getElementById('example').innerHTML = "<a href='#' onClick='javascript:remote();return false'>Example Link</a>";
    EOF
  }

  let(:button_js) { 
    <<-EOF
      document.getElementById('example').innerHTML = "<input type='submit' value='example' onClick='javascript:remote()' />";
    EOF
  }

  it 'should identify a link on page' do
    js_for link_js do |js|
      js.should have_link('Example Link')
      js.should_not have_link('Example2 Link')
    end
  end

  it 'should identify where a link sends' do
    js_for link_js do |js|
      js.should have_link('Example Link').to("example")
      js.should_not have_link('Example Link').to("example").with_params(:ex=>1)
      js.should_not have_link('Example Link').to("example2")
    end
  end

  it 'should identify a button on a page' do
    js_for button_js do |js|
      js.should have_button("example")
    end
  end
end
