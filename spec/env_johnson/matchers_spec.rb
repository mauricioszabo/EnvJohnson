require "spec/helper"

describe 'Custom matchers' do
  it 'should match when replacing text' do
    js_code = "document.getElementById('example').innerHTML = 'Changed'"
    js_code.should replace_inner_html_of(:example)
    js_code.should_not replace_inner_html_of(:example2)
  end

  it 'should match replaced text' do
    js_code = "document.getElementById('example').innerHTML = 'Changed'"
    js_code.should replace_inner_html_of(:example, :with => 'Changed')
  end
end
