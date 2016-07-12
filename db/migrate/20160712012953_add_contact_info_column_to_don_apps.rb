class AddContactInfoColumnToDonApps < ActiveRecord::Migration
  def change
    add_column :donation_applications, :contact_info_id, :integer
  end
end
