module Revolut
  class Rate < Resource
    shallow

    def self.resource_name
      "rate"
    end

    def self.rate(**)
      response = http_client.get("/#{resource_name}", **)

      new(response.body)
    end
  end
end
