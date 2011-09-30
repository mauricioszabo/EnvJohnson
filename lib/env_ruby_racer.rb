require "v8"
require 'net/http'
require 'thread'

class EnvRubyRacer
  attr_reader :js
  attr_reader :remote_calls

  def initialize(js_code, *javascripts)
    hash = javascripts.delete_at -1 if javascripts[-1].is_a?(Hash)
    @js = V8::Context.new
    @remote_calls = []
    configure_context(@js, hash)
    @js.load(@js['dir'] + "/envjs/rubyracer.js")
    js = <<-JS
      var check_urls = function(event) {
        document.innerHTMLBeforeChanges = document.innerHTML;
        #{rewrite_get_element_by_id}
      };
      document.addEventListener('DOMContentLoaded', check_urls);
      document.location = "http://example.com/";
      Envjs.resetEventLoop();
    JS
    @js.eval js
    #load_javascripts javascripts
    #@js.eval(js_code)
  end
    
  def configure_context(context, hash={})
    hash ||= {}
    body = generate_body(hash)
    context['global'] = context
    context['HTTPConnection'] = HTTPConnection.new(body, self)
    context['dir'] = File.expand_path(File.dirname(__FILE__))

    ruby = {}
    Module.included_modules.each{|m| ruby[m.to_s] = m }
    Module.constants.each{|c| ruby[c.to_s] = Kernel.eval(c) }
    Kernel.global_variables.each{|g| ruby[g.to_s] = Kernel.eval(g) }
    Kernel.methods.each{|m| ruby[m.to_s] = Kernel.method(m) }
    ruby['CONFIG'] = Config::CONFIG
    ruby['gc'] = lambda{ GC.start() }
    context['Ruby']  = ruby
    context['fopen']     = lambda{|name, mode| File.open(name, mode)}
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
        element.appendChild(newDiv);
        return newDiv;
      }
    JS
  end
  private :rewrite_get_element_by_id

  def load_javascripts(jss)
    jss.each do |js|
      @js.load("#{js}.js")
    end
  end
  private :load_javascripts

  def body
    @js.eval "document.innerHTML"
  end

  def body_before
    @js.eval "document.innerHTMLBeforeChanges"
  end

  def [](id)
    element = @js.eval "document.oldGetElementById(#{id.to_s.inspect});"
    return if element.nil?
    return element.innerHTML
  end
end

