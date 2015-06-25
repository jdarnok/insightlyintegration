class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :insightly_create
  has_one :organisation
  def insightly_create
    Insightly2.client.insightly_create_contact(contact: self)
  end



end
