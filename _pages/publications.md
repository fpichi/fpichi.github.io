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

{% for post in site.publications reversed %}
  {% if post.pubsource == "unpublished" %}
    {% include archive-single.html %}
  {% endif %}
{% endfor %}

## Published

{% for post in site.publications reversed %}
  {% if post.pubsource == "journal" %}
    {% include archive-single.html %}
  {% endif %}
{% endfor %}

## Books

{% for post in site.publications reversed %}
  {% if post.pubsource == "book" %}
    {% include archive-single.html %}
  {% endif %}
{% endfor %}

## Proceedings

{% for post in site.publications reversed %}
  {% if post.pubsource == "proceeding" %}
    {% include archive-single.html %}
  {% endif %}
{% endfor %}