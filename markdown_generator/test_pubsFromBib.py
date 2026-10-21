"""Regression checks: python -B -m unittest discover -s markdown_generator."""

import contextlib
import io
import tempfile
import unittest
from pathlib import Path

from pybtex.database import parse_string

import pubsFromBib as generator


class PublicationGeneratorTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.bib = self.root / "refs.bib"
        self.output = self.root / "publications"

    def run_generator(self, bibliography):
        self.bib.write_text(bibliography, encoding="utf-8")
        with contextlib.redirect_stdout(io.StringIO()):
            return generator.generate(self.bib, self.output)

    def snapshot(self):
        return {p.relative_to(self.output): p.read_bytes()
                for p in self.output.rglob("*.md")}

    def test_all_categories_follow_source_order_and_round_trip(self):
        source = r"""
        @misc{preprint1, title={First preprint}, author={Pichi, Federico},
              year=2024, eprint={2401.12345}}
        @book{book1, title={First book}, editor={Hesthaven, Jan S.},
              year=2023, publisher={Publisher}}
        @incollection{chapter, title={Chapter}, booktitle={Collection},
              year=2024, author={Pichi, Federico}}
        @article{journal1, title={First journal}, journal={Computers \& Fluids},
              year=2024, author={Pichi, Federico}, doi={10.1234/first}}
        @unpublished{preprint2, title={Second preprint}, note={arXiv:2501.12345},
              year=2025, author={Pichi, Federico}}
        @article{journal2, title={Second journal}, journal={Other Journal},
              year=2025, author={Pichi, Federico}}
        @proceedings{conference, title={Conference}, booktitle={Proceedings},
              year=2025, editor={Pichi, Federico}}
        @inproceedings{paper, title={Conference paper}, booktitle={Proceedings},
              year=2025, author={Pichi, Federico}}
        @book{book2, title={Second book}, author={Pichi, Federico},
              year=2025, publisher={Publisher}}
        """
        paths = self.run_generator(source)
        original = parse_string(source, "bibtex")
        numbers = {"unpublished": [2, 1], "journal": [2, 1],
                   "book": [2, 1], "proceeding": [3, 2, 1]}
        for path, (key, entry) in zip(paths, original.entries.items()):
            data = generator.read_front_matter(path)
            self.assertEqual(data["item"], numbers[data["pubsource"]].pop(0))
            restored = parse_string(data["biblio"].replace("\\\n", "\n"), "bibtex")
            self.assertEqual(dict(restored.entries[key].fields), dict(entry.fields))
            self.assertEqual(restored.entries[key].persons, entry.persons)
        self.assertEqual(len(paths), 9)
        self.assertEqual(generator.read_front_matter(paths[0])["paperurl"],
                         "https://arxiv.org/abs/2401.12345")
        self.assertEqual(generator.read_front_matter(paths[1])["authors"],
                         "Jan S. Hesthaven")
        before = self.snapshot()
        self.assertEqual(self.run_generator(source), paths)
        self.assertEqual(self.snapshot(), before)

    def test_duplicate_files_and_removed_entries_are_archived(self):
        source = """@misc{old, title={Paper}, year=2024, eprint={2401.12345}}"""
        old_path = self.run_generator(source)[0]
        duplicate = old_path.with_name("duplicate----paper.md")
        duplicate.write_bytes(old_path.read_bytes())
        obsolete = old_path.with_name("removed.md")
        obsolete.write_text(old_path.read_text().replace("Paper", "Removed")
                            .replace("{old,", "{removed,"))
        # An existing backup must survive archiving a file of the same name.
        backup = self.output / "bk" / obsolete.name
        backup.parent.mkdir()
        backup.write_text("Existing backup")
        source = """@article{new, title={Paper}, year=2025,
                    journal={Journal}, doi={10.1234/paper}}"""
        paths = self.run_generator(source)
        self.assertEqual(len(list(self.output.glob("*.md"))), 1)
        self.assertEqual(generator.read_front_matter(paths[0])["pubsource"], "journal")
        self.assertEqual(len(list(backup.parent.glob("*.md"))), 3)
        self.assertEqual(backup.read_text(), "Existing backup")
        before = self.snapshot()
        self.run_generator(source)
        self.assertEqual(self.snapshot(), before)

    def test_repeated_bib_entries_prefer_published_version(self):
        source = """
        @misc{preprint, title={Same paper}, year=2024, doi={10.48550/arXiv.1}}
        @article{first, title={Earlier journal}, year=2024, journal={Journal}}
        @article{published, title={Same paper}, year=2025, journal={Journal},
                 doi={10.1234/paper}}
        @article{duplicate, title={Alternate title}, year=2025, journal={Journal},
                 doi={https://doi.org/10.1234/PAPER}}
        @misc{laterpreprint, title={Same paper}, year=2024}
        """
        paths = self.run_generator(source)
        self.assertEqual([generator.read_front_matter(p)["title"] for p in paths],
                         ["Earlier journal", "Same paper"])
        self.assertTrue(all(generator.read_front_matter(p)["pubsource"] == "journal"
                            for p in paths))

    def test_invalid_entry_does_not_modify_or_archive_existing_files(self):
        self.run_generator("@book{book, title={Book}, year=2024, publisher={Publisher}}")
        before = self.snapshot()
        with self.assertRaises(KeyError):
            self.run_generator("@article{broken, title={Broken}, year=2025}")
        self.assertEqual(self.snapshot(), before)


if __name__ == "__main__":
    unittest.main()
