module Key::Fingerprint
  extend ActiveSupport::Concern

  included do
    before_validation :generate_fingerpint
    validates :fingerprint, uniqueness: true
  end


  def generate_fingerpint
    self.fingerprint = nil
    return unless key?

    output = ''
    Tempfile.open('ssh_key_file') do |file|
      file.puts key
      file.rewind
      output = Subprocess.run 'ssh-keygen', '-lf', file.path
    end
    output.gsub /([\d\h]{2}:)+[\d\h]{2}/ do |match|
      self.fingerprint = match.gsub(":","")
    end
  rescue Subprocess::Error => e
    errors[:key] << e.output.split("\n").last.split(" ",2).last
  end

end
