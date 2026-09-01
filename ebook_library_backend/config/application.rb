require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module EbookLibraryBackend
  class Application < Rails::Application
    config.load_defaults 7.2

    # API only mode
    config.api_only = true

    # Active Storage: use disk service for local development
    config.active_storage.service = :local

    # CORS — allow all origins for local Flutter dev
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*",
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          expose:  ["Content-Disposition"]
      end
    end
  end
end
