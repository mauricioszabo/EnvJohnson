require "spec/helper"

describe EnvJohnson do
  it 'should create a stubbed environment with a div' do
    js = EnvJohnson.new "", :body => "<div id='example'></div>"
    js.body.should have_tag("div#example")
  end

  it 'should change something on the page' do
    js_code = "document.getElementById('example').innerHTML = 'Changed!'"
    js = EnvJohnson.new js_code, :body => "<div id='example'></div>"
    js[:example].should == "Changed!"
  end

  it 'should save the last page' do
    js_code = "document.getElementById('example').innerHTML = 'Changed'"
    js = EnvJohnson.new js_code, :body => "<div id='example'>Before</div>"
    js.body.should match(/Changed/)
    js.body.should_not match(/Before/)

    js.body_before.should match(/Before/)
    js.body_before.should_not match(/Changed/)
  end

  it 'should create a new element if the JS references an unexistente element' do
    js_code = "document.getElementById('example').innerHTML = 'Changed!'"
    js = EnvJohnson.new js_code
    js.body.should have_tag("#example")
    js[:example].should == "Changed!"
  end

  it 'should create a stubbed environment with a simpler syntax' do
    js = EnvJohnson.new "", :elements => [:example, :something]
    js.body.should have_tag("#example")
    js.body.should have_tag("#something")
  end
end
