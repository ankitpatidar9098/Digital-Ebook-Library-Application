# frozen_string_literal: true

# Background job to generate a cover image from PDF first page
# Uses MiniMagick (ImageMagick wrapper) + GhostScript
class GenerateCoverJob < ApplicationJob
  queue_as :default

  def perform(ebook_id)
    ebook = Ebook.find_by(id: ebook_id)
    return unless ebook
    return if ebook.cover_image.attached?
    return unless ebook.file.attached? && ebook.file_format == "pdf"

    # Download PDF blob to a temp file
    ebook.file.blob.open do |temp_pdf|
      generate_cover_from_pdf(ebook, temp_pdf.path)
    end
  rescue StandardError => e
    Rails.logger.warn "[GenerateCoverJob] Failed for ebook #{ebook_id}: #{e.message}"
    # Non-fatal — cover will just remain blank
  end

  private

  def generate_cover_from_pdf(ebook, pdf_path)
    require "mini_magick"

    # Convert first page of PDF to JPEG
    image = MiniMagick::Image.open("#{pdf_path}[0]")
    image.format("jpeg")
    image.resize("400x600>")
    image.colorspace("sRGB")

    Tempfile.create(["cover", ".jpg"]) do |temp_cover|
      image.write(temp_cover.path)
      ebook.cover_image.attach(
        io:           File.open(temp_cover.path),
        filename:     "cover_#{ebook.id}.jpg",
        content_type: "image/jpeg"
      )
    end
  end
end
