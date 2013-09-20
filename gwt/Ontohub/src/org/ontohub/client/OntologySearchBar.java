/**
 * 
 */
package org.ontohub.client;

import org.ontohub.client.KeywordListRequester.Keyword;
import org.ontohub.client.KeywordListRequester.KeywordList;
import org.ontohub.client.KeywordListRequester.Ontology;
import org.ontohub.client.KeywordListRequester.OntologyList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyEvent;
import com.google.gwt.event.dom.client.KeyPressEvent;
import com.google.gwt.event.dom.client.KeyPressHandler;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiFactory;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.MultiWordSuggestOracle;
import com.google.gwt.user.client.ui.SuggestBox;
import com.google.gwt.user.client.ui.SuggestOracle.Suggestion;
import com.google.gwt.user.client.ui.Widget;

/**
 * @author DanielVale
 *
 */
public class OntologySearchBar extends Composite {

	private static OntologySearchBarUiBinder uiBinder = GWT.create(OntologySearchBarUiBinder.class);

	interface OntologySearchBarUiBinder extends UiBinder<Widget, OntologySearchBar> {}


	@UiField
	FlowPanel conceptPanel;

	@UiField
	SuggestBox box;

	@UiField
	FlowPanel ontologyWidgetPanel;

	private KeywordListRequester requester;

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
	public OntologySearchBar() {
		requester = new KeywordListRequester();
		initWidget(uiBinder.createAndBindUi(this));
	}

	@UiFactory
	public final SuggestBox makeSuggestBox() {
		final MultiWordSuggestOracle oracle = new MultiWordSuggestOracle();
		final SuggestBox box = new SuggestBox(oracle);
		box.addKeyPressHandler(new KeyPressHandler() {

			@Override
			public void onKeyPress(KeyPressEvent event) {
				System.out.print(box.getText());
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
				conceptPanel.add(new OntologySearchConcept(OntologySearchBar.this, "Category", suggestion.getReplacementString()));
				box.setText("");

				requester.requestOntologyList(new String[]{}, new AsyncCallback<OntologyList>() {

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
					}
					
				});
			}
			
		});
		return box;
	}

	@UiHandler("bar")
	public final void onBarClick(ClickEvent event) {
		box.setFocus(true);
		event.stopPropagation();
	}

	@UiHandler("box")
	public final void onBoxKeyDown(KeyDownEvent event) {
		char ch = (char) event.getNativeKeyCode();
		if (box.getTextBox().getCursorPos() == 0) {
			if (event.isLeftArrow()) {
				focusLastConcept(event);
				event.stopPropagation();
			} else if (ch == (char) KeyCodes.KEY_BACKSPACE) {
				focusLastConcept(event);
				event.stopPropagation();
			} else if (ch == (char) KeyCodes.KEY_DELETE) {
				focusLastConcept(event);
				event.stopPropagation();
			}
		}
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

}
