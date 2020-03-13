class Order < ApplicationRecord
  include OwnerField
  include Discard::Model
  include Catalog::DiscardRestore
  destroy_dependencies :order_items
  acts_as_tenant(:tenant)

  default_scope { kept.order(:created_at => :desc) }

  has_many :order_items, :dependent => :destroy
  has_one :pre_provision_order_template
  has_one :post_provision_order_template

  before_create :set_defaults

  def set_defaults
    self.state = "Created"
  end
end
