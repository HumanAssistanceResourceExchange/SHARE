class ContactInfo < ActiveRecord::Base
  belongs_to :user

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true

  def last_and_first
    @last_and_first = last_name + ', ' + first_name
  end

  def first_and_last
    @first_and_last = first_name + ' ' + last_name
  end
end
