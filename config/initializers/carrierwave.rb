# encoding: utf-8

require 'open-uri'

# HACK HACK HACK
class CarrierWave::Uploader::Download::RemoteFile
  
  def original_filename
    name  = File.basename(file.base_uri.path)
    # add .owl if file extension is missing or unknown
    name += ".owl" unless name =~ /(owl|clf|clif|xml)$/
    name
  end
  
  private
  
  def file
    # monkey patching carrier-wave to add an additional header
    if @file.blank?
      @file = Kernel.open(@uri.to_s, 'Accept' => 'application/rdf+xml,*/*;q=0.9')
      @file = @file.is_a?(String) ? StringIO.new(@file) : @file
    end
    @file
  end
  
end