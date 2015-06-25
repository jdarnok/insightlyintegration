require 'insightly2/dsl'
require 'active_record'

module Insightly2
  module DSL::Wrapper


    def create_account(account)

      insightly_create_contact(contact: build_contact(contact: account))
      insightly_create_organisation(organisation: build_organisation(account))
    end


    def build_contact(contact)
      builder = OpenStruct.new
      builder.first_name = contact[:contact].name.split(" ").first
      builder.last_name = contact[:contact].name.split(" ").last
      builder.phone = contact[:contact].phone
      builder.email = contact[:contact].email
      builder.contact_id
      builder
    end
    def build_organisation(organisation)
      builder = OpenStruct.new
      builder.name = organisation.organisation
      builder.phone = organisation.phone
      builder.email = organisation.email
      builder.website = organisation.website
      builder.address = organisation.address.to_s + ' ' +
      organisation.address2.to_s
      builder.city = organisation.city
      builder.state = organisation.state
      builder.postcode = organisation.postcode
      builder.country = organisation.country
      builder.domain
      builder
    end



    def insightly_update_contact(contact: nil)
      fail ArgumentError, 'Contact cannot be blank' if contact.blank?
      insightly_contact = Insightly2.client.get_contacts(email: contact.email)
      contact.contact_id = insightly_contact[0]["CONTACT_ID"]
      begin
        Insightly2.client.update_contact(contact: insightly_contact_payload(contact, update: true))
      rescue Insightly2::Errors::ClientError => e
        insightly_create_contact(contact: contact)
      end
    end


    # POST /v2.1/Contacts
    # Creates a contact and adds contact_id to the User model.
    # @param [Hash] contact The contact to create.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [[Insightly2::Resources::Contact, false].
    def insightly_create_contact(contact: nil)
      fail ArgumentError, 'Contact cannot be blank' if contact.blank?
      # contact.first_name = contact.name,split(" ").last
      # contact.last_name = contact.
      Insightly2.client.create_contact(contact: insightly_contact_payload(contact))
    end


    def insightly_create_organisation(organisation: nil)
      fail ArgumentError, 'Organisation cannot be blank' if organisation.blank?

      organisation.domain = organisation.email.split("@").last
      Insightly2.client.create_organisation(organisation: insightly_organisation_payload(organisation))
    end

    def insightly_update_organisation(organisation: nil)
      fail ArgumentError, 'Organisation cannot be blank' if organisation.blank?
      organisation.domain = organisation.email.split("@").last
      insightly_organisation = Insightly2.client.get_organisations(domain: organisation.domain)
      insightly_organisation = insightly_organisation.select {|item| item["ORGANISATION_NAME"] == organisation.name }
      organisation.organisation_id = insightly_organisation[0]["ORGANISATION_ID"]
        binding.pry
        Insightly2.client.update_organisation(organisation: insightly_organisation_payload(organisation, update: true))
    end




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
       payload.merge!({:CUSTOMFIELDS=>[{
         :CUSTOM_FIELD_ID=> "ORGANISATION_FIELD_1",
         :FIELD_VALUE=> Time.zone.now.strftime("%Y-%m-%d")}
       ]}) if order
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
          detail: contact.email },
        { type: 'Phone',
          subtype: '',
          label: 'Work',
          detail: contact.phone }],
      }
      payload.merge!(contact_id: contact.contact_id) if update
      payload.merge!(date_created_utc: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')) unless update
      payload.merge!(date_updated_utc: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')) if update
      payload
    end
  end
end

# contact.select {|organisation| organisation["ORGANISATION_NAME"] == "druga" }
