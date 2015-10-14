module GoogleCalendarsHelper

  def cal_link_to(text, cal_id, tag_id)
    link_to text, url_for(id: cal_id), class: "panel #{'active' if @current_calendar.id == cal_id}"
  end

end
