module Sessions
  class OrganizationsController < ApplicationController
    before_action :hide_admin_navigation

    def new
      @organizations = current_user.managed_organizations_within_market(current_market)
    end

    def create
      if org = current_user.managed_organizations.find_by(id: params[:org_id])
        session[:current_organization_id] = org.id
        redirect_to params[:redirect_back_to] || [:products]
      else
        flash[:alert] = "Please select an organization"
        self.new
        render :new
      end
    end
  end
end
