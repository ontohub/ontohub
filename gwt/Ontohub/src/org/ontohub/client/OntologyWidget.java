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
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.InlineLabel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;

public class OntologyWidget extends Composite {

	private static OntologyWidgetUiBinder uiBinder = GWT.create(OntologyWidgetUiBinder.class);

	interface OntologyWidgetUiBinder extends UiBinder<Widget, OntologyWidget> {
	}

	@UiField
	Image iconImage;

	@UiField
	Anchor titleAnchor;
//
	@UiField
	InlineLabel acronymLabel;

//	@UiField
//	InlineLabel languageLabel;

	@UiField
	InlineLabel logicLabel;

	@UiField
	Label iriLabel;

	@UiField
	Label descriptionLabel;

	@UiField
	Anchor typeAnchor;

	@UiField
	Anchor topic0Anchor;

	@UiField
	Anchor topic1Anchor;

	@UiField
	Anchor topic2Anchor;

	@UiField
	Anchor project0Anchor;

	@UiField
	Anchor project1Anchor;

	@UiField
	Anchor project2Anchor;
	
	public OntologyWidget() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	public OntologyWidget(Ontology ontology) {
		initWidget(uiBinder.createAndBindUi(this));
		setOntology(ontology);
	}

	private final void setOntology(Ontology ontology) {
		iconImage.setUrl(ontology.getIconUrl());
		iconImage.setAltText(ontology.getIconAltText());
		titleAnchor.setText(ontology.getName());
		titleAnchor.setHref(ontology.getHref());
		titleAnchor.setTabIndex(-1);
		if (null != ontology.getAcronym() && ontology.getAcronym().length() != 0) {
			acronymLabel.setVisible(true);
			acronymLabel.setText("(" + ontology.getAcronym() + ")");
		} else {
			acronymLabel.setVisible(false);
		}
//		languageLabel.setText(ontology.getLanguage());
		logicLabel.setText(ontology.getLogic());
		iriLabel.setText(ontology.getIri());
		descriptionLabel.setText(ontology.getDescription());
		updateWidgetAnchor(typeAnchor, ontology.getType(), ontology.getTypeUrl());
		updateWidgetAnchor(topic0Anchor, ontology.getTopic0(), ontology.getTopic0Url());
		updateWidgetAnchor(topic1Anchor, ontology.getTopic1(), ontology.getTopic1Url());
		updateWidgetAnchor(topic2Anchor, ontology.getTopic2(), ontology.getTopic2Url());
		updateWidgetAnchor(project0Anchor, ontology.getProject0(), ontology.getProject0Url());
		updateWidgetAnchor(project1Anchor, ontology.getProject1(), ontology.getProject1Url());
		updateWidgetAnchor(project2Anchor, ontology.getProject2(), ontology.getProject2Url());
	}

	/**
	 * Updates an anchor by setting its text and href and by displaying it only when there is a text
	 * and an href.
	 * 
	 * @param anchor the anchor to update
	 * @param anchorText the text of the anchor
	 * @param anchorHref the href of the anchor
	 */
	private final static void updateWidgetAnchor(Anchor anchor, String anchorText, String anchorHref) {
		if (anchorText != null && anchorText.length() != 0 && anchorHref != null && anchorHref.length() != 0) {
			anchor.setVisible(true);
			anchor.setText(anchorText);
			anchor.setHref(anchorHref);
		} else {
			anchor.setVisible(false);
		}
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
