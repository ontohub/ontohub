class StatusViewhelper

  DEFAULT_TAB = :overview

  TABS = [
    ['Overview', :overview],
    ['Processing Ontologies', :ontologies,
     ->(v){ v.processing_ontologies_count }],
    ['Errored Ontologies', :errored_ontologies,
     ->(v){ v.errored_ontologies_count }],
  ]

  HELPERS = {
    overview: StatusOverviewViewhelper,
    ontologies: StatusOntologyViewhelper,
    errored_ontologies: StatusOntologyErrorViewhelper,
  }

  attr_reader :tab, :view, :available_tabs

  def initialize(view, tab)
    @view = view
    @tab = tab
    initialize_data
  end

  def initialize_data
    @available_tabs = TABS.map do |(tab_title, tab, count)|
      [tab_title, tab, retrieve_count(tab, count)]
    end
  end

  def retrieve_count(tab, count_proc)
    count_proc.call(initialize_helper(HELPERS[tab])) if count_proc
  end

  def inner_helper
    @inner_helper ||= initialize_helper(HELPERS[tab])
  end

  def initialize_helper(helper_klass)
    helper_klass.new(view)
  end

  def current?(other_tab)
    tab == other_tab
  end

  def render
    view.render partial: tab.to_s, locals: {view: inner_helper} if tab
  end


end
