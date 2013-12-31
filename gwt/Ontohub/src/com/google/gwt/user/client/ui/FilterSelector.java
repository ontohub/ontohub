package com.google.gwt.user.client.ui;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.ontohub.shared.Filter;

import com.google.gwt.core.client.GWT;
import com.google.gwt.core.client.JsArray;
import com.google.gwt.dom.client.Element;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Window;

public class FilterSelector extends Composite implements HasWidgets {

	private static FilterSelectorUiBinder uiBinder = GWT
			.create(FilterSelectorUiBinder.class);

	interface FilterSelectorUiBinder extends UiBinder<Widget, FilterSelector> {
	}

	public FilterSelector() {
		initWidget(uiBinder.createAndBindUi(this));
		button.getElement().setAttribute("type", "button");
		button.getElement().setAttribute("data-toggle", "dropdown");
		setOpen(false);
	}

	@UiField
	HTMLPanel selector;

	@UiField
	Button button;

	@UiField
	Element menu;

	private boolean open = false;

	public final void setTitle(String title) {
		Element caretSpan = DOM.createSpan();
		caretSpan.addClassName("caret");
		button.getElement().setInnerText(title.trim() + " ");
		button.getElement().appendChild(caretSpan);
	}

	@UiHandler("button")
	public final void onButtonClick(ClickEvent event) {
		toggle();
	}

	private final void toggle() {
		setOpen(!isOpen());
	}


	/**
	 * Sets the selector open or closed
	 * 
	 * @param open <code>true</code> for the selector to be open and <code>false</code> for it to be closed
	 */
	private final void setOpen(boolean open) {
		this.open = open;
		if (open) {
			selector.addStyleName("open");
		} else {
			selector.removeStyleName("open");
		}
	}

	/**
	 * Checks whether the selector is open
	 * 
	 * @return <code>true</code> if the selector is open and <code>false</code> otherwise
	 */
	private final boolean isOpen() {
		return open;
	}

	public final void addAll(JsArray<Filter> filters) {
		for (int i = 0; i < filters.length(); i++) {
			add(filters.get(i));
		}
	}

	private final void add(final Filter filter) {
		Anchor menuItemAnchor = new Anchor();
		menuItemAnchor.setText(filter.getName());
		menuItemAnchor.setHref("#");
		menuItemAnchor.addClickHandler(new ClickHandler() {
			@Override
			public void onClick(ClickEvent event) {
				setTitle(filter.getName());
				setOpen(false);
			}
		});
		this.add(menuItemAnchor);
		Element menuItem = createListItem();
		menuItem.appendChild(menuItemAnchor.getElement());
		menu.appendChild(menuItem);
	}

	public final native Element createListItem() /*-{
		return $wnd.document.createElement('li');
	}-*/;


	List<Widget> widgetList = new ArrayList<Widget>();
	
	public final void onAttach() {
		super.onAttach();
		for (Widget aWidget : this) {
			aWidget.onAttach();
		}
	}

	public final void onDetach() {
		super.onAttach();
		for (Widget aWidget : this) {
			aWidget.onDetach();
		}
	}

	@Override
	public void add(Widget widget) {
		if (isAttached()) {
			widget.onAttach();
		}
		widgetList.add(widget);
	}

	@Override
	public void clear() {
		widgetList.clear();
	}

	@Override
	public Iterator<Widget> iterator() {
		return widgetList.iterator();
	}

	@Override
	public boolean remove(Widget widget) {
		if (!isAttached()) {
			widget.onDetach();
		}
		return widgetList.remove(widget);
	}

}
