json.array!(@accounts) do |account|
  json.extract! account, :id, :phone, :email, :website, :address, :address2, :city, :state, :postcode, :country
  json.url account_url(account, format: :json)
end
