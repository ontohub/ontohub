require 'net/http'
require 'openssl'
require 'json'

class OntohubNet

  GIT_CMD_MAP = {
    'git-upload-pack' => 'read',
    'git-upload-archive' => 'read',
    'git-receive-pack' => 'write',
  }

  attr_reader :cmd, :access_right, :repo, :project_name, :key_id, :ref

  def allowed?(cmd, repo, key, ref)
    @cmd = cmd
    @access_right = GIT_CMD_MAP[cmd]
    raise ArgumentError, "unknown cmd: #{cmd}" if access_right.nil?

    @repo = repo
    project_name = repo.gsub("'", "")
    project_name = project_name.gsub(/\.git\Z/, "")
    @project_name = project_name.gsub(/\A\//, "")

    @key_id = key
    @ref = ref

    resp = get(build_url)
    resp_hash = JSON.parse(resp.body)

    !!(resp.code == '200' && resp_hash['allowed'])
  end

  protected

  def config
    @config ||= OntohubConfig.instance
  end

  def host
    config.ontohub_url
  end

  def get(url)
    $logger.debug "Performing GET #{url}"

    url = URI.parse(url)
    http = Net::HTTP.new(url.host, url.port)

    if URI::HTTPS === url
      http.use_ssl = true
      http.cert_store = cert_store

      if config.http_settings['self_signed_cert']
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    request = Net::HTTP::Get.new(url.request_uri)

    response = nil

    http.start {|http| http.request(request) }.tap do |resp|
      response = resp
      if resp.code == "200"
        $logger.debug { "Received response #{resp.code} => <#{resp.body}>." }
      else
        $logger.error { "API call <GET #{url}> failed: #{resp.code} => <#{resp.body}>." }
      end
    end
    response
  end

  def cert_store
    @cert_store ||= OpenSSL::X509::Store.new.tap { |store|
      store.set_default_paths

      if ca_file = config.http_settings['ca_file']
        store.add_file(ca_file)
      end

      if ca_path = config.http_settings['ca_path']
        store.add_path(ca_path)
      end
    }
  end

  private
  def build_url
    access_url = "#{host}/repositories/#{project_name}/ssh_access"
    options = "?key_id=#{key_id}&permission=#{access_right}"
    "#{access_url}#{options}"
  end
end
