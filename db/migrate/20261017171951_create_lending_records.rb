class CreateLendingRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :items, [ :id, :user_id ], unique: true
    add_check_constraint :items, "length(trim(name)) BETWEEN 1 AND 80", name: "items_name_length"

    create_table :borrowers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email
      t.text :notes
      t.timestamps
    end
    add_index :borrowers, [ :id, :user_id ], unique: true
    add_check_constraint :borrowers, "length(trim(name)) BETWEEN 1 AND 80", name: "borrowers_name_length"

    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :item_id, null: false
      t.bigint :borrower_id, null: false
      t.date :lent_on, null: false
      t.date :due_on, null: false
      t.date :returned_on
      t.text :notes
      t.timestamps
    end
    add_index :loans, :borrower_id
    add_index :loans, [ :user_id, :due_on ]
    add_index :loans, :item_id, unique: true, where: "returned_on IS NULL", name: "one_outstanding_loan_per_item"
    add_foreign_key :loans, :items, column: [ :item_id, :user_id ], primary_key: [ :id, :user_id ]
    add_foreign_key :loans, :borrowers, column: [ :borrower_id, :user_id ], primary_key: [ :id, :user_id ]
    add_check_constraint :loans, "due_on >= lent_on", name: "loan_due_after_lending"
    add_check_constraint :loans, "returned_on IS NULL OR returned_on >= lent_on", name: "loan_return_after_lending"
  end
end
