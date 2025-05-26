class AddApprovalToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :approved, :boolean, default: false
    add_reference :events, :submitted_by, foreign_key: { to_table: :users }
  end
end
