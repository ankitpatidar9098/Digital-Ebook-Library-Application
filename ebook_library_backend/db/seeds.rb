# frozen_string_literal: true
# db/seeds.rb

puts "Seeding database..."
Ebook.destroy_all
puts "  Cleared existing ebooks."

sample_ebooks = [
  { title: "The Great Gatsby",       author: "F. Scott Fitzgerald", description: "A story of the mysteriously wealthy Jay Gatsby and his love for Daisy Buchanan." },
  { title: "To Kill a Mockingbird",  author: "Harper Lee",          description: "The story of racial injustice and moral growth in the American South." },
  { title: "1984",                   author: "George Orwell",       description: "A dystopian social science fiction novel about Big Brother's totalitarian regime." },
  { title: "Pride and Prejudice",    author: "Jane Austen",         description: "A classic romantic novel about the Bennett family and Mr. Darcy." },
  { title: "The Hobbit",             author: "J.R.R. Tolkien",      description: "Bilbo Baggins is swept into an epic quest to reclaim the Lonely Mountain." },
  { title: "Dune",                   author: "Frank Herbert",       description: "A science fiction epic set in a desert world called Arrakis." },
  { title: "Sapiens",                author: "Yuval Noah Harari",   description: "A brief history of humankind from the Stone Age to the 21st century." },
  { title: "The Lean Startup",       author: "Eric Ries",           description: "How today's entrepreneurs use continuous innovation to create successful businesses." }
]

# Minimal valid PDF content
pdf_content = "%PDF-1.4\n1 0 obj<</Type /Catalog /Pages 2 0 R>>endobj\n2 0 obj<</Type /Pages /Kids [3 0 R] /Count 1>>endobj\n3 0 obj<</Type /Page /MediaBox [0 0 612 792]>>endobj\nxref\n0 4\n0000000000 65535 f\n0000000009 00000 n\n0000000058 00000 n\n0000000115 00000 n\ntrailer<</Size 4 /Root 1 0 R>>\nstartxref\n174\n%%EOF"

sample_ebooks.each do |attrs|
  ebook = Ebook.new(
    title:       attrs[:title],
    author:      attrs[:author],
    description: attrs[:description],
    file_format: "pdf",
    file_size:   rand(500_000..5_000_000)
  )
  ebook.file.attach(
    io:           StringIO.new(pdf_content),
    filename:     "#{attrs[:title].parameterize}.pdf",
    content_type: "application/pdf"
  )
  if ebook.save
    puts "  Created: #{ebook.title}"
  else
    puts "  Failed:  #{ebook.title} — #{ebook.errors.full_messages.join(', ')}"
  end
end

puts "\nDone! #{Ebook.count} ebooks seeded."
