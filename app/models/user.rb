class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :paid_settlements, class_name: "Settlement", foreign_key: "payer_id"
  has_many :received_settlements, class_name: "Settlement", foreign_key: "payee_id"

  has_many :journal_transactions
end
