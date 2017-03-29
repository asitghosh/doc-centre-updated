class CreateFaqsTable < ActiveRecord::Migration
  def change
    #action, subject_class, subject_id
    create_table :faqs do |t|
      t.string :question
      t.text :answer
      t.string :pub_status
      t.timestamps
    end
  end
end
