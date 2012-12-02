module Jekyll
  class MarkdownTag < Jekyll::IncludeTag
    def converter(context)
      @converter ||= context.registers[:site].converters.find{ |c| c.matches 'markdown' }
    end

    def render(context)
      content = super
      converter = converter context
      converter.convert(content).gsub(/\n/,'') # strip out newlines so it can be embedded in haml
    end
  end
end

Liquid::Template.register_tag 'markdown', Jekyll::MarkdownTag
