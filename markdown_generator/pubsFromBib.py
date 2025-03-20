#!/usr/bin/env python
# coding: utf-8

# # Publications markdown generator for academicpages
#
# Takes a set of bibtex of publications and converts them for use with [academicpages.github.io](academicpages.github.io).
# This is an interactive Jupyter notebook [see more info here](http://jupyter-notebook-beginner-guide.readthedocs.io/en/latest/what_is_jupyter.html).
#
# The core python code is also in `pubsFromBibs.py`.
# Run either from the `markdown_generator` folder after replacing updating the publist dictionary with:
# * bib file names
# * specific venue keys based on your bib file preferences
# * any specific pre-text for specific files
# * Collection Name (future feature)
#
# TODO: Make this work with other databases of citations,
# TODO: Merge this with the existing TSV parsing solution


from pybtex.database.input import bibtex
import pybtex.database.input.bibtex
from time import strptime
import string
import html
import os
import re

# todo: incorporate different collection types rather than a catch all publications, requires other changes to template
publist = {
    "proceeding": {
        "file": "refs.bib",
        "venuekey": "booktitle",
        "venue-pretext": "In the proceedings of ",
        "collection": {"name": "publications",
                       "permalink": "/publication/"}
    },
    "journal": {
        "file": "refs.bib",
        "venuekey": "journal",
        "venue-pretext": "",
        "collection": {"name": "publications",
                       "permalink": "/publication/"}
    },
    "unpublished": {
        "file": "refs.bib",
        "venuekey": "note",
        "venue-pretext": "",
        "collection": {"name": "publications",
                       "permalink": "/publication/"}
    }
}

html_escape_table = {
    "&": "&amp;",
    '"': "&quot;",
    "'": "&apos;"
}

def html_escape(text):
    """Produce entities within text."""
    return "".join(html_escape_table.get(c, c) for c in text)

pub_day_list = [str(i) for i in range(1, 32)]
item = 1
for pubsource in publist:
    print("")
    print("Scanning for ", pubsource)
    parser = bibtex.Parser()
    bibdata = parser.parse_file(publist[pubsource]["file"])

    # loop through the individual references in a given bibtex file
    for (i, bib_id) in enumerate(bibdata.entries):
        # reset default date
        pub_year = "1900"
        pub_month = "01"
        pub_day = pub_day_list[i]

        b = bibdata.entries[bib_id].fields
        try:
            pub_year = f'{b["year"]}'

            # todo: this hack for month and day needs some cleanup
            if "month" in b.keys():
                if(len(b["month"]) < 3):
                    pub_month = "0"+b["month"]
                    pub_month = pub_month[-2:]
                elif(b["month"] not in range(12)):
                    tmnth = strptime(b["month"][:3], '%b').tm_mon
                    pub_month = "{:02d}".format(tmnth)
                else:
                    pub_month = str(b["month"])
            if "day" in b.keys():
                pub_day = str(b["day"])

            pub_date = pub_year+"-"+pub_month+"-"+pub_day

            # strip out {} as needed (some bibtex entries that maintain formatting)
            clean_title = b["title"].replace("{", "").replace("}", "").replace("\\", "").replace(" ", "-")

            url_slug = re.sub("\\[.*\\]|[^a-zA-Z0-9_-]", "", clean_title)
            url_slug = url_slug.replace("--", "-")

            md_filename = (str(pub_date) + "-" + url_slug + ".md").replace("--", "-")
            html_filename = (str(pub_date) + "-" + url_slug).replace("--", "-")

            # Build Citation from text
            citation = ""

            # citation authors - todo - add highlighting for primary author?
            for author in bibdata.entries[bib_id].persons["author"]:
                citation = citation+" "+author.first_names[0]+" "+author.last_names[0]+", "

            # Creating authors
            authors = ""
            for author in bibdata.entries[bib_id].persons["author"]:
                authors = authors+author.first_names[0]+" "+author.last_names[0]+", "
            authors = authors[:-2]
            authors.replace("{", "").replace("}", "")
            # citation title
            # authors = authors + "\"" + html_escape(b["title"].replace("{", "").replace("}", "").replace("\\", "")) + ".\""

            # add venue logic depending on citation type
            venue = publist[pubsource]["venue-pretext"]+b[publist[pubsource]["venuekey"]].replace("{", "").replace("}", "").replace("\\", "")

            citation = citation + " " + html_escape(venue)
            citation = citation + ", " + pub_year + "."

            # YAML variables
            md = "---\ntitle: \"" + html_escape(b["title"].replace("{", "").replace("}", "").replace("\\", "")) + '"\n'

            md += """collection: """ + publist[pubsource]["collection"]["name"]

            md += """\npermalink: """ + publist[pubsource]["collection"]["permalink"] + html_filename

            note = False
            if "note" in b.keys():
                if len(str(b["note"])) > 5:
                    md += "\nexcerpt: '" + html_escape(b["note"]) + "'"
                    md += "\npaperurl: '" + 'https://arxiv.org/abs/' + b["note"][6:] + "'"
                    note = True

            md += "\ndate: " + str(pub_date)

            print("Check here if you notice something strange, it should prevent rebuilding the bib from scratch")
            # md += "\nitem: " + str(item) 

            md += "\nvenue: '" + html_escape(venue) + "'"

            url = False
            if "doi" in b.keys():
                if len(str(b["doi"])) > 5:
                    md += "\npaperurl: '" + 'https://doi.org/' + b["doi"] + "'"
                    url = True

            md += "\nauthors: '" + html_escape(authors) + "'"

            md += "\npubsource: '" + html_escape(pubsource) + "'"

            md += "\n---"

            # Markdown description for individual page
            # if note:
            #     md += "\n" + html_escape(b["note"]) + "\n"

            # if url:
            #     md += "\n[Access paper here](" + b["url"] + "){:target=\"_blank\"}\n"
            # else:
            #     md += "\nUse [Google Scholar](https://scholar.google.com/scholar?q="+html.escape(clean_title.replace("-","+"))+")
            # {:target=\"_blank\"} for full citation"

            md_filename = os.path.basename(md_filename)

            with open("../_publications/" + md_filename, 'w') as f:
                f.write(md)
            print(f'SUCESSFULLY PARSED {bib_id}: \"', b["title"][:60], "..."*(len(b['title']) > 60), "\"")
            item += 1
        # field may not exist for a reference
        except KeyError as e:
            # print(f'WARNING Missing Expected Field {e} from entry {bib_id}: \"', b["title"][:30], "..."*(len(b['title']) > 30), "\"")
            continue
