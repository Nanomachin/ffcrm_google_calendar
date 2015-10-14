class GoogleCalendarsController < ApplicationController

  def index
    if current_user.google_calendar_refresh_token.present?
      build_calendar_entries
      redirect_to google_calendar_path(id: primary_calendar_id(@calendar_entries)) and return
    else
      redirect_to calendar_list.connection.authorize_url.to_s
    end

  end

  def show
    build_calendar_entries
    @current_calendar = @calendar_entries.select{|cal| cal.id == params[:id]}.first
  end

  def auth_redirect

    #initiate connection with google using auth code
    refresh_token = calendar_list.connection.login_with_auth_code(params[:code])

    #store refresh token in the user model
    current_user.update(google_calendar_refresh_token: refresh_token)

    redirect_to google_calendars_path and return

  end

  private

    def calendar_list
      @calendar_list ||= Google::CalendarList.new({
        client_id: Setting.google_calendar_api_client_id,
        client_secret: Setting.google_calendar_api_client_secret,
        redirect_url: google_calendars_auth_redirect_url
      })

    end

    def build_calendar_entries

      #start connection with refesh token and fetch entries
      calendar_list.connection.login_with_refresh_token(current_user.google_calendar_refresh_token)
      @calendar_entries = calendar_list.fetch_entries

      #reject calendar entries with ids from the blacklist
      @calendar_entries.reject!{|entry| Setting.google_calendar_blacklist_ids.any?{|black| entry.id.include? black}}

      @calendar_entries.sort!{|a, b| a.summary.downcase <=> b.summary.downcase}

    end

    def primary_calendar_id(calendar_entries)
      calendar_entries.select{|cal| cal.primary == true }.first.id
    end

end
