require_relative 'persistence'

class GraphAuth
  CLIENT_ID = ENV['GRAPH_CLIENT_ID']
  CLIENT_SECRET = ENV['GRAPH_CLIENT_SECRET']

  # Scopes required by the app
  SCOPES = ['openid',
            'profile',
            'User.Read',
            'Mail.Read',
            'Mail.Send',
            'Mail.Read.Shared',
            'Mail.ReadWrite',
            'Mail.ReadWrite.Shared',
            'Mail.Send.Shared',
            'email',
            'offline_access',
            'User.ReadBasic.All'
  ]

  REDIRECT_URI = 'https://3a911482.ngrok.io'
  CREDSTORE = PERSISTENCE::Creds.new

  def access_token
    get_access_token
  end

  def full_token
    CREDSTORE.get('credentials')
  end

  # Generates the login URL for the app.
  def get_login_url
    client = OAuth2::Client.new(ENV['GRAPH_CLIENT_ID'],
                                ENV['GRAPH_CLIENT_SECRET'],
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v2.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')

    redirect_url = client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI, :scope => SCOPES.join(' '))
    puts "Generated login URL is #{redirect_url}"
    redirect_url
  end

  def get_token_from_code(auth_code)
    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v1.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')

    token = client.auth_code.get_token(auth_code,
                                       :redirect_uri => REDIRECT_URI,
                                       :scope => SCOPES.join(' '))
    CREDSTORE.set('credentials', token.to_hash)

    token.to_hash
  end

  private

  def get_access_token
    # Get the current token from storage
    token_hash = CREDSTORE.get('credentials')


    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v2.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')

    token = OAuth2::AccessToken.from_hash(client, token_hash)

    # Check if token is expired, refresh if so
    if token.expired?
      puts 'Token is expired, refreshing'
      new_token = token.refresh!
      # Save new token
      CREDSTORE.set('credentials', new_token.to_hash)
      access_token = new_token.token
    else
      access_token = token.token
    end
    access_token
  end

end