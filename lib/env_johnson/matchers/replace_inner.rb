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
      conditions << (@params[:with] === after) if @params[:with]
      conditions.all?
    end

    def with(string)
      ReplaceInner.new @element_id, @params.merge(:with => string)
    end

    def failure_message
      "Expected #@js #{rest}"
    end
    def negative_failure_message
      "Expected #@js not #{rest}"
    end

    def rest
      rest = "to replace element '#{@element_id}'"
      rest << " with #{@params[:with].inspect}" if @params[:with]
      return rest
    end
    private :rest
  end
end


module RSpec::Matchers
  def replace_inner_html_of(element_id)
    Matchers::ReplaceInner.new(element_id)
  end
end
