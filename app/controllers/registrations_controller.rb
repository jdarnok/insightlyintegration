class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  # POST /resource
   def create
     build_resource(sign_up_params)

     resource.save
     yield resource if block_given?
     if resource.persisted?
       if resource.active_for_authentication?
         set_flash_message :notice, :signed_up if is_flashing_format?
         sign_up(resource_name, resource)
         respond_with resource, location: after_sign_up_path_for(resource)
       else
         set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
         expire_data_after_sign_in!
         respond_with resource, location: after_inactive_sign_up_path_for(resource)
       end
     else
       clean_up_passwords resource
       set_minimum_password_length
       respond_with resource
     end
   end

   def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      # user or order, other class will break devise
      self.resource.insightly_update
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end


  private

 def sign_up_params
   params.require(:user).permit(:first_name, :last_name, :email, :password,
   :password_confirmation, :phone, :country, :address, :city, :state, :postcode)
 end

 def account_update_params
   params.require(:user).permit(:first_name, :last_name, :email, :password,
   :password_confirmation, :current_password, :phone, :country, :address,
   :city, :state, :postcode)
 end

end
