class AddEmailToContactInfo < ActiveRecord::Migration
  def change
    add_column :contact_infos, :email, :string
  end
end
