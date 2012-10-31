require "fnordmetric"

FnordMetric.namespace :foreman do
  #hide_overview
  hide_active_users

  timeseries_gauge :number_of_reports,
    :group => "Reports",
    :title => "Number of Reports",
    :key_nouns => ["Report", "Reports"],
    :series => [:created, :destroyed],
    :resolution => 2.minutes

  timeseries_gauge :report_events,
    :group => "Reports",
    :title => "Reports Event distribution",
    :key_nouns => ["Event", "Events"],
    :series => [:applied, :restarted, :failed, :failed_restart, :skipped, :pending],
    :resolution => 2.minutes

  toplist_gauge :popular_hosts, title: "Popular Hosts"
  toplist_gauge :popular_controllers, title: "Popular Controllers"
  toplist_gauge :popular_paths, title: "Popular Paths"
  toplist_gauge :statuses, title: "Status Codes"
  
  gauge :events_per_hour, :tick => 1.hour
  gauge :events_per_second, :tick => 1.second
  gauge :events_per_minute, :tick => 1.minute

  event :"*" do
    incr :events_per_hour
    incr :events_per_minute
    incr :events_per_second
  end

  widget 'TechStats', {
    :title => "Events per Minute",
    :type => :timeline,
    :width => 100,
    :gauges => :events_per_minute,
    :include_current => true,
    :autoupdate => 30
  }

  widget 'TechStats', {
    :title => "Events per Hour",
    :type => :timeline,
    :width => 50,
    :gauges => :events_per_hour,
    :include_current => true,
    :autoupdate => 30
  }


  widget 'TechStats', {
    :title => "Events/Second",
    :type => :timeline,
    :width => 50,
    :gauges => :events_per_second,
    :include_current => true,
    :plot_style => :areaspline,
    :autoupdate => 1
  }

  widget 'TechStats', {
    :title => "Events Numbers",
    :type => :numbers,
    :width => 100,
    :gauges => [:events_per_second, :events_per_minute, :events_per_hour],
    :offsets => [1,3,5,10],
    :autoupdate => 1
  }

  gauge :reports_per_hour, :tick => 1.hour
  gauge :reports_per_second, :tick => 1.second
  gauge :reports_per_minute, :tick => 1.minute

  widget 'Reports', {
    :title => "Reports per Minute",
    :type => :timeline,
    :width => 100,
    :gauges => :reports_per_minute,
    :include_current => true,
    :autoupdate => 30
  }

  widget 'Reports', {
    :title => "Reports per Hour",
    :type => :timeline,
    :width => 50,
    :gauges => :reports_per_hour,
    :include_current => true,
    :autoupdate => 30
  }


  widget 'Reports', {
    :title => "Reports/Second",
    :type => :timeline,
    :width => 50,
    :gauges => :reports_per_second,
    :include_current => true,
    :plot_style => :areaspline,
    :autoupdate => 1
  }

  widget 'Reports', {
    :title => "Reports Numbers",
    :type => :numbers,
    :width => 100,
    :gauges => [:reports_per_second, :reports_per_minute, :reports_per_hour],
    :offsets => [1,3,5,10],
    :autoupdate => 1
  }

  event :report_event do
    incr :reports_per_hour
    incr :reports_per_minute
    incr :reports_per_second

    if data[:action] == "create"
      incr :number_of_reports, :created, 1
      incr :report_events, :skipped, data[:skipped] if data[:skipped] > 0
      incr :report_events, :failed_restarts, data[:failed_restarts] if data[:failed_restarts] > 0
      incr :report_events, :pending, data[:pending] if data[:pending] > 0
      incr :report_events, :failed, data[:failed] if data[:failed] > 0
      incr :report_events, :restarted, data[:restarted] if data[:restarted] > 0
      incr :report_events, :applied, data[:applied] if data[:applied] > 0
    elsif data[:action] == "destroy"
      incr :number_of_reports, :destroyed, 1
    end
  end


  event :view_host do
    observe :popular_hosts, data[:name]
  end

  event :process_action do
    observe :popular_controllers, data[:controller]
    observe :popular_paths, data[:path]
    observe :statuses, data[:status]
  end

end

FnordMetric::Web.new(port: 4242)
FnordMetric::Worker.new
FnordMetric.run


