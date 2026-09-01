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

    rails_blob_url(object.file, only_path: false)
  rescue StandardError
    nil
  end

  def cover_url
    return nil unless object.cover_image.attached?

    rails_blob_url(object.cover_image, only_path: false)
  rescue StandardError
    nil
  end

  def filename
    return nil unless object.file.attached?

    object.file.filename.to_s
  end
end
