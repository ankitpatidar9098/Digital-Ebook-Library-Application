# frozen_string_literal: true

FactoryBot.define do
  factory :ebook do
    title  { Faker::Book.title }
    author { Faker::Book.author }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    file_format { "pdf" }
    file_size   { rand(100_000..5_000_000) }

    after(:build) do |ebook|
      unless ebook.file.attached?
        pdf_content = "%PDF-1.4\n1 0 obj<</Type /Catalog>>endobj\ntrailer<</Root 1 0 R>>\n%%EOF"
        ebook.file.attach(
          io:           StringIO.new(pdf_content),
          filename:     "#{ebook.title.parameterize}.pdf",
          content_type: "application/pdf"
        )
      end
    end

    trait :epub do
      file_format { "epub" }
      after(:build) do |ebook|
        ebook.file.attach(
          io:           StringIO.new("PK\x03\x04" + "epub-minimal-content"),
          filename:     "#{ebook.title.parameterize}.epub",
          content_type: "application/epub+zip"
        )
      end
    end

    trait :with_cover do
      after(:build) do |ebook|
        # 1x1 pixel transparent PNG
        png_data = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x18\xd8N\x00\x00\x00\x00IEND\xaeB`\x82"
        ebook.cover_image.attach(
          io:           StringIO.new(png_data),
          filename:     "cover.png",
          content_type: "image/png"
        )
      end
    end

    trait :recently_read do
      last_read_at  { 1.hour.ago }
      read_position { 42 }
    end
  end
end
