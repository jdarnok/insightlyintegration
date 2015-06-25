class Organisation < ActiveRecord::Base
  belongs_to :user

  after_create :insightly_create
  def insightly_create
      Insightly2.client.insightly_create_organisation(self)
  end

  def insightly_update
    Insightly2.client.update_organisation(organisation: insightly_payload(true))
  rescue Insightly2::Errors::ResourceNotFoundError => e
    insightly_create
  end

  def insightly_update
    Insightly2.client.update_organisation(organisation: insightly_payload(true, true))
  rescue Insightly2::Errors::ResourceNotFoundError => e
    insightly_create
    Insightly2.client.update_organisation(organisation: insightly_payload(true, true))
  end
end
