module Matchers
  class Ajax
    def initialize(params = {})
      @params = params
    end

    def to(uri)
      Matchers::Ajax.new @params.merge(:to => uri)
    end

    def with_parameters(params)
      old_params = @params[:params] || {}
      Matchers::Ajax.new @params.merge(:params => old_params.merge(params))
    end
    alias :with_params :with_parameters

    def matches?(js)
      @js = js
      conditions = [@js.remote_calls.size > 1]
      conditions << to_remote? if @params[:to]
      conditions << with_parameters? if @params[:params]
      conditions.all?
    end

    def to_remote?
      call = @js.remote_calls[-1].gsub(/\?.*/, "")
      with_trailing = @params[:to] === call
      without_trailing = @params[:to] === call[1..-1]
      without_trailing or with_trailing
    end
    private :to_remote?

    def with_parameters?
      uri_params = @js.remote_calls[-1].gsub(/.*?\?/, "")
      uri_params = uri_params.split("&").map do |x| 
        k, v = x.split("=")
        [k, URI.unescape(v.to_s)]
      end
      params = @params[:params]
      params.all? do |key, value|
        key, value = key.to_s, value.to_s
        uri_params.include?([key, value])
      end
    end
    private :with_parameters?

    def failure_message
      "Expected #@js to #{rest}"
    end

    def negative_failure_message
      "Expected #@js not to #{rest}"
    end

    def rest
      "be an ajax call".tap do |m|
        m << " to #{@params[:to].inspect}" if @params[:to]
        m << " with parameters #{@params[:params].inspect}" if @params[:params]
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
