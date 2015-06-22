
[1mFrom:[0m /home/kjanczyk/Documents/Railsy/insightly2API/app/controllers/registrations_controller.rb @ line 36 RegistrationsController#update:

    [1;34m29[0m:  [32mdef[0m [1;34mupdate[0m
    [1;34m30[0m:   [1;36mself[0m.resource = resource_class.to_adapter.get!(send([33m:[1;33m"[0m[33mcurrent_#{resource_name}[0m[33m[1;33m"[0m[33m[0m).to_key)
    [1;34m31[0m:   prev_unconfirmed_email = resource.unconfirmed_email [32mif[0m resource.respond_to?([33m:unconfirmed_email[0m)
    [1;34m32[0m: 
    [1;34m33[0m:   resource_updated = update_resource(resource, account_update_params)
    [1;34m34[0m:   [32myield[0m resource [32mif[0m block_given?
    [1;34m35[0m:   [32mif[0m resource_updated
 => [1;34m36[0m:     binding.pry
    [1;34m37[0m:     [32mif[0m is_flashing_format?
    [1;34m38[0m:       flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
    [1;34m39[0m:         [33m:update_needs_confirmation[0m : [33m:updated[0m
    [1;34m40[0m:       set_flash_message [33m:notice[0m, flash_key
    [1;34m41[0m:     [32mend[0m
    [1;34m42[0m:     sign_in resource_name, resource, [35mbypass[0m: [1;36mtrue[0m
    [1;34m43[0m:     respond_with resource, [35mlocation[0m: after_update_path_for(resource)
    [1;34m44[0m:   [32melse[0m
    [1;34m45[0m:     clean_up_passwords resource
    [1;34m46[0m:     respond_with resource
    [1;34m47[0m:   [32mend[0m
    [1;34m48[0m: [32mend[0m

