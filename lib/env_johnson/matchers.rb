require "nokogiri"

RSpec = Spec if Object.const_defined? :Spec

RSpec::Matchers.define :replace_inner_html_of do |element_id, params|
  match do |js|
    env = EnvJohnson.new js, :elements => [element_id]
    before = Nokogiri.parse env.body_before
    after = Nokogiri.parse env.body
    before = before.css("##{element_id}").inner_html
    after = after.css("##{element_id}").inner_html
    

    before != after
  end
end
