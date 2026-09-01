# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Ebooks", type: :request do
  let(:json)    { JSON.parse(response.body) }
  let(:headers) { { "Accept" => "application/json" } }

  # ─── GET /api/ebooks ────────────────────────────────────────────────────────

  describe "GET /api/ebooks" do
    context "when there are no ebooks" do
      it "returns an empty array" do
        get "/api/ebooks", headers: headers
        expect(response).to have_http_status(:ok)
        expect(json["ebooks"]).to eq([])
      end
    end

    context "when ebooks exist" do
      let!(:ebook1) { create(:ebook, title: "Aaardvark Book", created_at: 1.day.ago) }
      let!(:ebook2) { create(:ebook, title: "Zebra Book",     created_at: Time.current) }

      it "returns all ebooks" do
        get "/api/ebooks", headers: headers
        expect(response).to have_http_status(:ok)
        expect(json["ebooks"].length).to eq(2)
      end

      it "returns ebooks sorted by recent by default" do
        get "/api/ebooks", headers: headers
        titles = json["ebooks"].map { |e| e["title"] }
        expect(titles.first).to eq("Zebra Book")
      end

      it "supports sort=title" do
        get "/api/ebooks?sort=title", headers: headers
        titles = json["ebooks"].map { |e| e["title"] }
        expect(titles).to eq(["Aaardvark Book", "Zebra Book"])
      end

      it "returns pagination metadata" do
        get "/api/ebooks", headers: headers
        expect(json["pagination"]).to include("count", "page", "pages")
      end
    end

    context "filtering by file_format" do
      let!(:pdf_book)  { create(:ebook, file_format: "pdf")  }
      let!(:epub_book) { create(:ebook, :epub) }

      it "filters by pdf format" do
        get "/api/ebooks?format=pdf", headers: headers
        formats = json["ebooks"].map { |e| e["file_format"] }
        expect(formats).to all(eq("pdf"))
      end
    end
  end

  # ─── GET /api/ebooks/search ─────────────────────────────────────────────────

  describe "GET /api/ebooks/search" do
    let!(:gatsby)   { create(:ebook, title: "The Great Gatsby",     author: "Fitzgerald") }
    let!(:mockbird) { create(:ebook, title: "To Kill a Mockingbird", author: "Harper Lee") }

    it "returns matching ebooks by title" do
      get "/api/ebooks/search?q=Gatsby", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json["ebooks"].length).to eq(1)
      expect(json["ebooks"].first["title"]).to eq("The Great Gatsby")
    end

    it "returns matching ebooks by author" do
      get "/api/ebooks/search?q=Harper", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json["ebooks"].first["title"]).to eq("To Kill a Mockingbird")
    end

    it "is case-insensitive" do
      get "/api/ebooks/search?q=gatsby", headers: headers
      expect(json["ebooks"].length).to eq(1)
    end

    it "returns empty array for no matches" do
      get "/api/ebooks/search?q=xyznotfound", headers: headers
      expect(json["ebooks"]).to eq([])
    end

    it "returns empty array for blank query" do
      get "/api/ebooks/search?q=", headers: headers
      expect(json["ebooks"]).to eq([])
    end

    it "includes the query in the response" do
      get "/api/ebooks/search?q=Gatsby", headers: headers
      expect(json["query"]).to eq("Gatsby")
    end
  end

  # ─── GET /api/ebooks/:id ────────────────────────────────────────────────────

  describe "GET /api/ebooks/:id" do
    let!(:ebook) { create(:ebook) }

    it "returns the ebook" do
      get "/api/ebooks/#{ebook.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(ebook.id)
      expect(json["title"]).to eq(ebook.title)
    end

    it "includes file_url in response" do
      get "/api/ebooks/#{ebook.id}", headers: headers
      expect(json).to have_key("file_url")
    end

    it "returns 404 for unknown ebook" do
      get "/api/ebooks/9999999", headers: headers
      expect(response).to have_http_status(:not_found)
      expect(json["error"]).to be_present
    end
  end

  # ─── POST /api/ebooks ───────────────────────────────────────────────────────

  describe "POST /api/ebooks" do
    let(:pdf_content) do
      "%PDF-1.4\n1 0 obj<</Type /Catalog>>endobj\ntrailer<</Root 1 0 R>>\n%%EOF"
    end

    let(:valid_params) do
      {
        ebook: {
          title:  "My Test Book",
          author: "Test Author",
          file:   fixture_file_upload_helper(pdf_content, "test.pdf", "application/pdf")
        }
      }
    end

    context "with valid parameters" do
      it "creates an ebook and returns 201" do
        pdf_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: StringIO.new(pdf_content),
          filename: "test.pdf",
          type:     "application/pdf"
        )
        # Use multipart form for file uploads
        post "/api/ebooks",
             params:  { ebook: { title: "My Test Book", author: "Test Author", file: pdf_file } },
             headers: { "Content-Type" => "multipart/form-data" }

        expect(response).to have_http_status(:created)
        expect(json["title"]).to eq("My Test Book")
        expect(json["author"]).to eq("Test Author")
      end

      it "increments ebook count" do
        pdf_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: StringIO.new(pdf_content),
          filename: "test.pdf",
          type:     "application/pdf"
        )
        expect {
          post "/api/ebooks",
               params:  { ebook: { title: "New Book", file: pdf_file } },
               headers: { "Content-Type" => "multipart/form-data" }
        }.to change(Ebook, :count).by(1)
      end
    end

    context "without a title" do
      it "returns 422 with error details" do
        pdf_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: StringIO.new(pdf_content),
          filename: "test.pdf",
          type:     "application/pdf"
        )
        post "/api/ebooks",
             params:  { ebook: { file: pdf_file } },
             headers: { "Content-Type" => "multipart/form-data" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["details"]).to be_present
      end
    end

    context "without a file" do
      it "returns 422" do
        post "/api/ebooks",
             params:  { ebook: { title: "Missing File Book" } },
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to be_present
      end
    end

    context "with wrong file type" do
      it "returns 422 with file type error" do
        txt_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: StringIO.new("just plain text"),
          filename: "test.txt",
          type:     "text/plain"
        )
        post "/api/ebooks",
             params:  { ebook: { title: "Wrong Type", file: txt_file } },
             headers: { "Content-Type" => "multipart/form-data" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["details"].join).to match(/PDF or EPUB/)
      end
    end
  end

  # ─── GET /api/ebooks/:id/download ───────────────────────────────────────────

  describe "GET /api/ebooks/:id/download" do
    let!(:ebook) { create(:ebook) }

    it "redirects to file download URL" do
      get "/api/ebooks/#{ebook.id}/download", headers: headers
      # Should redirect to Active Storage blob URL
      expect(response).to have_http_status(:redirect).or have_http_status(:ok)
    end

    it "returns 404 for unknown ebook" do
      get "/api/ebooks/9999999/download", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  # ─── PATCH /api/ebooks/:id/read_position ────────────────────────────────────

  describe "PATCH /api/ebooks/:id/read_position" do
    let!(:ebook) { create(:ebook) }

    it "updates the read position" do
      patch "/api/ebooks/#{ebook.id}/read_position",
            params:  { page: 25 },
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["read_position"]).to eq(25)
      expect(ebook.reload.read_position).to eq(25)
    end

    it "requires a page parameter" do
      patch "/api/ebooks/#{ebook.id}/read_position", headers: headers
      expect(response).to have_http_status(:bad_request)
    end
  end

  # ─── DELETE /api/ebooks/:id ─────────────────────────────────────────────────

  describe "DELETE /api/ebooks/:id" do
    let!(:ebook) { create(:ebook) }

    it "deletes the ebook and returns 200" do
      expect {
        delete "/api/ebooks/#{ebook.id}", headers: headers
      }.to change(Ebook, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(json["message"]).to match(/deleted/i)
    end

    it "returns 404 for unknown ebook" do
      delete "/api/ebooks/9999999", headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it "removes the file attachment" do
      expect(ebook.file).to be_attached

      delete "/api/ebooks/#{ebook.id}", headers: headers
      expect { ebook.file.blob.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
