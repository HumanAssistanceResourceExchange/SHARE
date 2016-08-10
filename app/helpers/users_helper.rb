module UsersHelper
  def format_email(email_address)
    return '' unless valid_email?(email_address)
    wbr = "<wbr>"
    prefix, at, suffix = email_address.rpartition("@").reject(&:empty?)
    prefix.gsub!(/(\W)/i){ |char| wbr + char }
    suffix.gsub!(/(\W)/i){ |char| wbr + char }

    (prefix + wbr + at + suffix).html_safe
  end

  def valid_email?(email_address)
    return false unless email_address && email_address.kind_of?(String)
    prefix, at, suffix = email_address.rpartition("@").reject(&:empty?)
    return false if prefix.nil? or suffix.nil?

    true
  end
end
