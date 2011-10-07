require "env_johnson/matchers/ajax"
module Matchers
  class Elements
    def initialize(text, element, ajax=nil)
      @text = text
      @element = element
      @ajax = ajax
    end

    def matches?(js)
      @js = js
      result = @js.evaluate(find_element)
      results = [!result.nil?]
      results << @ajax.matches?(js) if @ajax
      return results.all?
    end

    def find_element
      run_action = <<-JS
        try {
          element.click();
          //TODO: Why this doesn't work: element.onclick();
          eval(element.getAttribute('onclick'))
        } catch(e) {
        }
      JS

      #FIXME: Change to XPath finding (as soon as I discover how to do this with Env.JS)
      get_element = case @element.upcase
        when 'A' then find_link
        when 'BUTTON' then find_button
      end
      
      return "(function() { #{get_element.gsub "{run_action}", run_action} })();"
    end
    private :find_element

    def find_link()
      return <<-JS
        var matches = document.getElementsByTagName('a');
        var i, l = matches.length;
        for(i = 0; i < l; i++) {
          var element = matches[i];
          if(element.innerHTML === #{@text.inspect}) {
            {run_action}
            return element;
          }
        }
      JS
    end
    private :find_link

    def find_button
      return <<-JS
        var matches1 = document.getElementsByTagName('input');
        var matches2 = document.getElementsByTagName('button');
        var funcao = function(matches) {
          var i, l = matches.length;
          for(i = 0; i < l; i++) {
            var element = matches[i];
            var is_button = element.tagName.toLowerCase() === "button" || 
              element.getAttribute("type").toLowerCase() === "submit";
            if(is_button && element.getAttribute("value") === #{@text.inspect}) {
              {run_action}
              return element;
            }
          }
        };
        var e1 = funcao(matches1);
        if(e1) {
          return e1;
        } else {
          return funcao(matches2);
        }
      JS
    end

    def to(url)
      ajax = @ajax || Matchers::Ajax.new
      Elements.new(@text, @element, ajax.to(url))
    end

    def with_parameters(params)
      ajax = @ajax || Matchers::Ajax.new
      Elements.new(@text, @element, ajax.with_parameters(params))
    end
    alias :with_params :with_parameters

    def failure_message
      "Expected #@js to #{rest}"
    end

    def negative_failure_message
      "Expected #@js not to #{rest}"
    end

    def rest
      "have an element #{@element.upcase} with text '#@text'".tap do |m|
      end
    end
    private :rest
  end
end

module RSpec::Matchers
  def have_link(link_text)
    Matchers::Elements.new link_text, 'a'
  end

  def have_button(text)
    Matchers::Elements.new text, 'button'
  end
end
