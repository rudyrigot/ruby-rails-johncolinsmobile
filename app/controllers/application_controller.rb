class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_ref

  def index
    @document = PrismicService.get_document(api.bookmark("home"), api, @ref)
    @arguments = api.create_search_form('arguments').submit(@ref)
  end

  def gallery
    @document = PrismicService.get_document(api.bookmark("gallery"), api, @ref)
  end

  def photo
    @photo = PrismicService.get_document(api.bookmark("gallery"), api, @ref).fragments['photo'].fragments[params[:id].to_i]
  end

  def menu
    @menupages = api.create_search_form('menupages').submit(@ref)
  end

  def get_callback_url
    callback_url(redirect_uri: request.env['referer'])
  end

  def signin
    url = api.oauth_initiate_url({
      client_id: PrismicService.config("client_id"),
      redirect_uri: get_callback_url,
      scope: "master+releases"
    })
    redirect_to url
  end

  def callback
    access_token = api.oauth_check_token({
      grant_type: "authorization_code",
      code: params[:code],
      redirect_uri: get_callback_url,
      client_id: PrismicService.config("client_id"),
      client_secret: PrismicService.config("client_secret"),
    })
    if access_token
      session['ACCESS_TOKEN'] = access_token
      url = params['redirect_uri'] || root_path
      redirect_to url
    else
      render "Can't sign you in", status: :unauthorized
    end
  end

  def signout
    session['ACCESS_TOKEN'] = nil
    redirect_to :root
  end

  private

  def set_ref
    @ref = params[:ref].blank? ? api.master_ref.ref : params[:ref]
  end

  def api
    @access_token = session['ACCESS_TOKEN']
    @api ||= PrismicService.init_api(@access_token)
  end

end
