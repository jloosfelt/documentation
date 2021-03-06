require 'open-uri'
require 'nokogiri'

namespace :fetch_from_homepage do
  task all: [:header, :footer]

  task :header do
    doc = fetch_homepage

    toolbar = doc.css("header.mdc-toolbar")
    toolbar = hack(toolbar)
    toolbar = add_subrow(toolbar)
    toolbar = add_subnav(toolbar)

    drawer = doc.css("aside.mdc-drawer")
    drawer = add_drawer_subnav(drawer)

    template_path = "_includes/header.html"
    File.open(template_path, 'w+') { |file|
      file.write(toolbar.to_xhtml)
      file.write(drawer.to_xhtml)
    }
  end

  task :footer do
    doc = fetch_homepage
    footer = doc.css("footer").to_xhtml
    template_path = "_includes/footer.html"
    File.open(template_path, 'w+') { |file|
      file.write(footer)
    }
  end

  def fetch_homepage
    uri = URI.parse(HOMEPAGE_URL)
    str = if uri.user || uri.password
      uri2 = uri.clone
      uri2.user = nil
      uri2.password = nil
      open(uri.to_s, http_basic_authentication: [uri.user, uri.password])
    else
      open(uri)
    end
    Nokogiri::HTML(str)
  end

  def add_subrow doc
    doc.css('.supnav').after(subrow)
    doc
  end

  def add_subnav doc
    doc.css('header > .mdc-toolbar__row:first-child').after(subnav)
    doc
  end

  def add_drawer_subnav doc
    doc.css('nav > ul > li.heading:nth-child(4) > a').after(drawer_subnav)
    doc
  end

  def subrow
    <<~HEREDOC
      <div class="mdc-toolbar__subrow">
        <div class="container">
          <span class="mdc-toolbar__title">
            Resources for Developers
          </span>
        </div>
      </div>
    HEREDOC
  end

  def subnav
    <<~HEREDOC
      <div class="mdc-toolbar__row">
        <div class="container">
          <div class="d-flex justify-content-start">
            <nav class="mdc-tab-bar d-none d-md-block">
              <a class="mdc-tab" href="/">
                Guides
              </a>
              <a class="mdc-tab" href="/samples" data-index="samples">
                Samples
              </a>
              <a class="mdc-tab" href="/cli" data-index="cli">
                CLI
              </a>
              <a class="mdc-tab" href="/changelog" data-index="changelog">
                Changelog
              </a>
              <a class="mdc-tab" href="https://developers.scalingo.com" target="_blank" data-index="api">
                API Reference
                <i class="material-icons">open_in_new</i>
              </a>
            </nav>
            <div class="search mdc-text-field mdc-text-field--with-leading-icon">
              <i class="material-icons mdc-text-field__icon" tabindex="0">search</i>
              <input type="text" id="search-input" placeholder="Search" class="mdc-text-field__input">
            </div>
          </div>
        </div>
      </div>
    HEREDOC
  end

  def drawer_subnav
    <<~HEREDOC
      <ul>
        <li>
          <a href="/">
            Guides
          </a>
        </li>
        <li>
          <a href="/samples" data-index="samples">
          Samples
          </a>
        </li>
        <li>
          <a href="/cli" data-index="cli">
          CLI
          </a>
        </li>
        <li>
          <a href="/changelog" data-index="changelog">
          Changelog
          </a>
        </li>
        <li>
          <a href="https://developers.scalingo.com" target="_blank" data-index="api">
          API Reference
          <i class="material-icons">open_in_new</i>
          </a>
        </li>
      </ul>
    HEREDOC
  end


  # Don't know why but the default SVG button make the page scroll automatically
  # This hack is here to circumvent this problem by replacing the SVG by the same
  # glyph coming from the material design font icon
  def hack doc
    doc.css('button svg').first.replace('<i class="material-icons">menu</i>')
    doc
  end
end
