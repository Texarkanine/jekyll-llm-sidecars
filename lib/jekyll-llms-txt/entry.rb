# frozen_string_literal: true

module JekyllLlmsTxt
  # One document. Summary and body are slots filled on first read.
  class Entry
    UNSET = Object.new

    # Returns the Entry already registered for this document. The first call
    # stores the object and its computers. A later call for the same document
    # returns that object.
    #
    # @param item [Jekyll::Page, Jekyll::Document]
    # @param summary_computer [#call]
    # @param body_computer [#call]
    # @return [Entry]
    def self.new(item:, summary_computer:, body_computer:)
      registry[item] ||= super
    end

    # Drops every registration. The census calls this at the start of a build.
    #
    # @return [void]
    def self.reset!
      @registry = nil
    end

    def self.registry
      @registry ||= {}.compare_by_identity
    end
    private_class_method :registry

    # @param item [Jekyll::Page, Jekyll::Document]
    # @param summary_computer [#call]
    # @param body_computer [#call]
    def initialize(item:, summary_computer:, body_computer:)
      @item = item
      @summary_computer = summary_computer
      @body_computer = body_computer
      @summary = UNSET
      @body = UNSET
    end

    # @return [Jekyll::Page, Jekyll::Document]
    attr_reader :item

    # @return [Object] the summary slot, filled on first read
    def summary
      return @summary unless @summary.equal?(UNSET)

      @summary = @summary_computer.call(@item)
    end

    # @return [Object] the body slot, filled on first read
    def body
      return @body unless @body.equal?(UNSET)

      @body = @body_computer.call(@item)
    end
  end
end
