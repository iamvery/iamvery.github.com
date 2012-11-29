module Jekyll
  require 'haml'

  class HamlConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /haml/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      Haml::Engine.new(content).render
    end
  end
end
