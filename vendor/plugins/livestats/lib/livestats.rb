# Livestats
FNORD_METRIC = FnordMetric::API.new

ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  FNORD_METRIC.event(event.payload.merge(:_type => :process_action))
end

Rails.application.config.to_prepare do

   # trigger via the Controller would miss rake tracking actions from rake 
   # tasks ...
#  ReportsController.class_eval do
#    after_filter :trigger_report_event, :only => [:create, :destroy]
#
#    private
#
#    def trigger_report_event
#      FNORD_METRIC.event(params.merge(:_type => :report_event))
#    end
#  end

  # Track reports creation and destruction
  Report.class_eval do
    after_create do
      FNORD_METRIC.event(self.status.merge(:_type => :report_event, :action => :create))
    end

    after_destroy do
      FNORD_METRIC.event(:_type => :report_event, :action => :destroy)
    end
  end

  # track popular hosts, hosts which are most visited by users:
  HostsController.class_eval do
    after_filter :trigger_view_event, :only => [:show]
    private
    def trigger_view_event
      FNORD_METRIC.event(@host.attributes.merge(:_type => :view_host))
    end
  end
end
