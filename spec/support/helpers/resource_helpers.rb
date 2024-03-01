module ResourceHelpers
  def stub_resource(method, resource, request: {}, response: {}, query: {})
    request_body = request.dig(:body) || {}
    request_headers = {"Authorization" => "Bearer #{Revolut::Auth.access_token}"}.merge(request.dig(:headers) || {})
    response_body = response.dig(:body) || {}
    response_headers = response.dig(:headers) || {"Content-Type" => "application/json"}

    stub_request(
      method,
      revolut_url(Revolut::Client.instance.base_uri, path: "/#{resource}", query:)
    )
      .with({body: hash_including(request_body)}.merge(request_headers ? {headers: request_headers} : {}))
      .to_return(
        status: 200,
        body: response_body.to_json,
        headers: response_headers
      )
  end

  private

  def revolut_url(base_uri, path:, query: {})
    File.join(base_uri, path) + "?#{URI.encode_www_form(query)}"
  end
end
