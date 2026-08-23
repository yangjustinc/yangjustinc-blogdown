#!/usr/bin/env python3
"""Check local links and fragments in a generated Hugo site."""

from __future__ import annotations

import argparse
import posixpath
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urljoin, urlparse


class DocumentParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: set[str] = set()
        self.references: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if values.get("id"):
            self.ids.add(values["id"] or "")
        if values.get("name"):
            self.ids.add(values["name"] or "")
        for attribute in ("href", "src"):
            if values.get(attribute):
                self.references.append(values[attribute] or "")


def document_url(path: Path, root: Path) -> str:
    relative = path.relative_to(root).as_posix()
    if relative == "index.html":
        return "/"
    if relative.endswith("/index.html"):
        return f"/{relative[:-10]}"
    return f"/{relative}"


def target_file(root: Path, url_path: str) -> Path:
    clean_path = posixpath.normpath(unquote(url_path)).lstrip("/")
    if clean_path in ("", "."):
        return root / "index.html"
    candidate = root / clean_path
    if url_path.endswith("/") or candidate.is_dir():
        return candidate / "index.html"
    if candidate.suffix:
        return candidate
    if candidate.exists():
        return candidate
    return candidate / "index.html"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("site", type=Path)
    parser.add_argument("--base-url", required=True)
    args = parser.parse_args()

    root = args.site.resolve()
    base = urlparse(args.base_url)
    documents: dict[Path, DocumentParser] = {}
    for html_file in root.rglob("*.html"):
        parsed = DocumentParser()
        parsed.feed(html_file.read_text(encoding="utf-8"))
        documents[html_file.resolve()] = parsed

    errors: list[str] = []
    skipped_schemes = {"data", "javascript", "mailto", "tel"}

    for source, document in documents.items():
        source_url = urljoin(args.base_url, document_url(source, root))
        for reference in document.references:
            parsed_reference = urlparse(reference)
            if parsed_reference.scheme in skipped_schemes or reference.startswith("//"):
                continue
            if parsed_reference.scheme in {"http", "https"} and parsed_reference.netloc != base.netloc:
                continue

            absolute = urlparse(urljoin(source_url, reference))
            destination = target_file(root, absolute.path).resolve()
            if not destination.exists():
                errors.append(f"{source.relative_to(root)}: missing {reference}")
                continue

            if absolute.fragment and destination.suffix == ".html":
                target_document = documents.get(destination)
                if target_document is None:
                    target_document = DocumentParser()
                    target_document.feed(destination.read_text(encoding="utf-8"))
                    documents[destination] = target_document
                fragment = unquote(absolute.fragment)
                if fragment not in target_document.ids:
                    errors.append(
                        f"{source.relative_to(root)}: missing fragment #{fragment} in "
                        f"{destination.relative_to(root)}"
                    )

    if errors:
        print("Internal link check failed:")
        for error in errors:
            print(f"  - {error}")
        return 1

    print(f"Checked {len(documents)} HTML documents: no broken internal links.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
