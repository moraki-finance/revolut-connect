# Revolut Connect


|  Tests |  Coverage  |
|:-:|:-:|
| [![Tests](https://github.com/moraki-finance/revolut-connect/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/moraki-finance/revolut-connect/actions/workflows/main.yml)  |  [![Codecov Coverage](https://codecov.io/github/moraki-finance/revolut-connect/graph/badge.svg?token=SKTT14JJGV)](https://codecov.io/github/moraki-finance/revolut-connect) |

A lightweight API client for Revolut featuring authentication, permission scopes, token expiration and automatic renewal, webhooks, webhook events, and much more!

Revolut docs: <https://developer.revolut.com/>

_:warning: The extracted API objects don't do input parameters validations. It's a simple faraday wrapper that allows you to send as many inputs as you want. The Revolut API might fail when passing a wrong set of parameters._

_:warning: For now this connector only supports the [Business API](https://developer.revolut.com/docs/business/business-api). Pull requests are welcomed to support other APIs._

## Supported APIs & Resources

### Business API

- `Account`
- `Counterparty`
- `Payment`
- `Transaction`
- `TransferReason`
- `Webhook`

## :construction: Roadmap

### Business API

- `Card` resource
- `ForeignExchange` resource
- `PaymentDraft` resource
- `PayoutLink` resource
- `Simulation` resource
- `TeamMember` resource
- `Transfer` resource

### Merchants API

- Authentication
- Resources

### Open Banking API

- Authentication
- Resources

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
  bundle add revolut-connect
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
  gem install revolut-connect
```

## Usage

### First Time Authorization

1. Generate a certificate for your API integration and register the API into your Revolut business account by following [this tutorial](https://developer.revolut.com/docs/guides/manage-accounts/get-started/make-your-first-api-request#1-add-your-certificate).

2. From the step above, you'll need to copy the `client id`, the `private key` and the `iss` values that Revolut asks you to generate. We'll set these as environment variables as follows:

    ```text
      REVOLUT_CLIENT_ID={YOUR APP CLIENT ID}
      REVOLUT_SIGNING_KEY="{YOUR APP SIGNING KEY IN ONE LINE JOINED BY NEW LINES (e.g: -----BEGIN PRIVATE KEY-----\n....)}"
      REVOLUT_ISS={YOUR ISS}
    ```

3. Set the Revolut authorization redirect URI. This URI is what Revolut will use to redirect to after the user has authorized the API to access the account. Revolut will redirect to this URL adding a `code` query param that we'll need to exchange for the first access token ([reference](https://developer.revolut.com/docs/guides/manage-accounts/get-started/make-your-first-api-request#3-consent-to-the-application)):

    ```text
    REVOLUT_AUTHORIZE_REDIRECT_URI={YOUR REVOLUT AUTH HANDLING DOMAIN}
    ```

4. In revolut, after adding all the API details (uploading the certificate, iss, etc), enable the API. This will take you to the APP authorization consent form. After you authorize the app, you should be redirected to the domain you set in the configuration with the authorization `code` in query params. Copy this code.

    ![Screenshot 2024-03-01 at 6 45 45 AM](https://github.com/moraki-finance/revolut-connect/assets/3678598/94f3e3c0-143d-40e7-9f14-69d1ea4f68f5)

    ![Screenshot 2024-03-01 at 6 46 11 AM](https://github.com/moraki-finance/revolut-connect/assets/3678598/a9c2a55d-3e7d-420c-8d9d-c9617438856f)

5. Exchange the code for your first time access token:

    ```rb
    revolut_auth = Revolut::Auth.exchange(authorization_code: "{CODE YOU COPIED IN PREVIOUS STEP}")
    ```

6. This will return a `Revolut::Auth` object with the access token in it. It's highly recommended that you persist this information somewhere so that it can later be loaded without needing to go through this code exchange process again:

    ```rb
    auth_to_persist = revolut_auth.to_json # Persist this somewhere (database, redis, etc.). Remember to encrypt it if you persist it.
    ```

    And then, when you need to load the auth again:

    ```rb
    Revolut::Auth.load(auth_to_persist)
    ```

    You can also store this json in an environment variable and the gem will auto load it:

    ```text
      REVOLUT_AUTH_JSON={auth_to_persist}
    ```

    :tada: You're all set to start using the API.

### Configuration

In rails applications, it's standard to provide an initializer (e.g `config/initializers/revolut.rb`) to load all the configuration settings of the gem. If you follow the previous step (First Time Authorization), you can do the following:

```rb
Revolut.configure do |config|
  # Your app client id. Typically stored in the environment variables as it's a sensitive secret.
  config.client_id = ENV["REVOLUT_CLIENT_ID"]

  # Your app private key. Typically stored in the environment variables as it's a sensitive secret.
  config.signing_key = ENV["REVOLUT_SIGNING_KEY"]

  # The URI that Revolut will redirect to upon a successful authorization.
  # Used to get the authorization code and exchange it for an access_token.
  config.authorize_redirect_uri = ENV["REVOLUT_AUTHORIZE_REDIRECT_URI"]

  # Optional: JWT issuer domain. Typically your app domain.
  # Default: example.com
  config.iss = ENV["REVOLUT_ISS"]

  # Optional: JWT token duration. After this duration, the token will be renewed (for security reasons, in case of token leakage)
  # Default: 120 seconds (2 minutes).
  config.token_duration = ENV["REVOLUT_TOKEN_DURATION"]

  # Optional: Revolut authorization scope. You can restrict which features the app will have access to by passing different scopes.
  # More info in https://developer.revolut.com/docs/business/business-api
  # Default: nil
  config.scope = ENV["REVOLUT_SCOPE"]

  # Optional: Timeout of the underlying faraday requests.
  # Default: 120
  config.request_timeout = 120

  # Optional: Set extra headers that will get attached to every revolut api request.
  # Useful for observability tools like Helicone: https://www.helicone.ai/
  # Default: {}
  config.global_headers = {
    "Helicone-Auth": "Bearer {HELICONE_API_KEY}"
    "helicone-stream-force-format" => "true",
  }

  # Optional: Set the environment to be production or sandbox.
  # Default: sandbox
  config.environment = ENV["REVOLUT_ENVIRONMENT"]

  # Optional: The JWT for an already exchanged token.
  # Used to preload an existing auth token so that you don't have to exchange / renew it again.
  config.auth_json = ENV["REVOLUT_AUTH_JSON"]

  # Optional: The revolut api version used. Generally used to hit the webhooks API as it requires api_version 2.0.
  # Default: "1.0".
  config.api_version = ENV["REVOLUT_API_VERSION"]
end
```

If you're setting the `auth_json` config, rembember to call `Revolut::Auth.load_from_env` right after the configuration is set so that the gem loads this JSON you just set:

```rb
Revolute.configure do |config|
  ...
  config.auth_json = ENV.fetch("REVOLUT_AUTH_JSON", nil)
end

# Load the `auth_json` value.
Revolut::Auth.load_from_env
```

### Resources

#### Accounts

<https://developer.revolut.com/docs/business/accounts>

```rb
# List revolut accounts
accounts = Revolut::Account.list

# Retrieve a single account
account = Revolut::Account.retrieve(accounts.last.id)

# List bank accounts
bank_details = Revolut::Account.bank_details(accounts.last.id)
```

#### Counterparties

<https://developer.revolut.com/docs/business/counterparties>

```rb
# List counterparties
counterparties = Revolut::Counterparty.list

# Create a counterparty
created_counterparty = Revolut::Counterparty.create(
  profile_type: "personal",
  name: "John Smith",
  revtag: "johnsmith"
)

# Retrieve a counterparty
retrieved_counterparty = Revolut::Counterparty.retrieve(created_counterparty.id)

# Delete a counterparty
deleted = Revolut::Counterparty.delete(retrieved_counterparty.id)
```

#### Payments

<https://developer.revolut.com/docs/business/create-payment>

```rb
# Create a payment transaction
payment = Revolut::Payment.create(
  request_id: "49c6a48b-6b58-40a0-b974-0b8c4888c8a7", # Your app's own payment ID.
  account_id: "af98333c-ea53-482b-93c2-1fa5e4eae671",
  receiver: {
    counterparty_id: "49c6a48b-6b58-40a0-b974-0b8c4888c8a7",
    account_id: "9116f03a-c074-4585-b261-18a706b3768b"
  },
  amount: 1000.99,
  charge_bearer: "debtor",
  currency: "EUR",
  reference: "To John Doe"
)

# List payment transactions
transactions = Revolut::Payment.list

# Retrieve a payment transaction
transaction = Revolut::Payment.retrieve(payment.id)

# Delete a payment transaction
deleted = Revolut::Payment.delete(transaction.id)
```

## Development

You can use `bin/console` to access an interactive console. This will preload environment variables from a `.env` file.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/moraki-finance/revolut-connect>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/moraki-finance/revolut-connect/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Revolut::Connect project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/revolut-connect/blob/main/CODE_OF_CONDUCT.md).
