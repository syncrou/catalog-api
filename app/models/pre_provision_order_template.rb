class PreProvisionOrderTemplate < OrderItem
  before_create :set_defaults
  before_save :sanitize_parameters, :if => :will_save_change_to_service_parameters?

  private

  def set_defaults
    puts "in preprovision set defaults"
  end

  def sanitize_parameters
    puts "in preprovision set sanitize_parameters"
  end
end
