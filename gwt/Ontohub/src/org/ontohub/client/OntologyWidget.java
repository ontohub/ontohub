package org.ontohub.client;

import org.ontohub.shared.Ontology;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.KeyPressEvent;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.InlineLabel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;

public class OntologyWidget extends Composite {

	private static OntologyWidgetUiBinder uiBinder = GWT
			.create(OntologyWidgetUiBinder.class);

	interface OntologyWidgetUiBinder extends UiBinder<Widget, OntologyWidget> {
	}

	@UiField
	Anchor titleAnchor;
//
//	@UiField
//	InlineLabel acronymLabel;
//
//	@UiField
//	InlineLabel languageLabel;

	@UiField
	InlineLabel logicLabel;

	@UiField
	Label iriLabel;

	@UiField
	Label descriptionLabel;
	
	public OntologyWidget() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	public OntologyWidget(Ontology ontology) {
		initWidget(uiBinder.createAndBindUi(this));
		setOntology(ontology);
	}

	private final void setOntology(Ontology ontology) {
		titleAnchor.setText(ontology.getName());
		titleAnchor.setHref(ontology.getHref());
		titleAnchor.setTabIndex(-1);
//		acronymLabel.setText(ontology.getAcronym());
//		languageLabel.setText(ontology.getLanguage());
		logicLabel.setText(ontology.getLogic());
		iriLabel.setText(ontology.getIri());
		descriptionLabel.setText(ontology.getDescription());
	}

	@Override
	public final void onAttach() {
		super.onAttach();
		titleAnchor.setTabIndex(-1);
	}

	@UiHandler("widget")
	public final void onKeyPress(KeyPressEvent event) {
		Window.Location.assign(titleAnchor.getHref());
	}

}
