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

module Matchers
  class ReplaceInner
    def initialize(element_id, params={})
      @element_id = element_id
      @params = params
    end

    def matches?(js)
      @js = js
      before = Nokogiri.parse @js.body_before
      after = Nokogiri.parse @js.body
      before = before.css("##{@element_id}").inner_html
      after = after.css("##{@element_id}").inner_html
      
      conditions = [before != after]
      conditions << (after == @params[:with]) if @params[:with]
      conditions.all?
    end

    def with(string)
      ReplaceInner.new @element_id, @params.merge(:with => string)
    end

    def failure_message
      "Expected #{@js.inspect} #{rest}"
    end
    def negative_failure_message
      "Expected #{@js.inspect} not to replace element '#{@element_id}'"
    end

    def rest
      rest = "to replace element '#{@element_id}'"
      rest << " with #{@params[:with]}" if @params[:with]
      return rest
    end
    private :rest
  end
end

module RSpec::Matchers
  def js_for(string, params={})
    js = SpecEnvJohnson.new string, params
    yield js
  end

  def replace_inner_html_of(element_id)
    Matchers::ReplaceInner.new(element_id)
  end
end
