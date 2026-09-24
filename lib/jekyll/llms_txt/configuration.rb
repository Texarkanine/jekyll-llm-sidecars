# frozen_string_literal: true

module Jekyll
  module LlmsTxt
    # Reads the `llms-txt` config block. A missing block uses the README defaults.
    # A key that is present wins, including an explicit false or an empty list.
    class Configuration
      DEFAULT_INCLUDE = %w[pages posts].freeze
      DEFAULT_EXCLUDE = ["/README.md", "/CHANGELOG.md", "/404.html", "/assets/**"].freeze

      # @param site [Jekyll::Site]
      def initialize(site)
        block = site.config["llms-txt"]
        @block = block.is_a?(Hash) ? block : {}
      end

      # @return [Boolean]
      def markdown
        flag("markdown", true)
      end

      # @return [Boolean]
      def llms_txt
        flag("llms_txt", true)
      end

      # @return [Boolean]
      def llms_full
        flag("llms_full", false)
      end

      # @return [Boolean]
      def categories
        flag("categories", false)
      end

      # @return [Boolean]
      def collections
        flag("collections", false)
      end

      # @return [Array<String>]
      def include
        list("include", DEFAULT_INCLUDE)
      end

      # @return [Array<String>]
      def exclude
        list("exclude", DEFAULT_EXCLUDE)
      end

      private

      def flag(key, default)
        @block.fetch(key, default)
      end

      def list(key, default)
        if @block.key?(key)
          Array(@block.fetch(key))
        else
          default
        end
      end
    end
  end
end
