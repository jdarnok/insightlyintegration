class Organisation < ActiveRecord::Base
  belongs_to :user

  after_create :insightly_create
  def insightly_create
    contact = Insightly2.client.create_organisation(organisation: insightly_payload)
    update_attributes(organisation_id: contact.organisation_id)
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

  private

  # it gets data from the database
  # https://api.insight.ly/v2.1/Help/Api/POST-Organisations
  def insightly_payload(update = false, order = false)
    payload = {
      organisation_name: name,
      VISIBLE_TO: 'EVERYONE',
      VISIBLE_TEAM_ID: nil,
      VISIBLE_USER_IDS: nil,
      ADDRESSES: [{
        ADDRESS_TYPE: 'Work',
        STREET: address,
        CITY: city,
        STATE: state,
        POSTCODE: postcode,
        COUNTRY: country }],
      CONTACTINFOS:      [{
        type: 'Email',
        subtype: '',
        label: 'Work',
        detail: email },
                          { type: 'Phone',
                            subtype: '',
                            label: 'Work',
                            detail: phone }]
    }
    #  if organisation is updated, it needs to prive organisation_id
    payload.merge!(organisation_id: organisation_id) if update
    payload.merge!(date_created_utc: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')) unless update
    payload.merge!(date_updated_utc: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')) if update
    payload.merge!(CUSTOMFIELDS: [{
                     CUSTOM_FIELD_ID: 'ORGANISATION_FIELD_1',
                     FIELD_VALUE: Time.zone.now.strftime('%Y-%m-%d') }
                                 ]) if order
    payload
  end
end
