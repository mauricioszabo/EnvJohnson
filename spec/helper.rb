require 'env_johnson'
require "rubygems"
require "nokogiri"

RSpec = Spec if Object.const_defined? :Spec
RSpec::Matchers.define :have_tag do |css_selector| 
  match do |body| 
    not Nokogiri.parse(body).css(css_selector).empty? 
  end
end
    
