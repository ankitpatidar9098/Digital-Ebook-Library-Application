# frozen_string_literal: true

class Ebook < ApplicationRecord
  # File attachments via Active Storage
  has_one_attached :file
  has_one_attached :cover_image

  # Allowed MIME types
  ALLOWED_CONTENT_TYPES = %w[
    application/pdf
    application/epub+zip
  ].freeze

  ALLOWED_EXTENSIONS = %w[.pdf .epub].freeze
  MAX_FILE_SIZE = 50.megabytes

  # Validations
  validates :title,  presence: true, length: { maximum: 255 }
  validates :author, length: { maximum: 255 }, allow_blank: true
  validates :file_format, presence: true, inclusion: { in: %w[pdf epub] }

  validate :file_must_be_attached
  validate :file_content_type_valid
  validate :file_size_within_limit

  # Callbacks
  before_validation :set_file_metadata, if: -> { file.attached? && file.blob.present? }
  after_create :generate_cover_if_missing

  # Scopes
  scope :by_title,   -> { order(:title) }
  scope :by_author,  -> { order(:author) }
  scope :by_recent,  -> { order(created_at: :desc) }
  scope :recently_read, -> { where.not(last_read_at: nil).order(last_read_at: :desc) }

  scope :search_by_query, ->(query) {
    term = "%#{query.downcase}%"
    where(
      "LOWER(title) LIKE ? OR LOWER(author) LIKE ? OR LOWER(ebooks.title) LIKE ?",
      term, term, term
    ).or(
      joins(file_attachment: :blob)
        .where("LOWER(active_storage_blobs.filename) LIKE ?", term)
    )
  }

  # Public instance methods

  # Update read position for "last read" tracking
  def update_read_position!(page)
    update!(read_position: page.to_i, last_read_at: Time.current)
  end

  # Human-readable file size
  def file_size_human
    return "Unknown" if file_size.zero?

    if file_size >= 1.megabyte
      "#{(file_size.to_f / 1.megabyte).round(1)} MB"
    elsif file_size >= 1.kilobyte
      "#{(file_size.to_f / 1.kilobyte).round(1)} KB"
    else
      "#{file_size} B"
    end
  end

  private

  def file_must_be_attached
    errors.add(:file, "must be attached") unless file.attached?
  end

  def set_file_metadata
    blob = file.blob
    self.file_format = detect_format(blob.content_type, blob.filename.to_s)
    self.file_size   = blob.byte_size
  end

  def detect_format(content_type, filename)
    return "epub" if content_type == "application/epub+zip" || filename.downcase.end_with?(".epub")
    return "pdf"  if content_type == "application/pdf"      || filename.downcase.end_with?(".pdf")

    "unknown"
  end

  def file_content_type_valid
    return unless file.attached?

    blob_ct   = file.blob&.content_type || ""
    blob_name = file.blob&.filename&.to_s || ""

    unless ALLOWED_CONTENT_TYPES.include?(blob_ct) ||
           ALLOWED_EXTENSIONS.any? { |ext| blob_name.downcase.end_with?(ext) }
      errors.add(:file, "must be a PDF or EPUB file")
    end
  end

  def file_size_within_limit
    return unless file.attached?
    return unless file.blob&.byte_size

    if file.blob.byte_size > MAX_FILE_SIZE
      errors.add(:file, "is too large (maximum #{MAX_FILE_SIZE / 1.megabyte}MB allowed)")
    end
  end

  # Auto-generate cover image from first page of PDF
  # Requires ImageMagick (convert) installed on the system
  def generate_cover_if_missing
    return if cover_image.attached?
    return unless file_format == "pdf"

    GenerateCoverJob.perform_later(id)
  end
end
