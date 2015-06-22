class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :insightly_create
  has_one :organisation
  def insightly_create
      contact = Insightly2.client.create_contact(contact: insightly_payload)
      self.update_attributes(contact_id: contact.contact_id)
  end
  def insightly_update
      Insightly2.client.update_contact(contact: insightly_payload(true))
  end

       private
  #https://api.insight.ly/v2.1/Help/Api/POST-Contacts
  def insightly_payload(update = false)
  payload = {
  :first_name=>self.first_name,
  :last_name=>self.last_name,
  :image_url=>"https://fakedomain.imgix.net/user_photos/man.jpg?crop=faces&fit=crop&h=96&w=96",
  :contactinfos=>[{
    :type=>"Email",
    :subtype=>"",
    :label=>"Work",
    :detail=> self.email},
    { :type=>"Phone",
      :subtype=>"",
      :label=>"Work",
      :detail=> self.phone}],
  :ADDRESSES=>[{
    :ADDRESS_TYPE=>"Work",
    :STREET=> self.address,
    :CITY=> self.city,
    :STATE=> self.state,
    :POSTCODE=> self.postcode,
    :COUNTRY=> self.country}],
  :links=>[],
  :tags=>[],
  :date_created_utc=> Time.zone.now.strftime("%Y-%m-%d %H:%M:%S"),
  :date_updated_utc=>"2014-10-23 17:27:25"
  # "contact_id"=>81126408
  }
  payload.merge!({:contact_id=> self.contact_id}) if update
  payload.merge!({:date_created_utc=> Time.zone.now.strftime("%Y-%m-%d %H:%M:%S")}) unless update
  payload.merge!({:date_updated_utc=>Time.zone.now.strftime("%Y-%m-%d %H:%M:%S")}) if update
  payload
  end

end
