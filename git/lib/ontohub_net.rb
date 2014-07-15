require 'net/http'
require 'openssl'
require 'json'
require File.expand_path('../../../lib/uri_fetcher/errors', File.realdirpath(__FILE__))
require File.expand_path('../../../lib/uri_fetcher', File.realdirpath(__FILE__))

class OntohubNet
  include UriFetcher

  GIT_CMD_MAP = {
    'git-upload-pack' => 'read',
    'git-upload-archive' => 'read',
    'git-receive-pack' => 'write',
  }

  attr_reader :cmd, :access_right, :repo_path, :key_id, :ref

  def allowed?(cmd, repo_path, key, ref)
    @cmd = cmd
    @access_right = GIT_CMD_MAP[cmd]
    raise ArgumentError, "unknown cmd: #{cmd}" if access_right.nil?

    repo_path  = repo_path.gsub("'", "")
    repo_path  = repo_path.gsub(/\.git\Z/, "")
    @repo_path = repo_path.gsub(/\A\//, "")

    @key_id = key
    @ref = ref

    resp = get(build_url)
    resp_hash = JSON.parse(resp.body)

    raise UnexpectedStatusCodeError.new(response: resp) unless resp.code == '200'

    !!(resp.code == '200' && resp_hash['allowed'])
  end

  protected

  def host
    Settings.git.verify_url
  end

  def get(url)
    Rails.logger.debug "Performing GET #{url}"

    url  = URI.parse(url)

    response = fetch_uri_content(url, limit: NO_REDIRECT)

    Rails.logger.debug do
      <<-MSG
Received response #{response.code} => <#{response.body}>.
      MSG
    end
    response
  rescue UriFetcher::TooManyRedirectionsError => error
    response = error.last_response
    Rails.logger.error do
      <<-ERROR
API call <GET #{url}> failed:
  #{response.code} => <#{response.body}>.
We also encountered this error:
  <##{error.class}> <#{error.message}>
With this stacktrace:
  #{error.backtrace.join('\n')}
      ERROR
    end
    raise
  end

  private

  def build_url
    access_url = "#{host}/repositories/#{repo_path}/ssh_access"
    options = "?key_id=#{key_id}&permission=#{access_right}"
    "#{access_url}#{options}"
  end
end
