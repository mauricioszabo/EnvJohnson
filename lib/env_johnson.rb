require "rubygems"
require 'johnson'
require 'net/http'
require 'thread'

class EnvJohnson
  attr_reader :js
  attr_reader :remote_calls

  def initialize(js_code, *javascripts)
    hash = javascripts.delete_at -1 if javascripts[-1].is_a?(Hash)
    @js = Johnson::Runtime.new
    @remote_calls = []
    configure_context(@js, hash)
    @js.load(@js['dir'] + "/envjs/johnson.js")
    js = <<-JS
      var check_urls = function(event) {
        document.innerHTMLBeforeChanges = document.innerHTML;
        #{rewrite_get_element_by_id}
        #{add_tag_name}
      };
      document.addEventListener('load', check_urls);
      window.location = "http://example.com/";
      Envjs.resetEventLoop();
    JS
    @js.evaluate js
    load_javascripts javascripts
    @js.evaluate(js_code)
  end

  def evaluate(script)
    @js.evaluate script
  end
    
  def configure_context(context, hash={})
    hash ||= {}
    body = generate_body(hash)
    context['global'] = context
    context['HTTPConnection'] = HTTPConnection.new(body, self)
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

  def add_tag_name
    <<-JS
      document.getElementsByTagNameCorrected = function(tagName) {
        var all = document.getElementsByTagName("*");
        var allLength = all.length;
        var elements = [];
        for(var i = 0; i < allLength; i++) {
          if(all[i].tagName.toUpperCase() === tagName.toUpperCase()) {
            elements.push(all[i]);
          }
        }
        return elements;
      }
    JS
  end
  private :add_tag_name

  def load_javascripts(jss)
    jss.each do |js|
      @js.load("#{js}.js")
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
  def initialize(body, env_johnson)
    @body = "<body id='someDivThatWillNeverBeOverwrited'>#{body}</body>"
    @env_johnson = env_johnson
  end

  def go(complete_url, path)
    @env_johnson.remote_calls << path
    response = if path == "/"
      FakeResponse.new(@body)
    else
      FakeResponse.new "example"
    end
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
