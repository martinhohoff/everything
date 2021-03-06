class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :points
  has_many :movies, through: :points
  has_one :profile, dependent: :destroy
  mount_uploader :photo, PhotoUploader
end
