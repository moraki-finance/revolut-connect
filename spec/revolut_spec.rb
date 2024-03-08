# frozen_string_literal: true

RSpec.describe Revolut do
  it "has a version number" do
    expect(Revolut::VERSION).to eq "0.1.5"
  end

  it "allows to configure" do
    Revolut.configure do |config|
      config.client_id = "client_id"
    end
    expect(Revolut.config.client_id).to eq("client_id")
  end
end
