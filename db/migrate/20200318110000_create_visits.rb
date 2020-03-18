# frozen_string_literal: true

# Creating Visits table
class CreateVisits < ActiveRecord::Migration[5.0]
  def change
    create_table :visits do |t|
      t.string 'evid'
      t.string 'vendor_site_id'
      t.string 'vendor_visit_id'
      t.string 'visit_ip'
      t.string 'vendor_visitor_id'
    end
  end
end
