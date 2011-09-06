require "rubygems"
require 'johnson'
require 'net/http'
require 'uri'
require 'thread'



class EnvJohnson
  attr_reader :js

  def initialize(js_code, *javascripts)
    hash = javascripts.delete_at -1 if javascripts[-1].is_a?(Hash)
    @js = Johnson::Runtime.new
    configure_context(@js, hash)
    @js.load(@js['dir'] + "/envjs/johnson.js")
    js = <<-JS
      var check_urls = function(event) {
        document.innerHTMLBeforeChanges = document.innerHTML;
        #{rewrite_get_element_by_id}
      };
      document.addEventListener('load', check_urls);
      window.location = "http://example.com/";
      Envjs.resetEventLoop();
    JS
    @js.evaluate js
    load_javascripts javascripts
    @js.evaluate(js_code)
  end
    
  def configure_context(context, hash={})
    hash ||= {}
    body = generate_body(hash)
    context['global'] = context
    context['HTTPConnection'] = HTTPConnection.new(body)
    context['dir'] = File.expand_path(File.dirname(__FILE__))
  end
  private :configure_context

  def generate_body(hash)
    body = "#{hash[:body]}"
    if hash[:elements]
      body += hash[:elements].map { |e| "<div id=#{e.to_s.inspect}></div>" }.join
    end
    return body
  end
  private :generate_body

  def rewrite_get_element_by_id
    <<-JS
      document.oldGetElementById = document.getElementById;
      document.getElementById = function(id) {
        var element = document.oldGetElementById(id);
        if(element) return element;
        element = document.oldGetElementById('someDivThatWillNeverBeOverwrited');
        var newDiv = document.createElement('div');
        newDiv.id = id;
        newDiv.innerHTML = "";
        element.appendChild(newDiv)
        return newDiv;
      }
    JS
  end
  private :rewrite_get_element_by_id

  def load_javascripts(jss)
    jss.each do |js|
      @js.load("public/javascripts/#{js}.js")
    end
  end
  private :load_javascripts

  def body
    @js.evaluate "document.innerHTML"
  end

  def body_before
    @js.evaluate "document.innerHTMLBeforeChanges"
  end

  def [](id)
    element = @js.evaluate "document.oldGetElementById(#{id.to_s.inspect});"
    return if element.nil?
    return element.innerHTML
  end
end

class HTTPConnection
  def initialize(body = '')
    @body = "<body id='someDivThatWillNeverBeOverwrited'>#{body}</body>"
  end

  def go(complete_url, path)
    response = FakeResponse.new(@body)
    headers = {
      "content-location" => "http://example.com/",
      "content-type"=>"text/html"
    }
    [response, headers]
  end
end

class FakeResponse
  attr_accessor :code, :message, :body
  def initialize(body)
    @body = body
    @code, @message = "200", "OK"
  end
end
