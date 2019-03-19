module RBAC
  module ACLS
    def new_acls(resource_id, permissions)
      permissions.collect do |permission|
        add_acl(permission, resource_id)
      end
    end

    def remove_acls(acls, resource_id, permissions)
      permissions.each do |permission|
        acls = delete_matching_acls(acls, resource_id, permission)
      end
      acls
    end

    def updated_acls(acls, resource_id, permissions)
      existing_acls = []
      new_acls = []
      permissions.each do |permission|
        acl = find_matching_acl(acls, resource_id, permission)
        if acl
          existing_acls << acl
        else
          new_acls << add_acl(permission, resource_id)
        end
      end
      new_acls.empty? ? new_acls : new_acls + existing_acls
    end

    def add_acl(permission, resource_id)
      resource_def = resource_definition(resource_id)
      RBACApiClient::Access.new.tap do |access|
        access.permission = permission
        access.resource_definitions = [resource_def]
      end
    end

    def resource_definition(resource_id)
      rdf = RBACApiClient::ResourceDefinitionFilter.new.tap do |obj|
        obj.key       = 'id'
        obj.operation = 'equal'
        obj.value     = resource_id.to_s
      end

      RBACApiClient::ResourceDefinition.new.tap do |rd|
        rd.attribute_filter = rdf
      end
    end

    def matches?(access, resource_id, permission)
      access.permission == permission &&
        access.resource_definitions.any? { |rdf| rdf.attribute_filter.value == resource_id }
    end

    def find_matching_acl(acls, resource_id, permission)
      acls.detect { |access| matches?(access, resource_id, permission) }
    end

    def delete_matching_acls(acls, resource_id, permission)
      acls.delete_if { |access| matches?(access, resource_id, permission) }
    end
  end
end
