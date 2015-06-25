class Account < ActiveRecord::Base

  after_create :insightly_create

  def insightly_create
    Insightly2.client.create_account(self)
  end

end
