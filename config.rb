# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions
require 'slim'

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

set :slim, { :pretty => true, :sort_attrs => false, :format => :html }
set :frontmatter_extensions, %w(.html .slim)
# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# Activate and configure blog extension

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  blog.sources = "posts/{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "post_layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

activate :directory_indexes

activate :syntax

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :footnotes => true

page "/feed.xml", layout: false
# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

helpers do
  def site_title
    'Syntactic Serif'
  end

  def tufte_footnotes(html)
    # Extract footnote definitions
    footnotes = {}

    # Extract all footnote content
    if html =~ /<div class="footnotes">/
      html.gsub!(/<div class="footnotes">.+?<ol>(.+?)<\/ol>.+?<\/div>/m) do
        footnote_list = $1
        footnote_list.scan(/<li id="fn(\d+)">.+?<p>(.*?)&nbsp;<a href="#fnref\d+">&#8617;<\/a><\/p>.+?<\/li>/m) do |number, content|
          footnotes[number] = content.strip
        end
        "" # Remove the footnotes section
      end

      # Replace footnote references with sidenotes
      html.gsub!(/<sup id="fnref(\d+)"><a href="#fn\d+">\d+<\/a><\/sup>/) do
        number = $1
        content = footnotes[number] || "Footnote #{number}"
        %(<label for="sidenote-#{number}" class="margin-toggle sidenote-number"></label>
          <input type="checkbox" id="sidenote-#{number}" class="margin-toggle"/>
          <span class="sidenote">#{content}</span>)
      end
    end

    html
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end
