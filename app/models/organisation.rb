class Organisation < ActiveRecord::Base
  belongs_to :user

  after_create :insightly_create
  def insightly_create

      contact = Insightly2.client.create_organisation(organisation: insightly_payload)
      self.update_attributes(organisation_id: contact.organisation_id)
  end
  def insightly_update
      Insightly2.client.update_organisation(organisation: insightly_payload(true))
  end

  def insightly_update_order
    Insightly2.client.update_organisation(organisation: insightly_payload(true,true))
  end

  private
  def insightly_payload(update = false, order = false)
    payload = { :organisation_name=> self.name,
    #  :OWNER_USER_ID=> self.owner_id,
     :VISIBLE_TO=>"EVERYONE",
     :VISIBLE_TEAM_ID=>nil,
     :VISIBLE_USER_IDS=>nil,
    #  :CUSTOMFIELDS=>[{
    #    :CUSTOM_FIELD_ID=> "ORGANISATION_FIELD_1",
    #    :FIELD_VALUE=> Time.zone.now.strftime("%Y-%m-%d")}
    #  ],
     :ADDRESSES=>[{
       :ADDRESS_TYPE=>"Work",
       :STREET=> self.address,
       :CITY=> self.city,
       :STATE=> self.state,
       :POSTCODE=> self.postcode,
       :COUNTRY=> self.country}],
     :CONTACTINFOS=>
     [{
       :type=>"Email",
       :subtype=>"",
       :label=>"Work",
       :detail=> self.email},
       { :type=>"Phone",
         :subtype=>"",
         :label=>"Work",
         :detail=> self.phone}],
     :DATES=>[],
     :TAGS=>[],
     :LINKS=>[],
     :ORGANISATIONLINKS=>[],
     :EMAILLINKS=>[] }
     payload.merge!({:organisation_id=> self.organisation_id}) if update
     payload.merge!({:date_created_utc=> Time.zone.now.strftime("%Y-%m-%d %H:%M:%S")}) unless update
     payload.merge!({:date_updated_utc=>Time.zone.now.strftime("%Y-%m-%d %H:%M:%S")}) if update
     payload.merge!({:CUSTOMFIELDS=>[{
       :CUSTOM_FIELD_ID=> "ORGANISATION_FIELD_1",
       :FIELD_VALUE=> Time.zone.now.strftime("%Y-%m-%d")}
     ]}) if order
     payload

  end

end
