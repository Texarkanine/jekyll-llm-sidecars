# frozen_string_literal: true

require "fileutils"
require "yaml"

module SiteFixtures
  def build_site(files, config = {})
    source = File.join(@temp_dir, "src")
    destination = File.join(@temp_dir, "_site")
    FileUtils.mkdir_p(source)
    File.write(File.join(source, "_config.yml"), YAML.dump(config))
    files.each do |relative, body|
      full = File.join(source, relative)
      FileUtils.mkdir_p(File.dirname(full))
      File.write(full, body)
    end

    site = Jekyll::Site.new(
      Jekyll.configuration(
        "source" => source,
        "destination" => destination,
        "quiet" => true
      )
    )
    site.read
    site
  end

  def process_site(files, config = {})
    site = build_site(files, config)
    site.process
    site
  end

  def read_dest(site, path)
    File.read(File.join(site.dest, path.delete_prefix("/")))
  end

  def page_body(title: nil, extra: nil, body: "Body")
    front = []
    front << "title: #{title}" if title
    front << extra if extra
    <<~MARKDOWN
      ---
      #{front.join("\n")}
      ---
      #{body}
    MARKDOWN
  end
end

RSpec.configure do |config|
  config.include SiteFixtures
end
