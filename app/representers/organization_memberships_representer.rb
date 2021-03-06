require 'roar/decorator'

class OrganizationMembershipsRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  collection :to_a, as: 'items', class: UserOrganizationMembership, decorator: OrganizationMembershipRepresenter
end
