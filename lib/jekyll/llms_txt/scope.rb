# frozen_string_literal: true

module Jekyll
  module LlmsTxt
    # A group of census entries that share an output path prefix.
    class Scope
      # @param path_prefix [String]
      # @param title [String, nil] nil becomes an empty title
      # @param description [String, nil] nil or blank omits the blockquote
      # @param entries [Array<Entry>]
      def initialize(path_prefix:, title:, description:, entries:)
        @path_prefix = path_prefix
        @title = title.to_s
        @description = description if description.to_s.match?(/\S/)
        @entries = sort_entries(entries)
      end

      attr_reader :path_prefix, :title, :description, :entries

      private

      def sort_entries(entries)
        entries.sort do |left, right|
          compared = entry_time(right) <=> entry_time(left)
          next relative_path(left) <=> relative_path(right) if compared.zero?

          compared
        end
      end

      def entry_time(entry)
        item = entry.item
        date = item.date if item.respond_to?(:date)
        date || Time.at(0)
      end

      def relative_path(entry)
        entry.item.relative_path
      end
    end
  end
end
