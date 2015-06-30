require 'insightly2/dsl'
require 'active_record'

module Insightly2
  module DSL::Wrapper


#this 2 methods break account model into smaller pieces for rest of the code
#builder needs to be fetched with proper data. When there are differences in
#account like 'mail' instead of 'email' just change the proper attribute in
# account.object
#@param [Account] Account model object
    def build_contact(account)
      builder = OpenStruct.new
      builder.first_name = account.name.split(" ").first
      builder.last_name = account.name.split(" ").last
      builder.phone = account.phone
      builder.email = account.email
      builder.id = account.id unless account.id.blank?
      builder.contact_id = account.insightly_contact_id unless account.insightly_contact_id.blank?
      builder
    end
    def build_organisation(account)
      builder = OpenStruct.new
      builder.name = account.organisation
      builder.phone = account.phone
      builder.email = account.email
      builder.website = account.website
      builder.address = account.address.to_s + ' ' +
      account.address2.to_s
      builder.city = account.city
      builder.state = account.state
      builder.postcode = account.postcode
      builder.country = account.country
      builder.domain = account.email.split("@").last
      builder.brick_mortar = account.brick_mortar #boolean
      builder.online = account.online #boolean
      builder.organisation_id = account.insightly_organisation_id unless account.insightly_organisation_id.blank?
      builder.id = account.id
      builder
    end


    #Creates and updates Account object
    #@param [Account] Account model object
    def create_account(account)
      contact = insightly_create_contact(account)
      account.update_attributes(insightly_contact_id: contact.contact_id)
      organisation = insightly_create_organisation(account)
      account.update_attributes(insightly_organisation_id: organisation.organisation_id)
    end

    #@param [Account] Account model object
    def update_account(account)
      insightly_update_contact(account)
      insightly_update_organisation(account)
    end

    #@param [Account] Account model object
    def make_order(organisation)
      fail ArgumentError, 'Organisation cannot be blank' if organisation.blank?
      builded_organisation = build_organisation(organisation)

        builded_organisation.domain = organisation.email.split("@").last
        Insightly2.client.update_organisation(organisation: insightly_organisation_payload(builded_organisation, true, true))
    end

    #@param [Account] Account model object
    def insightly_update_contact(contact)
      fail ArgumentError, 'Contact cannot be blank' if contact.blank?

      builded_contact = build_contact(contact)
      begin
        Insightly2.client.update_contact(contact: insightly_contact_payload(builded_contact, update: true))
      rescue Insightly2::Errors::ClientError => e
        insightly_contact = insightly_create_contact(contact)
        contact.update_attributes(insightly_contact_id: insightly_contact.contact_id)
      end
      # begin
      # rescue Insightly2::Errors::ClientError => e
        # insightly_create_contact(contact: contact)
      # end
    end


    # POST /v2.1/Contacts
    # Creates a contact and adds contact_id to the User model.
    # @param [Hash] contact The contact to create.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [[Insightly2::Resources::Contact, false].
    def insightly_create_contact(contact)
      fail ArgumentError, 'Contact cannot be blank' if contact.blank?
      contact = build_contact(contact)

      # contact.first_name = contact.name,split(" ").last
      # contact.last_name = contact.
      Insightly2.client.create_contact(contact: insightly_contact_payload(contact))
    end


    def insightly_create_organisation(organisation)
      fail ArgumentError, 'Organisation cannot be blank' if organisation.blank?
      organisation = build_organisation(organisation)
      organisation.domain = organisation.email.split("@").last
      Insightly2.client.create_organisation(organisation: insightly_organisation_payload(organisation))
    end

    def insightly_update_organisation(organisation)
      fail ArgumentError, 'Organisation cannot be blank' if organisation.blank?
      builded_organisation = build_organisation(organisation)
      begin
        Insightly2.client.update_organisation(organisation: insightly_organisation_payload(builded_organisation, update: true))
      rescue Insightly2::Errors::ResourceNotFoundError => e
        insightly_organisation = insightly_create_organisation(organisation: organisation)
        organisation.update_attributes(insightly_organisation_id: insightly_organisation.organisation_id)
      end
    end



#proper hash for Insightly2 gem

    def insightly_organisation_payload(organisation, update = false, order = false)
      payload = {
       :organisation_name=> organisation.name,
       :VISIBLE_TO=>"EVERYONE",
       :VISIBLE_TEAM_ID=>nil,
       :VISIBLE_USER_IDS=>nil,
       :ADDRESSES=>[{
         :ADDRESS_TYPE=>"Work",
         :STREET=> organisation.address,
         :CITY=> organisation.city,
         :STATE=> organisation.state,
         :POSTCODE=> organisation.postcode,
         :COUNTRY=> organisation.country}],
       :CONTACTINFOS=>
       [{
         :type=>"Email",
         :subtype=>"",
         :label=>"Work",
         :detail=> organisation.email},
         { :type=>"Phone",
           :subtype=>"",
           :label=>"Work",
           :detail=> organisation.phone},
         { :type=>"EmailDomain",
           :subtype=>"",
           :label=>"Work",
           :detail=> organisation.domain}],
       }
       payload.merge!({:organisation_id=> organisation.organisation_id}) if update
       payload.merge!({:date_created_utc=> Time.zone.now.strftime("%Y-%m-%d %H:%M:%S")}) unless update
       payload.merge!({:date_updated_utc=>Time.zone.now.strftime("%Y-%m-%d %H:%M:%S")}) if update
       payload.merge!({:CUSTOMFIELDS=>[]})
       if order
         hash = {
           :CUSTOM_FIELD_ID=> "ORGANISATION_FIELD_1",
           :FIELD_VALUE=> Time.zone.now.strftime("%Y-%m-%d") }

         payload[:CUSTOMFIELDS] << hash
      end
      hash = {
         :CUSTOM_FIELD_ID=> "ORGANISATION_FIELD_2",
         :FIELD_VALUE=> organisation.id }

      payload[:CUSTOMFIELDS] << hash
      if organisation.brick_mortar
        hash = {
           :CUSTOM_FIELD_ID=> "ORGANISATION_FIELD_3",
           :FIELD_VALUE=> "True" }

         payload[:CUSTOMFIELDS] << hash
      else
        hash = {
           :CUSTOM_FIELD_ID=> "ORGANISATION_FIELD_3",
           :FIELD_VALUE=> "Unchecked" }

         payload[:CUSTOMFIELDS] << hash
      end

      if organisation.online
        hash = {
           :CUSTOM_FIELD_ID=> "ORGANISATION_FIELD_4",
           :FIELD_VALUE=> "True" }

         payload[:CUSTOMFIELDS] << hash
      else
        hash = {
           :CUSTOM_FIELD_ID=> "ORGANISATION_FIELD_4",
           :FIELD_VALUE=> "Unchecked" }

         payload[:CUSTOMFIELDS] << hash
      end


       payload

    end

    def insightly_contact_payload(contact, update = false)
      payload = {
        first_name: contact.first_name,
        last_name: contact.last_name,
        contactinfos: [{
          type: 'Email',
          subtype: '',
          label: 'Work',
          detail: contact.email.to_s },
        { type: 'Phone',
          subtype: '',
          label: 'Work',
          detail: contact.phone.to_s }],
      }
      payload.merge!(contact_id: contact.contact_id) if update
      payload.merge!(date_created_utc: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')) unless update
      payload.merge!(date_updated_utc: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')) if update
      payload.merge!({:CUSTOMFIELDS=>[{
        :CUSTOM_FIELD_ID=> "CONTACT_FIELD_1",
        :FIELD_VALUE=> contact.id }
      ]})
      payload
    end
  end
end

# contact.select {|organisation| organisation["ORGANISATION_NAME"] == "druga" }
