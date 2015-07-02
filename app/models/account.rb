class Account < ActiveRecord::Base

  after_create :insightly_create

  def insightly_create
    InsightlyWrapper.create_account(self)
  end

end
