package org.ontohub.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.DoubleClickEvent;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyEvent;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.InlineLabel;
import com.google.gwt.user.client.ui.Widget;

public class OntologySearchConcept extends Composite implements HasText {

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

	private void selectNext() {
		ontologySearch.selectNext(this);
	}

	private void selectPrevious() {
		ontologySearch.selectPrevious(this);
	}

	public void setText(String text) {
		String[] labels = text.split(":");
		if (labels.length != 2) {
			return;
		}
		typeLabel = labels[0];
		itemLabel = labels[1].substring(1, labels[1].length() - 1).replace("\\\"", "\"").replace("\\\\", "\\");
		label.setText(itemLabel);
	}

	public String getText() {
		itemLabel = label.getText();
		return typeLabel + ":\"" + itemLabel.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
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

}
