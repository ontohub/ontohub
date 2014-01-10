package org.ontohub.client;

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

public class OntohubServices {

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

	public void requestOntologyList(final Keyword[] keywordList, final int page, final AsyncCallback<OntologyList> keywordListCallback) {
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
					keywordListCallback.onFailure(exception);
				}
				@Override
				public void onResponseReceived(Request request, Response response) {
					if (200 == response.getStatusCode()) {
						@SuppressWarnings("unchecked")
						SearchResponse searchResponse = (SearchResponse)JsonUtils.safeEval(response.getText());
						JsArray<Ontology> array = searchResponse.getOntologies();
						OntologyList ontologyList = new OntologyList(searchResponse.getPage(),
								searchResponse.getOntologiesPerPage(), searchResponse.getOntologiesInSet());
						for (int i = 0; i < (int)array.length(); i++) {
							Ontology ontology = array.get(i);
							ontologyList.add(ontology);
						}
						keywordListCallback.onSuccess(ontologyList);
					} else if (response.getStatusCode() != 0) {
						onError(request, new Exception());
					}
				}
			});
		} catch (RequestException exception) {
			keywordListCallback.onFailure(exception);
		}
	}

}

