class UserOrganizationMembershipsController < ApplicationController
  #before_action :authenticate, only: [:create_by_email, :destroy]
  before_action :set_membership, only: [:destroy]
  before_action :set_entities, only: [:create_by_email]
  before_action :check_authorization, only: [:create_by_email, :destroy]

  def user_memberships
    # We use a UserOrganizationMemberships scope here to avoid unnecessary DB indirection through the user.
    @memberships = UserOrganizationMembership.for_user(params[:user_id])
    render json: UserMembershipsRepresenter.new(@memberships).to_json
  end

  def organization_memberships
    # We use a UserOrganizationMemberships scope here to avoid unnecessary DB indirection through the organization.
    @memberships = UserOrganizationMembership.for_organization(params[:organization_id])
    render json: OrganizationMembershipsRepresenter.new(@memberships).to_json
  end

  def generate_random_password
    "password ... but random1"
  end

  def generate_verification_ticket

  end

  def invite_user email
    auth0 = Auth0Client.new(
      :api_version => 2,
      :token => Rails.application.secrets.auth0_api_token,
      :domain => Rails.application.secrets.auth0_api_domain
    )
    password = generate_random_password
    new_auth0_user = auth0.create_user(
      email,
      connection: Rails.application.secrets.auth0_authentication_connection,
      email: email,
      password: password
    )

    @user = User.create name: new_auth0_user["name"], username: email, email: email, auth0_id: new_auth0_user["user_id"], picture: new_auth0_user["picture"]

    #url = generate_verification_ticket new_auth0_user

    url = "https://www.getguesstimate.com"

    UserOrganizationMembershipMailer.send_invite_email(@user, @organization, url, password).deliver_later
  end

  def create_by_email
    if @user.nil?
      invite_user params[:email]
    end

    @membership = UserOrganizationMembership.new user: @user, organization: @organization
    if @membership.save
      render json: OrganizationMembershipRepresenter.new(@membership).to_json
    else
      render json: @membership.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @membership.destroy
    head :no_content
  end

  private

  def set_membership
    @membership = UserOrganizationMembership.find(params[:id])
    @organization = @membership.organization
  end

  def set_entities
    @organization = Organization.find(params[:organization_id])
    @user = User.find_by_email(params[:email])
  end

  def check_authorization
    #head :unauthorized unless current_user.id == @organization.admin_id
  end
end
