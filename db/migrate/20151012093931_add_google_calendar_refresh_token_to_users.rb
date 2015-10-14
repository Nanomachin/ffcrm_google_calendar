class AddGoogleCalendarRefreshTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :google_calendar_refresh_token, :string
  end
end
