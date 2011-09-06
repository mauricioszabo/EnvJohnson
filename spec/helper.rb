require 'env_johnson'
require "env_johnson/matchers"
require "rubygems"
require "nokogiri"

RSpec::Matchers.define :have_tag do |css_selector| 
  match do |body| 
    not Nokogiri.parse(body).css(css_selector).empty? 
  end
end
    
