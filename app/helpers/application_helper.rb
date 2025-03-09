module ApplicationHelper
  def omniauth_provider_pretty_name(provider)
    case provider
    when :google_oauth2
      "Google"
    when :entra_id
      "Microsoft"
    else
      OmniAuth::Utils.camelize(provider.to_s)
    end
  end
end
