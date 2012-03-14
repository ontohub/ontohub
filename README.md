Ontohub
=======

A web-based repository for distributed ontologies.

An ontology is a formal, logic-based description of the concepts and
relationships that are of interest to an agent (user or service) or to a
community of agents. The conceptual model of an ontology reflects a consensus,
and the implementation of an ontology is often used to support a variety of
applications such as web services, expert systems, or search engines. Therefor,
ontologies are typically developed in teams. Ontohub wants to make this
step as convenient as possible.

This application started at the compact course [agile web development][0] given
by [Carsten Bormann][1] at the University of Bremen in March, 2012. The
concept and assignment came from [Till Mossakowski][2] and [Christoph
Lange][3] of the [AG Bernd Krieg-Brückner][4].

Initial developers are [Julian Kornberger][5] and [Henning Müller][6].

Configuration
-------------

### Hets environment variables

Hets environment variables and the extensions of files allowed for upload are
to be set in "config/hets.yml".

### Allowed URI schemas

Allowed URI schemas are to be set in
"config/initializers/ontohub_config.rb".

### Clean upload cache

    rails runner CarrierWave.clean_cached_files!


[0]: http://www.tzi.org/~cabo/awe12
[1]: http://www.tzi.org/~cabo
[2]: http://www.tzi.org/~till
[3]: http://kwarc.info/clange
[4]: http://www.informatik.uni-bremen.de/agbkb
[5]: https://github.com/corny
[6]: http://henning.orgizm.net
