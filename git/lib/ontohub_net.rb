require 'net/http'
require 'openssl'
require 'json'
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

    !!(resp.code == '200' && resp_hash['allowed'])
  end

  protected

  def host
    Settings.git.verify_url
  end

  def get(url)
    Rails.logger.debug "Performing GET #{url}"

    url  = URI.parse(url)

    resp = fetch_uri_content(url)
    Rails.logger.debug { "Received response #{resp.code} => <#{resp.body}>." }
  rescue ArgumentError
    Rails.logger.error { "API call <GET #{url}> failed: #{resp.code} => <#{resp.body}>." }
  end

  private

  def build_url
    access_url = "#{host}/repositories/#{repo_path}/ssh_access"
    options = "?key_id=#{key_id}&permission=#{access_right}"
    "#{access_url}#{options}"
  end
end
