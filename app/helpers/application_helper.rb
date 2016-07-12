module ApplicationHelper
  def formatted_price(amount)
    sprintf("$%0.2f USD", amount)
  end
end
