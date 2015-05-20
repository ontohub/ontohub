Code-View on Serializers
=================================

Serializers are classes which transform a model into a textual representation, e.g. JSON or XML. We use [active_model_serializers](https://github.com/rails-api/active_model_serializers) for this task.

Those are primarily used for the JSON output of the Ontohub API.

Our serializers are located in [app/serializers/](https://github.com/ontohub/ontohub/tree/staging/app/serializers). They inherit from the general serializer `ApplicationSerializer` which defines methods for the locid and url helpers.

# Structure of a Serializer

Each serializer has an internal class `Reference` which is the serializer for a reference to the current object. It is supposed to only create an IRI of this object and a name (or equivalent).

This `Reference` serializer is used whenever we don't want to include the whole object because it might be huge or its details are not of interest. For example, in the serialization of an ontology, we want to show which license models the ontology has, but we don't want to include all the details about them. So, in our `OntologySerializer`, we use the `LicenseModelSerializer::Reference` instead of the default `LicenseModelSerializer` to give basic information on the license models and a pointer to the location of the details.
