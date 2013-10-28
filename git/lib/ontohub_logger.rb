require 'logger'

Rails.logger = Logger.new Rails.root.join('log','git.log')
