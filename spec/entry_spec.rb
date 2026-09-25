# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllLlmSidecars::Entry do
  let(:item) { Object.new }
  let(:summary_calls) { [] }
  let(:body_calls) { [] }
  let(:summary_text) { "the summary line" }
  let(:body_text) { "the body" }
  let(:summary_computer) do
    lambda { |received|
      summary_calls << received
      summary_text
    }
  end
  let(:body_computer) do
    lambda { |received|
      body_calls << received
      body_text
    }
  end
  let(:entry) do
    described_class.new(
      item: item,
      summary_computer: summary_computer,
      body_computer: body_computer
    )
  end

  describe "#item" do
    it "is the document the census selected" do
      expect(entry.item).to equal(item)
    end
  end

  describe "#summary" do
    it "runs the summary computer once and returns that slot to every reader" do
      second_scope = entry

      expect(entry.summary).to equal(summary_text)
      expect(entry.summary).to equal(summary_text)
      expect(second_scope.summary).to equal(summary_text)
      expect(summary_calls).to eq([item])
    end
  end

  describe "#body" do
    it "runs the body computer once when the corpus and the sidecar both read it" do
      expect(entry.body).to equal(body_text)
      expect(entry.body).to equal(body_text)
      expect(body_calls).to eq([item])
    end

    it "does not run the body computer when nothing reads the body" do
      entry.summary

      expect(body_calls).to be_empty
    end
  end

  describe ".new" do
    it "returns the entry already registered for that document" do
      first = described_class.new(item: item, summary_computer: summary_computer, body_computer: body_computer)
      second = described_class.new(
        item: item,
        summary_computer: ->(_) { "other" },
        body_computer: ->(_) { "other" }
      )

      expect(second).to equal(first)
      expect(second.summary).to eq(summary_text)
    end

    it "returns a new entry when the document is a different object" do
      described_class.reset!
      document = Class.new do
        def eql?(_other) = true
        def hash = 0
      end
      first = described_class.new(item: document.new, summary_computer: ->(_) {}, body_computer: ->(_) {})
      second = described_class.new(item: document.new, summary_computer: ->(_) {}, body_computer: ->(_) {})

      expect(second).not_to equal(first)
    end

    it "drops registrations when the table is reset" do
      first = described_class.new(item: item, summary_computer: summary_computer, body_computer: body_computer)
      described_class.reset!
      second = described_class.new(item: item, summary_computer: summary_computer, body_computer: body_computer)

      expect(second).not_to equal(first)
    end
  end
end
