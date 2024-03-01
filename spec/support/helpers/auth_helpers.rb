module AuthHelpers
  def stub_client_assertion
    payload = {
      iss: Revolut.config.iss,
      sub: Revolut.config.client_id,
      aud: "https://revolut.com",
      exp: Time.now.to_i + 120 # Expires in 2 minutes
    }

    header = {
      alg: "RS256",
      typ: "JWT"
    }
    allow(OpenSSL::PKey::RSA).to receive(:new).and_return("key")
    allow(JWT).to receive(:encode).with(payload, "key", "RS256", header).and_return("stubbed_client_assertion")
  end

  def token_exchange_response
    {
      token_type: "bearer",
      access_token: "fake_access_token",
      expires_in: 2399,
      refresh_token: "fake_refresh_token"
    }
  end

  def stub_token_exchange(authorization_code: "fake")
    stub_client_assertion
    stub_request(:post, "https://sandbox-b2b.revolut.com/api/1.0/auth/token")
      .with(
        body: {
          "client_assertion" => "stubbed_client_assertion",
          "client_assertion_type" => "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          "code" => authorization_code,
          "grant_type" => "authorization_code"
        },
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "Ruby"
        }
      )
      .to_return(status: 200, body: token_exchange_response.to_json, headers: {})
  end

  def token_refresh_response
    {
      token_type: "bearer",
      access_token: "fake_access_token",
      expires_in: 2399
    }
  end

  def stub_token_refresh(refresh_token:)
    stub_client_assertion
    stub_request(:post, "https://sandbox-b2b.revolut.com/api/1.0/auth/token")
      .with(
        body: {
          "client_assertion" => "stubbed_client_assertion",
          "client_assertion_type" => "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          "refresh_token" => refresh_token,
          "grant_type" => "refresh_token"
        },
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "Ruby"
        }
      )
      .to_return(status: 200, body: token_refresh_response.to_json, headers: {})
  end

  def stub_authentication
    allow(Revolut::Auth).to receive(:access_token).and_return("fake_access_token")
  end
end
