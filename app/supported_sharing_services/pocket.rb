class Pocket < Service
  include HTTParty
  base_uri 'https://getpocket.com/v3'
  headers 'Content-Type' => 'application/json; charset=UTF-8', 'X-Accept' => 'application/json'

  def initialize(klass = nil)
    @klass = klass
    if @klass.present?
      @access_token = @klass.access_token
    end
  end

  def redirect_url(token)
    if token.present?
      uri = URI.parse(self.class.base_uri)
      uri.path = '/auth/authorize'
      uri.query = { 'request_token' => token, 'redirect_uri' => redirect_uri }.to_query
      uri.to_s
    else
      false
    end
  end

  def request_token
    options = {
      body: {consumer_key: ENV['POCKET_CONSUMER_KEY'], redirect_uri: redirect_uri}.to_json
    }
    self.class.post('/oauth/request', options)
  end

  def oauth2_pocket_authorize(code)
    options = {
      body: {consumer_key: ENV['POCKET_CONSUMER_KEY'], code: code}.to_json
    }
    self.class.post('/oauth/authorize', options)
  end

  def add(params)
    options = {
      body: { url: params['entry_url'], access_token: @access_token, consumer_key: ENV['POCKET_CONSUMER_KEY'] }.to_json
    }
    self.class.post('/add', options).code
  end

  def redirect_uri
    Rails.application.routes.url_helpers.oauth2_pocket_response_supported_sharing_service_url('pocket', host: ENV['PUSH_URL'])
  end

  def share(params)
    authenticated_share(@klass, params)
  end

end