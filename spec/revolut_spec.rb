# frozen_string_literal: true

RSpec.describe Revolut do
  it "has a version number" do
    expect(Revolut::VERSION).not_to be nil
  end

  it "allows to configure" do
    Revolut.configure do |config|
      config.client_id = "client_id"
    end
    expect(Revolut.config.client_id).to eq("client_id")
  end
end
