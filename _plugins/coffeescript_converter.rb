require 'jekyll_asset_pipeline'

module JekyllAssetPipeline
  class CoffeeScriptConverter < JekyllAssetPipeline::Converter
    require 'coffee-script'

    def self.filetype
      '.coffee'
    end

    def convert
      begin
        CoffeeScript.compile @content
      rescue StandardError => e
        puts "Coffeescript Error: #{e}"
      end
    end
  end
end
