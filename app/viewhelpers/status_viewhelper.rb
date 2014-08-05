class StatusViewhelper

  TABS = [
    ['Processing Ontologies', :ontologies, ->{ processing_ontologies_count }],
  ]

  HELPERS = {
    ontologies: StatusOntologyViewhelper,
  }

  attr_reader :tab, :view, :available_tabs

  def self.processing_ontologies_count
    StatusOntologyViewhelper.new.processing_ontologies_count
  end

  def initialize(view, tab)
    @view = view
    @tab = tab
    initialize_data
  end

  def initialize_data
    @available_tabs = TABS.map do |(tab_title, tab, count)|
      [tab_title, tab, count ? count.call : nil]
    end
  end

  def inner_helper
    @inner_helper ||= initialize_helper(HELPERS[tab])
  end

  def initialize_helper(helper_klass)
    helper_klass.new
  end

  def current?(other_tab)
    tab == other_tab
  end

  def render
    view.render partial: tab.to_s, locals: {view: inner_helper} if tab
  end


end
