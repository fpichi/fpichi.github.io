---
layout: archive
# title: "Publications"
permalink: /publications/
author_profile: true
---

{% if author.googlescholar %}
  You can also find my articles on <u><a href="{{author.googlescholar}}">Google Scholar profile</a>.</u>
{% endif %}

{% include base_path %}

## Preprints

{% assign preprints = site.publications | where: "pubsource", "unpublished" | sort: "item" | reverse %}
{% for post in preprints %}
  {% include archive-single.html %}
{% endfor %}

## Published

{% assign journal_publications = site.publications | where: "pubsource", "journal" | sort: "item" | reverse %}
{% for post in journal_publications %}
  {% include archive-single.html %}
{% endfor %}

## Books

{% assign books = site.publications | where: "pubsource", "book" | sort: "item" | reverse %}
{% for post in books %}
  {% include archive-single.html %}
{% endfor %}

## Proceedings

{% assign proceedings = site.publications | where: "pubsource", "proceeding" | sort: "item" | reverse %}
{% for post in proceedings %}
  {% include archive-single.html %}
{% endfor %}
