require "spec/helper"

describe 'Custom matchers' do
  it 'should match when replacing text' do
    js_code = "document.getElementById('example').innerHTML = 'Changed'"
    js_for js_code do |js|
      js.should replace_inner_html_of(:example)
      js.should_not replace_inner_html_of(:example2)
    end
  end

  it 'should match replaced text' do
    js_code = "document.getElementById('example').innerHTML = 'Changed'"
    js_for js_code do |js|
      js.should replace_inner_html_of(:example).with('Changed')
      js.should_not replace_inner_html_of(:example).with('Original')
    end
  end
end
