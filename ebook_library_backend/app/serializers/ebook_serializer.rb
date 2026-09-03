# frozen_string_literal: true

class EbookSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :author,
             :file_format,
             :file_size,
             :file_size_human,
             :description,
             :read_position,
             :last_read_at,
             :created_at,
             :updated_at,
             :file_url,
             :cover_url,
             :filename

  def file_url
    return nil unless object.file.attached?

    Rails.application.routes.url_helpers.rails_blob_path(object.file, only_path: true)
  rescue StandardError => e
    Rails.logger.error("File URL Error: #{e.message}")
    nil
  end

  def cover_url
    return nil unless object.cover_image.attached?

    Rails.application.routes.url_helpers.rails_blob_path(object.cover_image, only_path: true)
  rescue StandardError => e
    Rails.logger.error("Cover URL Error: #{e.message}")
    nil
  end

  def filename
    return nil unless object.file.attached?

    object.file.filename.to_s
  end
end
