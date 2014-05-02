/**
 * 
 */
package org.ontohub.client;

import java.util.ArrayList;
import java.util.List;

import org.ontohub.client.Pagination.PaginateEvent;
import org.ontohub.client.Pagination.PaginateHandler;
import org.ontohub.shared.FiltersMap;
import org.ontohub.shared.Keyword;
import org.ontohub.shared.Ontology;
import org.ontohub.shared.OntologyList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.BlurEvent;
import com.google.gwt.event.dom.client.BlurHandler;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.FocusEvent;
import com.google.gwt.event.dom.client.FocusHandler;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyUpEvent;
import com.google.gwt.event.dom.client.KeyUpHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiFactory;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FilterSelector;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.InlineLabel;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;
import com.google.gwt.user.client.ui.events.FilterSelectionEvent;
import com.google.gwt.user.client.ui.events.FilterSelectionHandler;

/**
 * @author DanielVale
 *
 */
public class OntologySearch extends Composite implements FilterSelectionHandler {

	private static OntologySearchUiBinder uiBinder = GWT.create(OntologySearchUiBinder.class);

	interface OntologySearchUiBinder extends UiBinder<Widget, OntologySearch> {}

	@UiField
	Pagination pagination;

	@UiField
	FlowPanel conceptPanel;

	@UiField
	FlowPanel filterSelectorsPanel;

	@UiField
	TextBox box;

	@UiField
	FlowPanel ontologyWidgetPanel;

	@UiField
	FocusPanel bar;

	@UiField
	InlineLabel refreshIcon;

	@UiField
	InlineLabel warningIcon;

	@UiField
	FilterSelector selector0;

	@UiField
	FilterSelector selector1;

	@UiField
	FilterSelector selector2;

	@UiField
	FilterSelector selector3;

	@UiField
	FilterSelector selector4;
	
	private final OntohubServices requester;

	private int page = 1;

	/**
	 * Because this class has a default constructor, it can
	 * be used as a binder template. In other words, it can be used in other
	 * *.ui.xml files as follows:
	 * <ui:UiBinder xmlns:ui="urn:ui:com.google.gwt.uibinder"
	 *   xmlns:g="urn:import:**user's package**">
	 *  <g:**UserClassName**>Hello!</g:**UserClassName>
	 * </ui:UiBinder>
	 * Note that depending on the widget that is used, it may be necessary to
	 * implement HasHTML instead of HasText.
	 * @param ontologySearchService 
	 */
	public OntologySearch() {
		requester = new OntohubServices();
		initWidget(uiBinder.createAndBindUi(this));
		pagination.setPageRange(0, 0);
		pagination.addPaginateHandler(new PaginateHandler() {

			@Override
			public void onPaginate(PaginateEvent event) {
				page = event.getPage();
				updateOntologyWidgetList();
			}
		});
		setFilterSelectorsVisible(true);
		selector0.addFilterSelectionHandler(this);
		selector1.addFilterSelectionHandler(this);
		selector2.addFilterSelectionHandler(this);
		selector3.addFilterSelectionHandler(this);
		selector4.addFilterSelectionHandler(this);
	}

	@UiFactory
	public final TextBox makeTextBox() {
		final TextBox box = new TextBox();
		box.addKeyUpHandler(new KeyUpHandler() {

			@Override
			public void onKeyUp(KeyUpEvent event) {
				if (KeyUpEvent.isArrow(event.getNativeKeyCode())) {
					return;
				}
				char ch = (char) event.getNativeKeyCode();
				if (box.getCursorPos() == 0) {
					if (ch == (char) KeyCodes.KEY_BACKSPACE) {
						return;
					} else if (ch == (char) KeyCodes.KEY_DELETE) {
						return;
					}
				}
				if (ch == (char) KeyCodes.KEY_ENTER) {
					selectKeyword();
				}
			}
		});
		box.addBlurHandler(new BlurHandler() {
			@Override
			public void onBlur(BlurEvent event) {
				OntologySearch.this.getElement().removeClassName("SearchBar-textBoxFocus");
			}
		});
		box.addFocusHandler(new FocusHandler() {
			@Override
			public void onFocus(FocusEvent event) {
				OntologySearch.this.getElement().addClassName("SearchBar-textBoxFocus");
			}
		});
		return box;
	}

	/**
	 * Selects a keyword
	 */
	private final void selectKeyword() {
		String text = box.getText().trim();
		if (text.length() == 0) {
			return;
		}
		OntologySearchConcept concept = new OntologySearchConcept(OntologySearch.this, "Mixed", text);
		concept.addBlurHandler(new BlurHandler() {
			@Override
			public void onBlur(BlurEvent event) {
				OntologySearch.this.getElement().removeClassName("SearchBar-conceptFocus");
			}
		});
		concept.addFocusHandler(new FocusHandler() {
			@Override
			public void onFocus(FocusEvent event) {
				OntologySearch.this.getElement().addClassName("SearchBar-conceptFocus");
			}
			
		});
		conceptPanel.add(concept);
		box.setText("");
		page = 1;
		updateOntologyWidgetList();
	}

	/*
	@UiFactory
	public final SuggestBox makeSuggestBox() {
		final MultiWordSuggestOracle oracle = new MultiWordSuggestOracle();
		final SuggestBox box = new SuggestBox(oracle);
		box.addKeyUpHandler(new KeyUpHandler() {

			@Override
			public void onKeyUp(KeyUpEvent event) {
				if (KeyUpEvent.isArrow(event.getNativeKeyCode())) {
					return;
				}
				char ch = (char) event.getNativeKeyCode();
				if (box.getTextBox().getCursorPos() == 0) {
					if (ch == (char) KeyCodes.KEY_BACKSPACE) {
						return;
					} else if (ch == (char) KeyCodes.KEY_DELETE) {
						return;
					}
				}
				requester.requestKeywordList(box.getText(), new AsyncCallback<KeywordList>() {

					@Override
					public void onFailure(Throwable caught) {
						caught.printStackTrace();
					}

					@Override
					public void onSuccess(KeywordList keywordList) {
						for (Keyword keyword : keywordList) {
							oracle.add(keyword.getText());
						}
						box.showSuggestionList();
					}
				});
			}
			
		});
		box.addSelectionHandler(new SelectionHandler<Suggestion>() {

			@Override
			public void onSelection(SelectionEvent<Suggestion> event) {
				Suggestion suggestion = event.getSelectedItem();
				conceptPanel.add(new OntologySearchConcept(OntologySearch.this, "Mixed", suggestion.getReplacementString()));
				box.setText("");
				page = 1;
				updateOntologyWidgetList();
			}
			
		});
		return box;
	}
	*/

	/**
	 * Handle the deletion of a concept.
	 */
	public final void onConceptDeleted() {
		page = 1;
		updateOntologyWidgetList();
	}

	/**
	 * Updates the ontology widget list to match the filters. 
	 */
	public final void updateOntologyWidgetList() {
		List<Keyword> keywordArray = new ArrayList<Keyword>();
		keywordArray.add(selector0.getKeyword());
		keywordArray.add(selector1.getKeyword());
		keywordArray.add(selector2.getKeyword());
		keywordArray.add(selector3.getKeyword());
		keywordArray.add(selector4.getKeyword());
		for (Widget widget : conceptPanel) {
			if (widget instanceof OntologySearchConcept) {
				OntologySearchConcept concept = (OntologySearchConcept)widget;
				keywordArray.add(concept.getKeyword());
			}
		}
		refreshIcon.setVisible(true);
		warningIcon.setVisible(false);
		requester.requestOntologyList(keywordArray.toArray(new Keyword[keywordArray.size()]), page, new AsyncCallback<OntologyList>() {

			@Override
			public void onFailure(Throwable caught) {
				caught.printStackTrace();
				refreshIcon.setVisible(false);
				warningIcon.setVisible(true);
			}

			@Override
			public void onSuccess(OntologyList ontologyList) {
				refreshIcon.setVisible(false);
				warningIcon.setVisible(false);
				ontologyWidgetPanel.clear();
				for (Ontology ontology : ontologyList) {
					OntologyWidget ontologyWidget = new OntologyWidget(ontology);
					ontologyWidgetPanel.add(ontologyWidget);
				}
				int index = ontologyList.getPage();
				int length = (int)Math.ceil((double)ontologyList.getOntologiesInSet() / (double)ontologyList.getOntologiesPerPage());
				pagination.setPageRange(index, length);
			}
			
		});
	}

	@UiHandler("bar")
	public final void onBarClick(ClickEvent event) {
		box.setFocus(true);
		event.stopPropagation();
	}

	@UiHandler("box")
	public final void onBoxKeyDown(KeyDownEvent event) {
		char ch = (char) event.getNativeKeyCode();
		if (box.getCursorPos() == 0) {
			if (event.isLeftArrow()) {
				focusLastConcept();
				event.stopPropagation();
				event.preventDefault();
			} else if (ch == (char) KeyCodes.KEY_BACKSPACE) {
				focusLastConcept();
				event.stopPropagation();
				event.preventDefault();
			} else if (ch == (char) KeyCodes.KEY_DELETE) {
				focusLastConcept();
				event.stopPropagation();
				event.preventDefault();
			}
		}
	}

	@UiHandler("searchButton")
	public final void onSearchButtonClick(ClickEvent event) {
		selectKeyword();
	}

	/**
	 * Focuses the last concept.
	 */
	private final void focusLastConcept() {
		if (conceptPanel.getWidgetCount() > 0) {
			OntologySearchConcept concept = (OntologySearchConcept)conceptPanel.getWidget(conceptPanel.getWidgetCount() - 1);
			concept.setFocus(true);
		}
	}

	/**
	 * Selects the next search component
	 * 
	 * @param concept the concept in relation to which to select the next
	 */
	public final void selectNext(OntologySearchConcept concept) {
		int index = conceptPanel.getWidgetIndex(concept);
		if (index == conceptPanel.getWidgetCount() - 1) {
			box.setFocus(true);
		} else {
			OntologySearchConcept nextConcept = (OntologySearchConcept) conceptPanel.getWidget(index + 1);
			nextConcept.setFocus(true);
		}
	}

	/**
	 * Selects the previous search component
	 * 
	 * @param concept the concept in relation to which to select the previous
	 */
	public final void selectPrevious(OntologySearchConcept concept) {
		int index = conceptPanel.getWidgetIndex(concept);
		if (index > 0) {
			OntologySearchConcept previousConcept = (OntologySearchConcept) conceptPanel.getWidget(index - 1);
			previousConcept.setFocus(true);
		}
	}

	/**
	 * Sets whether the results are paginated.
	 * 
	 * @param paginated <code>true</code> to make the results paginated and <code>false</code>
	 *      otherwise
	 */
	public final void setPaginated(boolean paginated) {
		pagination.setVisible(paginated);
	}

	/**
	 * Sets whether filter selectors are visible.
	 * 
	 * @param visible <code>true</code> to make filter selector visible and <code>false</code>
	 *      to make filter selectors invisible
	 */
	public final void setFilterSelectorsVisible(boolean visible) {
		filterSelectorsPanel.setVisible(visible);
		if (visible) {
			updateFilterSelectors();
		}
	}

	/**
	 * Updates the filter selectors with the values embedded in the website
	 */
	private final void updateFilterSelectors() {
		if (FiltersMap.existsWindowInstance()) {
			System.out.println("Window Instance");
			setFiltersMap(FiltersMap.getWindowInstance());
		} else {
			requester.requestFilterMap(new AsyncCallback<FiltersMap>() {

				@Override
				public void onFailure(Throwable caught) {
					System.out.println("No Instance");
					warningIcon.setVisible(true);
				}

				@Override
				public void onSuccess(FiltersMap map) {
					System.out.println("Server Instance");
					setFiltersMap(map);
				}

			});
		}
	}

	private final void setFiltersMap(FiltersMap map) {
		selector0.addAll(map.getOntologyTypeFilters());
		selector1.addAll(map.getProjectFilters());
		selector2.addAll(map.getFormalityLevelFilters());
		selector3.addAll(map.getLicenseModelFilters());
		selector4.addAll(map.getTaskFilters());
	}

	@Override
	public void onFilterSelection(FilterSelectionEvent event) {
		page = 1;
		updateOntologyWidgetList();
	}

}
