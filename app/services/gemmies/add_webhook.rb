require 'gems'

module Gemmies
  class AddWebhook < Services::Base
    def call(gemmy)
      Gems.add_web_hook gemmy.name, api_releases_url
    end
  end
end
