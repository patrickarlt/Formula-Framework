require "kss"
require "redcarpet"
require "formula"

Markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, {
  fenced_code_blocks: true,
  autolink: true,
  with_toc_data: true
})

Styleguide = Kss::Parser.new("stylesheets/")

helpers do
  def section_link(section)
    title = Styleguide.section(section).comment_sections.first.gsub("#", "").strip
    "<li><a href='#section-#{section}'>#{title}</a></li>"
  end

  def styleguide(section, &block)
    @section = Styleguide.section(section)
    @description = Markdown.render(@section.description)
    @example_html = nil
    @escaped_html = nil
    unless block.nil?
      @example_html = kss_capture{ block.call }
      @escaped_html = ERB::Util.html_escape(@example_html.sub(" class=\"$modifier_class\"", ""))
    end
    @_out_buf << partial('styleguide_block')
  end

  # KSS: Captures the result of a block within an erb template without spitting
  # it to the output buffer.
  def kss_capture(&block)
    out, @_out_buf = @_out_buf, ""
    yield
    @_out_buf
  ensure
    @_out_buf = out
  end

  def strip_whitespace_for_pre string
    # gets an array of the leading whitespace values for each line
    ws = string.lines.collect { |l|
      l[/\A */].size
    }

    ws.delete(0) # remove zero whitespace lines
    ws.delete_at(-1) # remove the last time since its going to be <% end %> which we dont want

    # get the section of each line starting at the lowest whitespace to the end of the line
    lines = string.lines.collect { |l|
      l[ws.min, l.size]
    }.join()

    ERB::Util.html_escape lines.strip
  end

  def base_url
    if environment === :build
      return "/formula-framework/"
    else
      return "/"
    end
  end

end

activate :directory_indexes

activate :automatic_image_sizes

set :build_dir, 'documentation'

set :css_dir, 'css'

set :js_dir, 'js'

set :images_dir, 'img'

# Build-specific configuration
configure :build do

  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  # activate :cache_buster

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets
end