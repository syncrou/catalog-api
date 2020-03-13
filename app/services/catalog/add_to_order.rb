module Catalog
  class AddToOrder
    attr_reader :order_item

    def initialize(params)
      @params = params
    end

    def process
      order = Order.find_by!(:id => @params[:order_id])
      @order_item = order.order_items.create!(order_item_params.merge!(:service_plan_ref => service_plan_ref))
      @order_item.update_message("info", "Order item tracking ID (x-rh-insights-request-id): #{@order_item.insights_request_id}")
      @pre_provision_item = PreProvisionOrderTemplate.create!(order_item_params.merge!(:service_plan_ref => service_plan_ref))
      @pre_provision_item.update_message("info", "Pre Provision tracking ID (x-rh-insights-request-id): #{@pre_provision_item.insights_request_id}")
      @post_provision_item = PostProvisionOrderTemplate.create!(order_item_params.merge!(:service_plan_ref => service_plan_ref))
      @post_provision_item.update_message("info", "Post Provision tracking ID (x-rh-insights-request-id): #{@post_provision_item.insights_request_id}")

      self
    end

    private

    def order_item_params
      @params.permit(:order_id, :portfolio_item_id, :count, :service_parameters => {}, :provider_control_parameters => {})
    end

    def service_plan_ref
      plans = Catalog::ServicePlans.new(@params[:portfolio_item_id]).process.items
      plans.first["id"]
    end
  end
end
