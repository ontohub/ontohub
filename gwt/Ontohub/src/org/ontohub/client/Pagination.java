package org.ontohub.client;

import java.util.LinkedList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.AnchorElement;
import com.google.gwt.dom.client.LIElement;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.shared.HandlerRegistration;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.Widget;

public class Pagination extends Composite {

	private static PaginationUiBinder uiBinder = GWT
			.create(PaginationUiBinder.class);

	@UiField LIElement item0;
	@UiField LIElement item1;
	@UiField LIElement item2;
	@UiField LIElement item3;
	@UiField LIElement item4;
	@UiField LIElement item5;
	@UiField LIElement item6;
	@UiField Anchor anchor0;
	@UiField Anchor anchor1;
	@UiField Anchor anchor2;
	@UiField Anchor anchor3;
	@UiField Anchor anchor4;
	@UiField Anchor anchor5;
	@UiField Anchor anchor6;
	HandlerRegistration registration0;
	HandlerRegistration registration1;
	HandlerRegistration registration2;
	HandlerRegistration registration3;
	HandlerRegistration registration4;
	HandlerRegistration registration5;
	HandlerRegistration registration6;

	List<PaginateHandler> paginateHandlerList = new LinkedList<PaginateHandler>();

	interface PaginationUiBinder extends UiBinder<Widget, Pagination> {
	}

	public Pagination() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	public Pagination(String firstName) {
		initWidget(uiBinder.createAndBindUi(this));
	}

	public final void setPageRange(int index, int length) {
		if (index <= 3 || length <= 5) {
			setItemEnabled(1, length);
			setItemActive(index);
			setAnchorMid(3);
		} else if (index + 2 < length) {
			setItemEnabled(0, 6);
			setItemActive(3);
			setAnchorMid(index);
		} else {
			int min = length >= 6 ? 0 : 1;
			setItemEnabled(min, 5);
			if (index + 2 == length) {
				setItemActive(3);
			} else if (index + 1 == length) {
				setItemActive(4);
			} else {
				setItemActive(5);
			}
			setAnchorMid(length - 2);
		}
		registration0 = setAnchorIndex(registration0, anchor0, 1);
		registration6 = setAnchorIndex(registration6, anchor6, length);
	}

	public static class PaginateEvent {
		private final int page;
		public PaginateEvent(int page) {
			this.page = page;
		}
		public final int getPage() {
			return page;
		}
	}

	public static interface PaginateHandler {
		public void onPaginate(PaginateEvent event);
	}

	private final void setAnchorMid(int mid) {
		registration1 = setAnchorIndexAndText(registration1, anchor1, mid - 2);
		registration2 = setAnchorIndexAndText(registration2, anchor2, mid - 1);
		registration3 = setAnchorIndexAndText(registration3, anchor3, mid - 0);
		registration4 = setAnchorIndexAndText(registration4, anchor4, mid + 1);
		registration5 = setAnchorIndexAndText(registration5, anchor5, mid + 2);
	}

	private final HandlerRegistration setAnchorIndexAndText(HandlerRegistration registration,
			final Anchor anchor, final int page) {
		anchor.setText("" + page);
		return setAnchorIndex(registration, anchor, page);
	}

	private final HandlerRegistration setAnchorIndex(HandlerRegistration registration,
			final Anchor anchor, final int page) {
		if (registration != null) {
			registration.removeHandler();
		}
		if (anchor.isEnabled()) {
			registration = anchor.addClickHandler(new ClickHandler() {
	
				@Override
				public void onClick(ClickEvent event) {
					firePaginateEvent(new PaginateEvent(page));
				}
				
			});
		} else {
			registration = null;
		}
		return registration;
	}

	public final void addPaginateHandler(PaginateHandler handler) {
		paginateHandlerList.add(handler);
	}

	private final void firePaginateEvent(PaginateEvent paginateEvent) {
		for (PaginateHandler paginateHandler : paginateHandlerList) {
			paginateHandler.onPaginate(paginateEvent);
		}
	}

	private final void setItemEnabled(int min, int max) {
		setItemEnabled(anchor0, item0, min <= 0 && max >= 0);
		setItemEnabled(anchor1, item1, min <= 1 && max >= 1);
		setItemEnabled(anchor2, item2, min <= 2 && max >= 2);
		setItemEnabled(anchor3, item3, min <= 3 && max >= 3);
		setItemEnabled(anchor4, item4, min <= 4 && max >= 4);
		setItemEnabled(anchor5, item5, min <= 5 && max >= 5);
		setItemEnabled(anchor6, item6, min <= 6 && max >= 6);
	}

	private static final void setItemEnabled(Anchor anchor, LIElement item, boolean enabled) {
		anchor.setEnabled(enabled);
		if (!enabled) {
			item.addClassName("disabled");
		} else {
			item.removeClassName("disabled");
		}
	}

	private final void setItemActive(int i) {
		setItemActive(item1, i == 1);
		setItemActive(item2, i == 2);
		setItemActive(item3, i == 3);
		setItemActive(item4, i == 4);
		setItemActive(item5, i == 5);
	}

	private static final void setItemActive(LIElement item, boolean active) {
		if (active) {
			item.addClassName("active");
		} else {
			item.removeClassName("active");
		}
	}

}
