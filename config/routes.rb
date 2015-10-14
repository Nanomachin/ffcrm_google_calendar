Rails.application.routes.draw do

  get 'googlecalendar/login', to: 'google_calendars#index'
  get 'googlecalendar/redirect', to: 'google_calendars#redirect', as: 'google_calendar_redirect'
  get 'goooglecalendar', to: 'google_calendars#panel', as: 'google_calendar'

end
