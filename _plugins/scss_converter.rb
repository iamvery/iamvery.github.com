require 'jekyll_asset_pipeline'

module JekyllAssetPipeline
  class SassConverter < JekyllAssetPipeline::Converter
    require 'sass'

    def self.filetype
      '.scss'
    end

    def convert
      begin
        Sass::Engine.new(@content, syntax: :scss).render
      rescue StandardError => e
        puts "Sass Error: #{e.message}"
      end
    end
  end
end
