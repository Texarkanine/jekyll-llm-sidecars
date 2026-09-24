# frozen_string_literal: true

require "fileutils"

module Jekyll
  module LlmsTxt
    # Writes this plugin's destination files and inserts Markdown alternate links.
    module Hooks
      # @param site [Jekyll::Site]
      # @return [void]
      def self.inject(site)
        state = site.instance_variable_get(:@llms_txt)
        return unless state

        documents(site).each do |document|
          href = state.href_for(document)
          next if href.nil?
          next if document.output.nil?

          tag = %(<link rel="alternate" type="text/markdown" href="#{href}">)
          document.output = document.output.sub("</head>", "#{tag}</head>")
        end
      end

      # @param obsolete [Array<String>] absolute destination paths the cleaner will delete
      # @return [void]
      def self.keep_destinations(obsolete)
        kept = Jekyll::LlmsTxt.current_destinations
        return if kept.nil?

        obsolete.delete_if { |path| kept.include?(path) }
      end

      # @param site [Jekyll::Site]
      # @return [void]
      def self.write(site)
        state = site.instance_variable_get(:@llms_txt)
        return unless state

        state.files.each do |path, content|
          dest_path = Jekyll.sanitized_path(site.dest, path)
          FileUtils.mkdir_p(File.dirname(dest_path))
          File.write(dest_path, content)
        end
      end

      def self.documents(site)
        site.pages + site.documents
      end
      private_class_method :documents
    end
  end
end

Jekyll::Hooks.register(:site, :post_render) do |site|
  Jekyll::LlmsTxt::Hooks.inject(site)
end

Jekyll::Hooks.register(:clean, :on_obsolete) do |obsolete|
  Jekyll::LlmsTxt::Hooks.keep_destinations(obsolete)
end

Jekyll::Hooks.register(:site, :post_write) do |site|
  Jekyll::LlmsTxt::Hooks.write(site)
end
