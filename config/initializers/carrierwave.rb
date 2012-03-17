# encoding: utf-8

require 'open-uri'

# HACK HACK HACK
# monkey patching carrier-wave to add an additional header
class CarrierWave::Uploader::Download::RemoteFile
  
  private
  
  def file
    if @file.blank?
      @file = Kernel.open(@uri.to_s, 'Accept' => 'application/rdf+xml,*/*;q=0.9')
      @file = @file.is_a?(String) ? StringIO.new(@file) : @file
    end
    @file
  end
  
end