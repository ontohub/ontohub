Code-View on importing Ontologies
=================================

The following files relate to the import of ontologies:

- `app/models/ontology_version/parsing.rb` Call of hets (see `lib/hets.rb`)
- `lib/hets.rb` Contains the system-caller of a hets procedure
- `lib/ontology_parser.rb` Contains the parser of the generated hets file. This does not include the actual ontology-creation
- `app/models/ontology/import.rb` Initiates `OntologyParser` with code blocks to create ontologies

## Initiate Parsing

`app/models/ontology_version/parsing.rb`

The method `parse` is defined to call **hets** and parse the corresponding xml-output.
`async_parse` calls the same method and performs the same actions but does so asynchronously
via a sidekiq-worker.

## Hets system call

`lib/hets.rb`

API-Interaction through the **module**-method `parse` which takes to file-path to an ontology
file as first parameter, an array of url replacements (string with "url_base_in_ontology=real_url_base")
as a second, but optional, one and a last parameter with a file path to an output file.

`Hets.parse` returns the filepath to the hets-xml-output as a string on success. The **pp.xml** file,
which contains code references, is usally the same filepath with the extension being replaced by
`.pp.xml`.

## Parsing Hets XML Output

`lib/ontology_parser.rb`
`app/models/ontology/import.rb`

The parsing of hets' XML output depends on two files. First `lib/ontology_parser.rb`
which contains the definition of `OntologyParser`-module. This module contains
itself a Listener which represents a **nokogiri** (xml parser-/creation-gem) SAX parser.
SAX parsers go through the xml file step by step in direct contrast to DOM parsers,
which parse he whole XML document into an internal representation before working with it.

If we want to recognize new elements in xml-files, or need to adjust the layout (maybe
because hets output changes), we will need to do this in the `Listener` definition
of `OntologyParser`.

The other important part of parsing is the definition of procs (code blocks) to react to
the encounter of specific elements inside of the xml document. This code can be found inside
of `app/models/ontology/import.rb` in the `import_xml`-method.
Everything that needs to be done inside of a `transaction do`-block to ensure the rollback of
already created objects (in the database) when raising errors.
The second part is the definition of local variables inside of the `transaction do`-block
(for example `ontology`, `root` and `link`). These variables can be accessed as closures across
all code-blocks inside of the `OntologyParser`. Those code-blocks are defined via
the hash argument to the `OntologyParser.parse`-method.

Keys losely correspond to the node definitions
inside of the OntologyParser (the constants), but need to be manually added, when they should be
called inside of the parser.

Each value inside of the hash is a Proc (a code-block like in `.each`-method calls) which is to be
executed when a specific element is encountered. The parameter `h` to the block is the xml-node with
attribute, which can be used to retrieve content from the xml-element.
