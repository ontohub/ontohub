module Key::Fingerprint
  extend ActiveSupport::Concern

  included do
    before_validation :generate_fingerpint
    validates :fingerprint, uniqueness: true, presence: true
  end


  def generate_fingerpint
    self.fingerprint = nil
    return unless key?

    output = ''
    Tempfile.open('ssh_key_file') do |file|
      file.puts key
      file.rewind
      output = Subprocess.run 'ssh-keygen', '-lf', file.path
      # Openssh 6.8 changed the format and hash algorithm of the fingerprint.
      # Now the hash algorithm name is prepended to the fingerprint and the
      # default algorithm is SHA256 (we need MD5).
      if output[0..16].include?('SHA256:')
        # If the parameter -E is used with an older version than 6.8, the
        # process fails. So we only use it if the know that it is supported.
        output = Subprocess.run 'ssh-keygen', '-l', '-E', 'md5', '-f', file.path
        output.sub!('MD5:', '')
      end
    end
    output.gsub /([\d\h]{2}:)+[\d\h]{2}/ do |match|
      self.fingerprint = match.gsub(":","")
    end
  rescue Subprocess::Error => e
    errors[:key] << e.output.split("\n").last.split(" ",2).last.strip
  end

end
