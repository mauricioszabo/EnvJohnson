require "nokogiri"

#TODO: Move to other file and SPEC it.
class SpecEnvJohnson < EnvJohnson
  def initialize(js_code, *javascripts)
    super
    @code = js_code
  end

  def inspect
    "\"#@code\""
  end
end

RSpec = Spec if Object.const_defined? :Spec

module RSpec::Matchers
  def js_for(string, params={})
    js = SpecEnvJohnson.new string, params
    yield js
  end
end

require "env_johnson/matchers/replace_inner"
