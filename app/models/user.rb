class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :omniauthable #, :confirmable # TODO: Determine what to do with confirmable
  include DeviseTokenAuth::Concerns::User

  has_many :recipes, dependent: :destroy
  has_many :recipe_parses, dependent: :destroy
  
end
