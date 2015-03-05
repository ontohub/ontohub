# Adjust setting below to your local environment and than start puma like this:
# puma -C config/puma.rb --control=unix:///tmp/puma.ctrl --control-token=
# and manage it like this:
# pumactl --control-url=unix:///tmp/puma.ctrl {restart|stop|status|stats|halt}
# For more information see http://www.rubydoc.info/gems/puma/

environment 'production'
# For non-thread-capable ruby impl. like MRI modifying this is usually just
# a waste of resources. However, for Rubinius or JRuby it probably makes a
# difference - in this case don't forget to adjust the workers accordingly.
threads 1, 1
# Perhaps starting with 75% of available strands is ok - monitor and adjust.
workers 24
# For convinience make it the same as for 'rails server', i.e. listen on all
# available interfaces on port 3000
bind 'tcp://0.0.0.0:3000'
# We don't like noise
quiet
# IMPORTANT wrt. MRI ruby - saves rsources!
preload_app!

# let's make sure, that ppl with the same GID as the running puma process
# are really able to control puma (the group needs write access). See option
# --control and --control-url above.
on_worker_boot do
  if @options[:control_url]
    uri = URI.parse(@options[:control_url])
    FileUtils.chmod(0770, uri.path) if uri.scheme == 'unix'
  end
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
