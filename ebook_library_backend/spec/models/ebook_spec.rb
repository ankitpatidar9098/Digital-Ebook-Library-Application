# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ebook, type: :model do
  subject(:ebook) { build(:ebook) }

  # ─── Validations ────────────────────────────────────────────────────────────

  describe "validations" do
    it "is valid with all required attributes" do
      expect(ebook).to be_valid
    end

    it "requires a title" do
      ebook.title = nil
      expect(ebook).not_to be_valid
      expect(ebook.errors[:title]).to include("can't be blank")
    end

    it "requires a file attachment" do
      ebook.file = nil
      expect(ebook).not_to be_valid
      expect(ebook.errors[:file]).to include("must be attached")
    end

    it "rejects titles longer than 255 characters" do
      ebook.title = "a" * 256
      expect(ebook).not_to be_valid
    end

    it "is valid without an author" do
      ebook.author = nil
      expect(ebook).to be_valid
    end

    context "when file is too large" do
      before do
        allow(ebook.file.blob).to receive(:byte_size)
          .and_return(51.megabytes.to_i)
      end

      it "adds a file size error" do
        ebook.valid?
        expect(ebook.errors[:file]).to include(match(/too large/))
      end
    end

    context "when file has invalid content type" do
      before do
        ebook.file.blob.update_column(:content_type, "text/plain") if ebook.file.attached?
      end

      # This tests the content type validation logic
      it "rejects non-PDF/EPUB content types" do
        new_ebook = Ebook.new(title: "Test", file_format: "pdf", file_size: 100)
        new_ebook.file.attach(
          io:           StringIO.new("just text"),
          filename:     "test.txt",
          content_type: "text/plain"
        )
        expect(new_ebook).not_to be_valid
        expect(new_ebook.errors[:file]).to include(match(/PDF or EPUB/))
      end
    end
  end

  # ─── Scopes ─────────────────────────────────────────────────────────────────

  describe "scopes" do
    let!(:ebook_a) { create(:ebook, title: "Alpha Book",  created_at: 1.day.ago)  }
    let!(:ebook_b) { create(:ebook, title: "Beta Book",   created_at: 2.days.ago) }
    let!(:ebook_c) { create(:ebook, title: "Gamma Book",  created_at: Time.current) }

    describe ".by_title" do
      it "orders ebooks alphabetically by title" do
        expect(Ebook.by_title.pluck(:title)).to eq(["Alpha Book", "Beta Book", "Gamma Book"])
      end
    end

    describe ".by_recent" do
      it "orders ebooks by most recently created" do
        expect(Ebook.by_recent.first).to eq(ebook_c)
      end
    end

    describe ".search_by_query" do
      it "finds ebooks matching title" do
        results = Ebook.search_by_query("Alpha")
        expect(results).to include(ebook_a)
        expect(results).not_to include(ebook_b)
      end

      it "performs case-insensitive search" do
        results = Ebook.search_by_query("alpha")
        expect(results).to include(ebook_a)
      end

      it "returns empty when no matches" do
        expect(Ebook.search_by_query("xyzxyznotfound")).to be_empty
      end
    end
  end

  # ─── Instance Methods ────────────────────────────────────────────────────────

  describe "#file_size_human" do
    it "returns MB for large files" do
      ebook.file_size = 2_500_000
      expect(ebook.file_size_human).to eq("2.5 MB")
    end

    it "returns KB for medium files" do
      ebook.file_size = 512_000
      expect(ebook.file_size_human).to match(/KB/)
    end

    it "returns Unknown for zero size" do
      ebook.file_size = 0
      expect(ebook.file_size_human).to eq("Unknown")
    end
  end

  describe "#update_read_position!" do
    let!(:saved_ebook) { create(:ebook) }

    it "updates read_position and last_read_at" do
      expect { saved_ebook.update_read_position!(15) }
        .to change { saved_ebook.reload.read_position }.to(15)
        .and change { saved_ebook.reload.last_read_at }
    end
  end
end
