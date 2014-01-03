/**
 * 
 */
package org.ontohub.client;

import java.util.ArrayList;
import java.util.List;

import org.ontohub.client.KeywordListRequester.Keyword;
import org.ontohub.client.KeywordListRequester.KeywordList;
import org.ontohub.client.KeywordListRequester.Ontology;
import org.ontohub.client.KeywordListRequester.OntologyList;
import org.ontohub.client.Pagination.PaginateEvent;
import org.ontohub.client.Pagination.PaginateHandler;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyEvent;
import com.google.gwt.event.dom.client.KeyPressEvent;
import com.google.gwt.event.dom.client.KeyPressHandler;
import com.google.gwt.event.dom.client.KeyUpEvent;
import com.google.gwt.event.dom.client.KeyUpHandler;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiFactory;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.MultiWordSuggestOracle;
import com.google.gwt.user.client.ui.SuggestBox;
import com.google.gwt.user.client.ui.SuggestOracle.Suggestion;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;

/**
 * @author DanielVale
 *
 */
public class OntologySearch extends Composite {

	private static OntologySearchUiBinder uiBinder = GWT.create(OntologySearchUiBinder.class);

	interface OntologySearchUiBinder extends UiBinder<Widget, OntologySearch> {}

	@UiField
	Pagination pagination;

	@UiField
	FlowPanel conceptPanel;

	@UiField
	TextBox box;

	@UiField
	FlowPanel ontologyWidgetPanel;

	@UiField
	FocusPanel bar;

	private final KeywordListRequester requester;

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
		requester = new KeywordListRequester();
		initWidget(uiBinder.createAndBindUi(this));
		pagination.setPageRange(0, 0);
		pagination.addPaginateHandler(new PaginateHandler() {

			@Override
			public void onPaginate(PaginateEvent event) {
				page = event.getPage();
				updateOntologyWidgetList();
			}
		});
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
		return box;
	}

	private final void selectKeyword() {
		String text = box.getText().trim();
		if (text.length() == 0) {
			return;
		}
		OntologySearchConcept concept = new OntologySearchConcept(OntologySearch.this, "Category", text);
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
				conceptPanel.add(new OntologySearchConcept(OntologySearch.this, "Category", suggestion.getReplacementString()));
				box.setText("");
				page = 1;
				updateOntologyWidgetList();
			}
			
		});
		return box;
	}
	*/

	public final void updateOntologyWidgetList() {
		List<String> stringArray = new ArrayList<String>();
		for (Widget widget : conceptPanel) {
			if (widget instanceof OntologySearchConcept) {
				OntologySearchConcept concept = (OntologySearchConcept)widget;
				stringArray.add(concept.getItemLabel());
			}
		}
		requester.requestOntologyList(stringArray.toArray(new String[stringArray.size()]), page, new AsyncCallback<OntologyList>() {

			@Override
			public void onFailure(Throwable caught) {
				caught.printStackTrace();
			}

			@Override
			public void onSuccess(OntologyList ontologyList) {
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
				focusLastConcept(event);
				event.stopPropagation();
				event.preventDefault();
			} else if (ch == (char) KeyCodes.KEY_BACKSPACE) {
				focusLastConcept(event);
				event.stopPropagation();
				event.preventDefault();
			} else if (ch == (char) KeyCodes.KEY_DELETE) {
				focusLastConcept(event);
				event.stopPropagation();
				event.preventDefault();
			}
		}
	}

	@UiHandler("searchButton")
	public final void onSearchButtonClick(ClickEvent event) {
		selectKeyword();
	}

	private final void focusLastConcept(KeyEvent<?> event) {
		if (conceptPanel.getWidgetCount() > 0) {
			OntologySearchConcept concept = (OntologySearchConcept)conceptPanel.getWidget(conceptPanel.getWidgetCount() - 1);
			concept.setFocus(true);
		}
	}

	public final void selectNext(OntologySearchConcept concept) {
		int index = conceptPanel.getWidgetIndex(concept);
		if (index == conceptPanel.getWidgetCount() - 1) {
			box.setFocus(true);
		} else {
			OntologySearchConcept nextConcept = (OntologySearchConcept) conceptPanel.getWidget(index + 1);
			nextConcept.setFocus(true);
		}
	}

	public final void selectPrevious(OntologySearchConcept concept) {
		int index = conceptPanel.getWidgetIndex(concept);
		if (index > 0) {
			OntologySearchConcept previousConcept = (OntologySearchConcept) conceptPanel.getWidget(index - 1);
			previousConcept.setFocus(true);
		}
	}

	public void onConceptDeleted() {
		page = 1;
		updateOntologyWidgetList();
	}

	public final void setPaginated(boolean paginated) {
		pagination.setVisible(paginated);
	}

}
