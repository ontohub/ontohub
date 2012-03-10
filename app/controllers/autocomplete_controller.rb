class AutocompleteController < ActionController::Base
  
  MIN_LENGTH = 3
  
  def index
    term = params[:term].to_s.strip
    
    if term.length < MIN_LENGTH
      @result = []
    else
      autocomplete = Autocomplete.new(params[:scope], term)
      @result = autocomplete.result.map{|r| {
        id:    r.id,
        type:  r.class.to_s,
        value: r.to_s
      }}
    end
    render :json => @result
  rescue Autocomplete::InvalidScope => error
    render :text => error.message, :status => :unprocessable_entity
  end
   
end
