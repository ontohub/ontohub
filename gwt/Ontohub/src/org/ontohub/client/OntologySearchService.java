package org.ontohub.client;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

/**
 * The client side stub for the RPC service.
 */
@RemoteServiceRelativePath("searchForOntology")
public interface OntologySearchService extends RemoteService {
	String greetServer(String name) throws IllegalArgumentException;
}
