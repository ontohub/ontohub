package com.google.gwt.user.client.ui;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.ontohub.shared.Filter;
import org.ontohub.shared.Keyword;

import com.google.gwt.core.client.GWT;
import com.google.gwt.core.client.JsArray;
import com.google.gwt.dom.client.Element;
import com.google.gwt.dom.client.LIElement;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.ui.events.FilterSelectionEvent;
import com.google.gwt.user.client.ui.events.FilterSelectionHandler;
import com.google.gwt.user.client.ui.events.HasFilterSelectionHandlers;

/**
 * A widget that allows selecting a filter from a drop down list.
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class FilterSelector extends Composite implements HasWidgets, HasFilterSelectionHandlers {

	private static FilterSelectorUiBinder uiBinder = GWT
			.create(FilterSelectorUiBinder.class);

	interface FilterSelectorUiBinder extends UiBinder<Widget, FilterSelector> {
	}

	private final static List<FilterSelector> defaultFilterSelectorList = new LinkedList<FilterSelector>();
	private final List<FilterSelector> filterSelectorList;
	private final List<FilterSelectionHandler> filterSelectionHandlerList = new LinkedList<FilterSelectionHandler>();
	
    public FilterSelector() {
    	this(defaultFilterSelectorList);
    }

	public FilterSelector(List<FilterSelector> filterSelectorList) {
		this.filterSelectorList = filterSelectorList;
		filterSelectorList.add(this);
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

	private boolean open;

	private String typeLabel = null;

	private String itemLabel = null;

	/**
	 * Sets the title of the button
	 * 
	 * @param title the title to set to the button
	 */
	public final void setTitle(String title) {
		Element caretSpan = DOM.createSpan();
		caretSpan.addClassName("caret");
		button.getElement().setInnerText(title.trim() + " ");
		button.getElement().appendChild(caretSpan);
		setOpen(false);
	}

	@UiHandler("button")
	public final void onButtonClick(ClickEvent event) {
		toggle();
		event.stopPropagation();
		event.preventDefault();
	}

	/**
	 * Toggles the button by opening it if it is closed and closing it if it is open.
	 */
	private final void toggle() {
		setOpen(!isOpen());
	}

	/**
	 * Sets the selector open or closed
	 * 
	 * @param open <code>true</code> for the selector to be open and <code>false</code> for it to be
	 *     closed
	 */
	private final void setOpen(boolean open) {
		this.open = open;
		if (open) {
			for (FilterSelector filterSelector : filterSelectorList) {
				if (this != filterSelector) {
					filterSelector.setOpen(false);
				}
			}
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
		if (filters.length() > 0) {
			setTitle(filters.get(0).getName());
			itemLabel = filters.get(0).getValue();
		}
	}

	public final void setTypeLabel(String typeLabel) {
		this.typeLabel = typeLabel;
	}

	public final void setItemLabel(String itemLabel) {
		this.itemLabel = itemLabel;
	}

	public final String getTypeLabel() {
		return typeLabel;
	}

	public final String getItemLabel() {
		return itemLabel;
	}

	public final Keyword getKeyword() {
		Keyword keyword = Keyword.newInstance();
		keyword.setItem(itemLabel);
		keyword.setType(typeLabel);
		keyword.setRole(null);
		return keyword;
	}

	private final void add(final Filter filter) {
		Anchor menuItemAnchor = new Anchor();
		menuItemAnchor.setText(filter.getName() + filter.getCountLabel());
		menuItemAnchor.setHref("#");
		menuItemAnchor.addClickHandler(new ClickHandler() {
			@Override
			public void onClick(ClickEvent event) {
				setTitle(filter.getName());
				setOpen(false);
				itemLabel = filter.getValue();
				FilterSelectionEvent selectionEvent = new FilterSelectionEvent(); 
				for (FilterSelectionHandler filterSelectionHandler : filterSelectionHandlerList) {
					filterSelectionHandler.onFilterSelection(selectionEvent);
				}
			}
		});
		this.add(menuItemAnchor);
		Element menuItem = createListItem();
		menuItem.appendChild(menuItemAnchor.getElement());
		menu.appendChild(menuItem);
	}

	public final native LIElement createListItem() /*-{
		return $wnd.document.createElement('li');
	}-*/;


	List<Widget> widgetList = new ArrayList<Widget>();
	
	public final void onAttach() {
		super.onAttach();
		for (Widget aWidget : this) {
			if (!aWidget.isAttached()) {
				aWidget.onAttach();
			}
		}
	}

	public final void onDetach() {
		super.onDetach();
		for (Widget aWidget : this) {
			if (aWidget.isAttached()) {
				aWidget.onDetach();
			}
		}
	}

	@Override
	public final void add(Widget widget) {
		if (isAttached()) {
			widget.onAttach();
		}
		widgetList.add(widget);
	}

	@Override
	public final void clear() {
		widgetList.clear();
	}

	@Override
	public final Iterator<Widget> iterator() {
		return widgetList.iterator();
	}

	@Override
	public final boolean remove(Widget widget) {
		if (!isAttached()) {
			widget.onDetach();
		}
		return widgetList.remove(widget);
	}

	@Override
	public void addFilterSelectionHandler(FilterSelectionHandler handler) {
		filterSelectionHandlerList.add(handler);
	}

}
