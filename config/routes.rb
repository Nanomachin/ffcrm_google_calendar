Rails.application.routes.draw do

  scope "google_calendars" do

    get '/',              to: 'google_calendars#index',         as: 'google_calendars'
    get '/auth_redirect', to: 'google_calendars#auth_redirect', as: 'google_calendars_auth_redirect'
    get '/:id',           to: 'google_calendars#show',          as: 'google_calendar'

  end

end