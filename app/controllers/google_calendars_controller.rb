class GoogleCalendarsController < ApplicationController

  def index
    if current_user.google_calendar_refresh_token.present?
      redirect_to google_calendar_path and return
    else
      redirect_to calendar_list.connection.authorize_url.to_s
    end

  end

  def panel

    #start connection with refesh token and fetch entries
    calendar_list.connection.login_with_refresh_token(current_user.google_calendar_refresh_token)
    @calendar_entries = calendar_list.fetch_entries

    #set blacklist
    blacklist_ids = ["#contacts@group.v.calendar.google.com",
                      "#holiday@group.v.calendar.google.com",
                      "#weeknum@group.v.calendar.google.com"]

    #reject calendar entries with ids from the blacklist
    @calendar_entries.reject!{|entry| blacklist_ids.any?{|black| entry.id.include? black}}

    #load the calendar given in parameters if it's present and valid - otherwise load the primary calendar
    if params[:id]
      @current_calendar = @calendar_entries.select{|cal| cal.id == params[:id]}.first
    else
      @current_calendar = @calendar_entries.select{|cal| cal.primary == true }.first
    end

  end

  def redirect

    #initiate connection with google using auth code
    refresh_token = calendar_list.connection.login_with_auth_code(params[:code])

    #store refresh token in the user model
    current_user.update(google_calendar_refresh_token: refresh_token)

    #
    redirect_to google_calendar_path and return

  end

  private

    def calendar_list
      @calendar_list ||= Google::CalendarList.new({
        client_id: ENV['GOOGLE_CALENDAR_CLIENT_ID'],
        client_secret: ENV['GOOGLE_CALENDAR_CLIENT_SECRET'],
        redirect_url: google_calendar_redirect_url
      })

    end

end
