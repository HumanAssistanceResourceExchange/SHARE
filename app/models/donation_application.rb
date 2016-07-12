class DonationApplication < ActiveRecord::Base
  belongs_to :applicant, class_name: "User", foreign_key: "user_id"
  belongs_to :listing
  belongs_to :contact, class_name: "ContactInfo", foreign_key: "contact_info_id"
end
