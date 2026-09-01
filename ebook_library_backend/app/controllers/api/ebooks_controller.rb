# frozen_string_literal: true

module Api
  class EbooksController < ApplicationController
    include Pagy::Backend

    before_action :set_ebook, only: [:show, :download, :destroy, :read_position]

    # GET /api/ebooks
    # Supports: ?sort=title|author|recent&page=N&per_page=N
    def index
      ebooks = Ebook.all

      ebooks = case params[:sort]
               when "title"  then ebooks.by_title
               when "author" then ebooks.by_author
               else               ebooks.by_recent
               end

      ebooks = ebooks.where(file_format: params[:format]) if params[:format].present?

      pagy, paginated = pagy(ebooks, limit: params.fetch(:per_page, 20).to_i)

      render json: {
        ebooks:     ActiveModelSerializers::SerializableResource.new(paginated),
        pagination: pagy_metadata(pagy)
      }
    end

    # GET /api/ebooks/search?q=keyword&sort=...&format=pdf|epub
    def search
      query = params[:q].to_s.strip
      return render json: { ebooks: [], pagination: {} } if query.blank?

      ebooks = Ebook.search_by_query(query)

      ebooks = case params[:sort]
               when "title"  then ebooks.by_title
               when "author" then ebooks.by_author
               else               ebooks.by_recent
               end

      ebooks = ebooks.where(file_format: params[:format]) if params[:format].present?

      pagy, paginated = pagy(ebooks, limit: params.fetch(:per_page, 20).to_i)

      render json: {
        ebooks:     ActiveModelSerializers::SerializableResource.new(paginated),
        query:      query,
        pagination: pagy_metadata(pagy)
      }
    end

    # GET /api/ebooks/:id
    def show
      render json: @ebook
    end

    # POST /api/ebooks
    def create
      @ebook = Ebook.new(ebook_params)

      if @ebook.save
        render json: @ebook, status: :created
      else
        render json: {
          error:   "Failed to upload ebook",
          details: @ebook.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    # GET /api/ebooks/:id/download
    def download
      unless @ebook.file.attached?
        return render_error("File not found", status: :not_found)
      end

      # Send the file inline or as attachment
      blob = @ebook.file.blob
      redirect_to rails_blob_url(blob, disposition: "attachment"), allow_other_host: true
    end

    # PATCH /api/ebooks/:id/read_position
    def read_position
      page = params.require(:page).to_i

      if page >= 0
        @ebook.update_read_position!(page)
        render json: { message: "Position saved", read_position: @ebook.read_position }
      else
        render_error("Invalid page number")
      end
    end

    # DELETE /api/ebooks/:id
    def destroy
      @ebook.file.purge     if @ebook.file.attached?
      @ebook.cover_image.purge if @ebook.cover_image.attached?
      @ebook.destroy!

      render json: { message: "Ebook deleted successfully" }, status: :ok
    end

    private

    def set_ebook
      @ebook = Ebook.find(params[:id])
    end

    def ebook_params
      params.require(:ebook).permit(:title, :author, :description, :file, :cover_image)
    end
  end
end
