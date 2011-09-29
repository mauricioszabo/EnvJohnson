module Matchers
  class Ajax
    def initialize(params = {})
      @params = params
    end

    def to(uri)
      Matchers::Ajax.new @params.merge(:to => uri)
    end

    def matches?(js)
      @js = js
      conditions = [@js.remote_calls.size > 1]
      conditions << to_remote if @params[:to]
      conditions.all?
    end

    def to_remote
      with_trailing = @params[:to] === @js.remote_calls[-1]
      without_trailing = @params[:to] === @js.remote_calls[-1][1..-1]
      without_trailing or with_trailing
    end
    private :to_remote

    def failure_message
      "Expected #@js to #{rest}"
    end

    def negative_failure_message
      "Expected #@js not to #{rest}"
    end

    def rest
      "be an ajax call".tap do |m|
        m << " to #{@params[:to].inspect}" if @params[:to]
      end
    end
    private :rest
  end
end

module RSpec::Matchers
  def be_an_ajax
    Matchers::Ajax.new
  end
end
