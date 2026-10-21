#!/usr/bin/env python3
"""Synchronize publications with refs.bib, using the bk front matter style.

Requires pybtex (which includes latexcodec). Run from any directory:
    python3 markdown_generator/pubsFromBib.py
    python3 markdown_generator/pubsFromBib.py --output-dir /tmp/publications

Generate preprints, journals, books, and proceedings in bibliography order.
Existing publication URLs are reused when the BibTeX key, DOI, or title matches.
Duplicate and obsolete publication files are moved to the excluded bk directory.
"""

import argparse
import codecs
import html
import re
from collections import Counter
from datetime import date
from pathlib import Path

import latexcodec  # Registers the ulatex codec used for accented author names.
import yaml
from pybtex.database import parse_file


SCRIPT_DIR = Path(__file__).resolve().parent
CATEGORIES = {
    "misc": "unpublished", "unpublished": "unpublished",
    "article": "journal", "book": "book", "booklet": "book",
    "incollection": "proceeding", "inproceedings": "proceeding",
    "proceedings": "proceeding", "conference": "proceeding",
}


def plain_text(value):
    """Remove BibTeX grouping while preserving accents and complete names."""
    value = codecs.decode(value, "ulatex")
    return " ".join(value.replace("{", "").replace("}", "").split())


def html_escape(value):
    return html.escape(value, quote=True).replace("&#x27;", "&apos;")


def title_key(value):
    return re.sub(r"[^\w]", "", html.unescape(value).casefold())


def doi_key(value):
    return re.sub(r"^https?://(?:dx\.)?doi\.org/|^doi:\s*", "",
                  value.strip(), flags=re.IGNORECASE).casefold()


def read_front_matter(path):
    content = path.read_text(encoding="utf-8")
    match = re.match(r"\A---[ \t]*\n(.*?)\n---[ \t]*(?:\n|\Z)", content, re.DOTALL)
    if not match:
        raise ValueError(f"Missing YAML front matter in {path}")
    return yaml.safe_load(match[1])


def existing_publications(output_dir):
    """Index only top-level output files; never modify the backup directory."""
    index = {}
    managed = set()
    for path in sorted(output_dir.glob("*.md")):
        data = read_front_matter(path)
        if (data.get("collection") != "publications"
                or data.get("pubsource") not in CATEGORIES.values()):
            continue
        managed.add(path)
        key = re.search(r"@\w+\s*\{\s*([^,]+),", data.get("biblio", ""))
        identities = [("title", title_key(data["title"]))]
        if key:
            identities.append(("key", key[1]))
        url = data.get("paperurl", "")
        if re.match(r"https?://(?:dx\.)?doi\.org/", url, re.IGNORECASE):
            identities.append(("doi", doi_key(url)))
        for identity in identities:
            index.setdefault(identity, []).append(path)
    return index, managed


def select_publications(bibliography):
    """Keep one entry per work, preferring a publication over its preprint."""
    selected = []
    identities = {}
    for key, entry in bibliography.entries.items():
        category = CATEGORIES.get(entry.type.lower())
        if category is None:
            print(f"Skipping unsupported entry {key} ({entry.type})")
            continue
        fields = entry.fields
        tokens = [("title", title_key(plain_text(fields["title"])))]
        if fields.get("doi"):
            tokens.append(("doi", doi_key(fields["doi"])))
        previous = {identities[token] for token in tokens if token in identities}
        if previous:
            if len(previous) > 1:
                raise ValueError(f"Conflicting publication identities for {key}")
            position = previous.pop()
            old_key, old_entry = selected[position]
            if (CATEGORIES[old_entry.type.lower()] == "unpublished"
                    and category != "unpublished"):
                previous_position = position
                selected[position] = None
                position = len(selected)
                selected.append((key, entry))
                identities = {token: position if old_position == previous_position
                              else old_position
                              for token, old_position in identities.items()}
                print(f"Replacing preprint {old_key} with {key}")
            else:
                print(f"Skipping duplicate {key}; using {old_key}")
        else:
            position = len(selected)
            selected.append((key, entry))
        for token in tokens:
            identities[token] = position
    return [entry for entry in selected if entry is not None]


def preprint_label(fields):
    if fields.get("eprint"):
        return "arXiv:" + fields["eprint"]
    for name in ("number", "note"):
        if fields.get(name, "").lower().startswith("arxiv:"):
            return fields[name]
    return fields.get("note", "Preprint")


def publication_venue(entry):
    fields = entry.fields
    category = CATEGORIES[entry.type.lower()]
    if category == "unpublished":
        return preprint_label(fields)
    if category == "journal":
        return fields["journal"]
    if category == "book":
        return fields["publisher"]
    return "In the proceedings of " + fields.get("booktitle", fields.get("publisher", ""))


def publication_date(fields):
    """Use real dates when provided, otherwise January 1 of the given year."""
    month = fields.get("month", "1")
    if not month.isdigit():
        months = ("jan", "feb", "mar", "apr", "may", "jun",
                  "jul", "aug", "sep", "oct", "nov", "dec")
        month = months.index(month[:3].lower()) + 1
    return date(int(fields["year"]), int(month), int(fields.get("day", "1")))


def render_publication(key, entry, item, stem):
    fields = entry.fields
    title = html_escape(plain_text(fields["title"]))
    category = CATEGORIES[entry.type.lower()]
    venue = html_escape(plain_text(publication_venue(entry)))
    authors = []
    for person in entry.persons.get("author", entry.persons.get("editor", [])):
        given = plain_text(" ".join(person.first_names + person.middle_names))
        family = plain_text(" ".join(person.prelast_names + person.last_names))
        name = " ".join(part for part in (given, family) if part)
        if person.lineage_names:
            name += ", " + plain_text(" ".join(person.lineage_names))
        authors.append(name)

    lines = [
        "---",
        f'title: "{title}"',
        "collection: publications",
        f"permalink: /publication/{stem}",
        f"date: {publication_date(fields).isoformat()}",
        f"item: {item}",
        f"venue: '{venue}'",
    ]
    if category == "unpublished":
        lines.append(f"excerpt: '{html_escape(plain_text(preprint_label(fields)))}'")
    doi = fields.get("doi", "").strip()
    paper_url = (doi if doi.startswith(("https://", "http://"))
                 else "https://doi.org/" + doi) if doi else fields.get("url")
    if not paper_url and category == "unpublished":
        label = preprint_label(fields)
        if label.lower().startswith("arxiv:"):
            paper_url = "https://arxiv.org/abs/" + label[6:].strip()
    if paper_url:
        lines.append(f"paperurl: '{html_escape(paper_url)}'")
    lines.extend([
        f"authors: '{html_escape(', '.join(authors))}'",
        f"pubsource: '{category}'",
        "biblio: >",
    ])

    # Match bk's folded YAML block and Markdown line breaks in the bib dropdown.
    # Values from the parser already contain LaTeX escapes; keep them verbatim.
    bib_fields = [(role, " and ".join(str(person) for person in people))
                  for role, people in entry.persons.items()]
    bib_fields.extend(fields.items())
    bib_lines = [f"@{entry.type}{{{key},"]
    bib_lines.extend(
        f"{name} = {{{value}}}" + ("," if i < len(bib_fields) - 1 else "")
        for i, (name, value) in enumerate(bib_fields)
    )
    bib_lines.append("}")
    lines.append("\n\n".join(
        "    " + line.strip() + ("\\" if i < len(bib_lines) - 1 else "")
        for i, line in enumerate(bib_lines)
    ))
    lines.append("---")
    return "\n".join(lines) + "\n"


def generate(bib_path, output_dir):
    bibliography = parse_file(str(bib_path))
    entries = select_publications(bibliography)
    existing, managed = existing_publications(output_dir)
    remaining = Counter(CATEGORIES[entry.type.lower()] for _, entry in entries)
    publications = []
    for key, entry in entries:
        # Each section counts down independently in bibliography order.
        category = CATEGORIES[entry.type.lower()]
        item = remaining[category]
        remaining[category] -= 1
        fields = entry.fields
        title = plain_text(fields["title"])
        candidates = (existing.get(("key", key))
                      or existing.get(("doi", doi_key(fields.get("doi", ""))))
                      or existing.get(("title", title_key(title))) or [])
        path = candidates[0] if candidates else None
        if path is None:
            slug = re.sub(r"[^\w-]", "", title.replace(" ", "-"))
            slug = re.sub(r"-+", "-", slug).strip("-")
            path = output_dir / f"{publication_date(fields).isoformat()}-{slug}.md"
        publications.append((path, render_publication(key, entry, item, path.stem)))

    # Validate every entry before writing any files.
    paths = [path for path, _ in publications]
    if len(set(paths)) != len(paths):
        raise ValueError("Multiple publications resolve to the same output file")
    output_dir.mkdir(parents=True, exist_ok=True)
    for path, markdown in publications:
        path.write_text(markdown, encoding="utf-8")
        print(f"Generated {path.name}")
    # Retain removed entries and duplicate files as backups, outside the site.
    for path in sorted(managed - set(paths)):
        backup = output_dir / "bk" / path.name
        backup.parent.mkdir(parents=True, exist_ok=True)
        suffix = 1
        while backup.exists():
            backup = backup.with_name(f"{path.stem}-{suffix}{path.suffix}")
            suffix += 1
        path.rename(backup)
        print(f"Archived obsolete or duplicate publication: {path.name}")
    return paths


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bib", type=Path, default=SCRIPT_DIR / "refs.bib")
    parser.add_argument("--output-dir", type=Path,
                        default=SCRIPT_DIR.parent / "_publications")
    args = parser.parse_args()
    paths = generate(args.bib, args.output_dir)
    print(f"Generated {len(paths)} publications in bibliography order.")


if __name__ == "__main__":
    main()
