package org.ontohub.client;

import org.ontohub.shared.FiltersMap;
import org.ontohub.shared.Keyword;
import org.ontohub.shared.KeywordList;
import org.ontohub.shared.Ontology;
import org.ontohub.shared.OntologyList;
import org.ontohub.shared.SearchResponse;

import com.google.gwt.core.client.JsArray;
import com.google.gwt.core.client.JsonUtils;
import com.google.gwt.http.client.Request;
import com.google.gwt.http.client.RequestBuilder;
import com.google.gwt.http.client.RequestCallback;
import com.google.gwt.http.client.RequestException;
import com.google.gwt.http.client.Response;
import com.google.gwt.http.client.URL;
import com.google.gwt.user.client.rpc.AsyncCallback;

/**
 * The Ontohub services for the search bar
 * 
 * @author Daniel Couto Vale <danielvale@uni-bremen.de>
 */
public class OntohubServices {

	/**
	 * Requests the filter map from the server
	 * 
	 * @param filtersMapCallback the callback for the filters map
	 */
	public void requestFilterMap(final AsyncCallback<FiltersMap> filtersMapCallback) {
		RequestBuilder builder = new RequestBuilder(RequestBuilder.GET, "ontologies/filters_map");
		builder.setHeader("Content-Type", "application/json");
		builder.setHeader("Accept", "application/json");
		try {
			builder.sendRequest(null, new RequestCallback() {
				@Override
				public void onError(Request request, Throwable exception) {
					filtersMapCallback.onFailure(exception);
				}
				@Override
				public void onResponseReceived(Request request, Response response) {
					if (200 == response.getStatusCode()) {
						FiltersMap filtersMap = (FiltersMap)JsonUtils.safeEval(response.getText());
						filtersMapCallback.onSuccess(filtersMap);
					} else if (response.getStatusCode() != 0) {
						onError(request, new Exception());
					}
				}
			});
		} catch (RequestException exception) {
			filtersMapCallback.onFailure(exception);
		}
	}

	/**
	 * Requests a keyword list with a given prefix.
	 * 
	 * @param prefix the prefix for the keywords to retrieve
	 * @param keywordListCallback the callback for the retrieved keyword list
	 */
	public void requestKeywordList(final String prefix, final AsyncCallback<KeywordList> keywordListCallback) {
		String requestData = "prefix=" + URL.encodeQueryString(prefix);
		RequestBuilder builder = new RequestBuilder(RequestBuilder.GET, "ontologies/keywords?" + requestData);
		builder.setHeader("Content-Type", "application/json");
		builder.setHeader("Accept", "application/json");
		try {
			builder.sendRequest(null, new RequestCallback() {
				@Override
				public void onError(Request request, Throwable exception) {
					keywordListCallback.onFailure(exception);
				}
				@Override
				public void onResponseReceived(Request request, Response response) {
					if (200 == response.getStatusCode()) {
						@SuppressWarnings("unchecked")
						JsArray<Keyword> array = (JsArray<Keyword>)JsonUtils.safeEval(response.getText());
						KeywordList keywordList = new KeywordList();
						for (int i = 0; i < (int)array.length(); i++) {
							Keyword keyword = array.get(i);
							keywordList.add(keyword);
						}
						keywordListCallback.onSuccess(keywordList);
					} else if (response.getStatusCode() != 0) {
						onError(request, new Exception());
					}
				}
			});
		} catch (RequestException exception) {
			keywordListCallback.onFailure(exception);
		}
	}

	/**
	 * Requests an ontology list with a given keyword list
	 * 
	 * @param keywordList the keyword list that ontologies must have
	 * @param page the page of the paginated result
	 * @param ontologyListCallback the ontology list with the keyword restrictions
	 */
	public void requestOntologyList(final Keyword[] keywordList, final int page, final AsyncCallback<OntologyList> ontologyListCallback) {
		String requestData;
		StringBuffer requestDataBuffer = new StringBuffer();
		for (Keyword keyword : keywordList) {
			requestDataBuffer.append("keywords[]=" + URL.encodeQueryString(keyword.toJson()));
			requestDataBuffer.append("&");
		}
		requestDataBuffer.append("page=" + page);
		requestData = requestDataBuffer.toString();
		RequestBuilder builder = new RequestBuilder(RequestBuilder.GET, "ontologies/search?" + requestData);
		builder.setHeader("Content-Type", "application/json");
		builder.setHeader("Accept", "application/json");
		try {
			builder.sendRequest(null, new RequestCallback() {
				@Override
				public void onError(Request request, Throwable exception) {
					ontologyListCallback.onFailure(exception);
				}
				@Override
				public void onResponseReceived(Request request, Response response) {
					if (200 == response.getStatusCode()) {
						SearchResponse searchResponse = (SearchResponse)JsonUtils.safeEval(response.getText());
						JsArray<Ontology> array = searchResponse.getOntologies();
						OntologyList ontologyList = new OntologyList(searchResponse.getPage(),
								searchResponse.getOntologiesPerPage(), searchResponse.getOntologiesInSet());
						for (int i = 0; i < (int)array.length(); i++) {
							Ontology ontology = array.get(i);
							ontologyList.add(ontology);
						}
						ontologyListCallback.onSuccess(ontologyList);
					} else if (response.getStatusCode() != 0) {
						onError(request, new Exception());
					}
				}
			});
		} catch (RequestException exception) {
			ontologyListCallback.onFailure(exception);
		}
	}

}

