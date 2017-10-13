class User < ApplicationRecord
  has_many :notifications, foreign_key: :recipient_id
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :masqueradable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates :first_name, :last_name, presence: true

  def name
    "#{first_name} #{last_name}"
  end
end
