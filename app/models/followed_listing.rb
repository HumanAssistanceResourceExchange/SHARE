class FollowedListing < ActiveRecord::Base
  belongs_to :follower, class_name: "User", foreign_key: "user_id"
  belongs_to :listing
  has_one :contact, class_name: 'ContactInfo', foreign_key: 'contact_info_id', through: :follower, source: :contact_infos
end
