class RedirectController < ApplicationController
  skip_before_filter :authorized_doc_center_user
  def login
    login_redirect
  end

  private

  def marketplace_openid_url
    begin
      params["openid"].split("/")[0...-1].join("/") if params["openid"]
    rescue URI::InvalidURIError => err
      false
    end
  end

  def channel_partner
    openid = OpenIDUrl.where("open_id_url = ?", marketplace_openid_url).first
    if openid
      return openid.channel_partner
    else
      return nil
    end
  end

  def request_host
    request.host_with_port.split(".").slice(-3, 3).join(".")
  end

  def login_redirect
    if marketplace_openid_url.blank? or channel_partner.blank?
      render_403
    elsif channel_partner.is_multitenant?
      redirect_to "http://#{channel_partner.subdomain}.#{request_host}/auth/appdirect?openid_url=#{marketplace_openid_url}"
    else
      redirect_to "http://#{channel_partner.subdomain}.#{request_host}/auth/appdirect"
    end
  end

end