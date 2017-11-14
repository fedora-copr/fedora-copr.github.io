require 'net/http'
require 'uri'

module Jekyll

  class RemoteInclude < Liquid::Tag

    def initialize(tag_name, remote_include, tokens)
      super
      @remote_include = remote_include
    end

    def open(url)
      Net::HTTP.get(URI.parse(url.strip)).force_encoding 'utf-8'
    end

    def render(context)
      text = open("#{@remote_include}")

      # If it is a jekyll post
      # then we are dealing with front-matter file,
      # https://jekyllrb.com/docs/frontmatter/
      if text.start_with?("---")
        # We need to remove the YAML header
        text = text[text.index("---", 2)+3..-1]
      end

      text
    end

  end
end

Liquid::Template.register_tag('remote_include', Jekyll::RemoteInclude)
