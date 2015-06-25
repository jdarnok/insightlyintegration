class OrganisationsController < ApplicationController
  before_action :set_organisation, only: [:show, :edit, :update, :order]
  before_action :authenticate_user!
  def index
  end

  def update
    respond_to do |format|
      if @organisation.update(organisation_params)
        @organisation.insightly_update
        format.html { redirect_to @organisation, notice: 'organisation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(organisation_params)

    respond_to do |format|
      if @organisation.save
        format.html { redirect_to @organisation, notice: 'Category was successfully created.' }
        format.json { render action: 'show', status: :created, location: @organisation }
      else
        format.html { render action: 'new' }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
  end
    end
  end

  def show
  end

  def order
    @organisation.insightly_update
  end

  def edit
  end


  private


  def set_organisation
  @organisation = Organisation.find(params[:id])
end

  def organisation_params
    params.require(:organisation).permit(:name, :phone, :country, :address,
     :city, :state, :postcode, :user_id, :owner_id, :email, :website)
  end
end
