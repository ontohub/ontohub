package org.ontohub.client;

import org.ontohub.shared.Keyword;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.BlurHandler;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.DoubleClickEvent;
import com.google.gwt.event.dom.client.FocusHandler;
import com.google.gwt.event.dom.client.HasBlurHandlers;
import com.google.gwt.event.dom.client.HasFocusHandlers;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyEvent;
import com.google.gwt.event.shared.HandlerRegistration;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.InlineLabel;
import com.google.gwt.user.client.ui.Widget;

public class OntologySearchConcept extends Composite implements HasFocusHandlers, HasBlurHandlers {

	private static OntologySearchConceptUiBinder uiBinder = GWT
			.create(OntologySearchConceptUiBinder.class);

	interface OntologySearchConceptUiBinder extends
			UiBinder<Widget, OntologySearchConcept> {
	}

	public OntologySearchConcept() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	@UiField
	FocusPanel panel;

	@UiField
	InlineLabel label;

	private String typeLabel;

	private String itemLabel;

	private OntologySearch ontologySearch;

	public OntologySearchConcept(OntologySearch ontologySearchBar, String typeLabel, String instanceLabel) {
		this.ontologySearch = ontologySearchBar;
		this.typeLabel = typeLabel;
		this.itemLabel = instanceLabel;
		initWidget(uiBinder.createAndBindUi(this));
		label.setText(instanceLabel);
	}

	@UiHandler("label")
	void onDoubleClick(DoubleClickEvent event) {
		this.removeFromParent();
	}

	@UiHandler("panel")
	void onPanelClick(ClickEvent event) {
		event.stopPropagation();
		event.preventDefault();
	}

	@UiHandler("panel")
	final void onPanelKeyDown(KeyDownEvent event) {
		char ch = (char) event.getNativeKeyCode();
		if (ch == (char) KeyCodes.KEY_LEFT) {
			selectPrevious();
			event.stopPropagation();
			event.preventDefault();
		} else if (ch == (char) KeyCodes.KEY_RIGHT) {
			selectNext();
			event.stopPropagation();
			event.preventDefault();
		} else if (ch == (char) KeyCodes.KEY_BACKSPACE) {
			removeFromParent(event);
		} else if (ch == (char) KeyCodes.KEY_DELETE) {
			removeFromParent(event);
		}
	}

	private final void removeFromParent(KeyEvent<?> event) {
		event.stopPropagation();
		event.preventDefault();
		selectNext();
		removeFromParent();
		ontologySearch.onConceptDeleted();
	}

	private final void selectNext() {
		ontologySearch.selectNext(this);
	}

	private final void selectPrevious() {
		ontologySearch.selectPrevious(this);
	}

	public final void setKeyword(Keyword keyword) {
		typeLabel = keyword.getType();
		itemLabel = keyword.getItem();
		label.setText(itemLabel);
	}

	public final Keyword getKeyword() {
		Keyword keyword = Keyword.newInstance();
		keyword.setItem(itemLabel);
		keyword.setType(typeLabel);
		keyword.setRole(null);
		return keyword;
	}

	public final void setFocus(boolean focused) {
		panel.setFocus(focused);
	}

	public final String getRoleLabel() {
		return "";
	}

	public final String getTypeLabel() {
		return typeLabel;
	}

	public final String getItemLabel() {
		return label.getText();
	}

	@Override
	public HandlerRegistration addBlurHandler(BlurHandler handler) {
		return panel.addBlurHandler(handler);
	}

	@Override
	public HandlerRegistration addFocusHandler(FocusHandler handler) {
		return panel.addFocusHandler(handler);
	}

}
