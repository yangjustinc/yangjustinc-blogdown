(function () {
  "use strict";

  var explorer = document.getElementById("publication-explorer");
  var recentSection = document.getElementById("recent-peer-reviewed-work");
  if (!explorer || !recentSection) return;

  function normaliseDoi(url) {
    return (url || "")
      .replace(/^https?:\/\/(dx\.)?doi\.org\//i, "")
      .toLowerCase()
      .trim();
  }

  function entryDoi(entry) {
    var link = entry.querySelector('.publication-entry-actions a[href*="doi.org/"]');
    return link ? normaliseDoi(link.href) : "";
  }

  function inferYear(entry) {
    var explicitYear = parseInt(entry.dataset.year, 10);
    if (Number.isFinite(explicitYear)) return explicitYear;

    var citation = entry.querySelector(".publication-citation");
    var match = citation && citation.textContent.match(/\(((?:19|20)\d{2})\)/);
    return match ? parseInt(match[1], 10) : -Infinity;
  }

  function bibtexField(record, field) {
    if (!record || !record.bibtex) return "";
    var pattern = new RegExp(field + "\\s*=\\s*\\{([^}]*)\\}", "i");
    var match = record.bibtex.match(pattern);
    return match ? match[1].replace(/\\&/g, "&").trim() : "";
  }

  var bibtexData = {};
  var bibtexElement = document.getElementById("publication-bibtex-data");
  if (bibtexElement) {
    try {
      JSON.parse(bibtexElement.textContent).forEach(function (record) {
        bibtexData[record.publication_id] = record;
      });
    } catch (error) {
      bibtexData = {};
    }
  }

  var selectedDois = {};
  var selectedSection = document.getElementById("programme-defining-outputs");
  if (selectedSection) {
    selectedSection.querySelectorAll('a[href*="doi.org/"]').forEach(function (link) {
      selectedDois[normaliseDoi(link.href)] = true;
    });
  }

  var peerReviewedSection = Array.prototype.find.call(
    explorer.querySelectorAll("[data-publication-section]"),
    function (section) {
      var heading = section.querySelector("h3");
      return heading && /peer-reviewed/i.test(heading.textContent);
    }
  );
  if (!peerReviewedSection) return;

  var desiredEntries = Array.prototype.slice.call(
    peerReviewedSection.querySelectorAll(".publication-entry")
  )
    .filter(function (entry) {
      var doi = entryDoi(entry);
      return !doi || !selectedDois[doi];
    })
    .sort(function (a, b) {
      var yearDifference = inferYear(b) - inferYear(a);
      if (yearDifference !== 0) return yearDifference;
      return a.textContent.localeCompare(b.textContent);
    })
    .slice(0, 5);

  var existingCards = {};
  recentSection.querySelectorAll(".recent-publication").forEach(function (card) {
    var link = card.querySelector('a[href*="doi.org/"]');
    if (link) existingCards[normaliseDoi(link.href)] = card;
  });

  function makeRecentCard(entry) {
    var doi = entryDoi(entry);
    if (doi && existingCards[doi]) return existingCards[doi];

    var record = bibtexData[entry.id];
    var title = bibtexField(record, "title");
    var journal = bibtexField(record, "journal");
    var resolvedYear = inferYear(entry);
    var year = Number.isFinite(resolvedYear) ? String(resolvedYear) : bibtexField(record, "year");

    if (!title) {
      var citation = entry.querySelector(".publication-citation");
      title = citation ? citation.textContent.trim() : "Publication";
    }

    var card = document.createElement("div");
    card.className = "recent-publication";
    var paragraph = document.createElement("p");

    if (doi) {
      var link = document.createElement("a");
      link.href = "https://doi.org/" + doi;
      var strong = document.createElement("b");
      strong.textContent = title;
      link.appendChild(strong);
      paragraph.appendChild(link);
    } else {
      var strongTitle = document.createElement("b");
      strongTitle.textContent = title;
      paragraph.appendChild(strongTitle);
    }

    var meta = [journal, year].filter(Boolean).join(" · ");
    if (meta) {
      paragraph.appendChild(document.createElement("br"));
      var metaSpan = document.createElement("span");
      metaSpan.className = "selected-meta";
      metaSpan.textContent = meta;
      paragraph.appendChild(metaSpan);
    }

    card.appendChild(paragraph);
    return card;
  }

  recentSection.querySelectorAll(".recent-publication").forEach(function (card) {
    card.remove();
  });
  desiredEntries.forEach(function (entry) {
    recentSection.appendChild(makeRecentCard(entry));
  });
})();
