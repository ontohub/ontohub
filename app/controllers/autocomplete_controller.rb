class AutocompleteController < ActionController::Base
  
  MIN_LENGTH = 3
  
  def index
    query = params[:query].to_s.strip
    
    if query.length < MIN_LENGTH
      @result = []
    else
      autocomplete = Autocomplete.new(params[:scope], query)
      @result = autocomplete.result
    end
  rescue Autocomplete::InvalidScope => error
    render :text => error.message, :status => :unprocessable_entity
  end
   
end
