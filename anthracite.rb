require 'puppet'
require 'net/http'
Puppet::Reports.register_report(:anthracite) do
  def process
    configfile = File.join([File.dirname(Puppet.settings[:config]), "anthracite.yaml"])
    raise(Puppet::ParseError, "Anthracite report config file #{configfile} not readable") unless File.exist?(configfile)
    config = YAML.load_file(configfile)

    anthracite_host = config[:anthracite_host] || "localhost"
    anthracite_port = config[:anthracite_port] || "8081"
    anthracite_open_timeout = config[:anthracite_open_timeout] || 5
    anthracite_read_timeout = config[:anthracite_read_timeout] || 5


    uri = URI.parse("http://#{anthracite_host}:#{anthracite_port}/events/add/script")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = anthracite_open_timeout
    http.read_timeout = anthracite_read_timeout
    if self.status == 'changed'
      r = self.resource_statuses
      changed = Array.new
      r.each { |name, status|
        if status.change_count > 0
          changed << name
        end
      }
      str = changed.join(', ')
      req = Net::HTTP::Post.new(uri.request_uri)
      now = Time.now.to_i
      req.set_form_data({ "event_timestamp" => "#{now}", "event_tags" => "puppet", "event_desc" => "#{str}" })

      begin
        response = http.request(req)
      rescue Exception => e
        Puppet.err "Couldn't send report to anthracite, #{e}"
      end
    end
  end
end

