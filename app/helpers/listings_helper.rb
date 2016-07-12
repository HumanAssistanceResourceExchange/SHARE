module ListingsHelper
  def date_format(time)
    formatted_date = time.strftime("%d %b %Y") unless time.nil?
    formatted_date ||= ''
  end
end
