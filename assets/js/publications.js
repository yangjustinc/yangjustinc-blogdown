(function () {
  "use strict";

  var explorer = document.getElementById("publication-explorer");
  if (!explorer) return;

  var activeStrand = "all";
  var searchTerm = "";
  var activeYear = "all";
  var entries = Array.prototype.slice.call(
    document.querySelectorAll(".publication-entry")
  );
  var marks = Array.prototype.slice.call(
    explorer.querySelectorAll(".publication-timeline-mark")
  );
  var resultCount = document.getElementById("publication-result-count");
  var selectedPaper = document.getElementById("publication-selected-paper");
  var search = document.getElementById("publication-search");
  var year = document.getElementById("publication-year");
  var bibtexData = {};

  function normalise(value) {
    return (value || "").toLowerCase().trim();
  }

  function matchesFilters(entry) {
    var strandMatches =
      activeStrand === "all" || entry.dataset.strand === activeStrand;
    var yearMatches =
      activeYear === "all" || entry.dataset.year === activeYear;
    var searchMatches = normalise(entry.dataset.search).indexOf(searchTerm) !== -1;
    return strandMatches && yearMatches && searchMatches;
  }

  function updateSections() {
    document.querySelectorAll("[data-publication-section]").forEach(function (section) {
      var hasVisibleEntry = Array.prototype.some.call(
        section.querySelectorAll(".publication-entry"),
        function (entry) { return !entry.hidden; }
      );
      section.hidden = !hasVisibleEntry;
    });
  }

  function updateExplorer() {
    var visibleIds = {};
    var visibleCount = 0;

    entries.forEach(function (entry) {
      var visible = matchesFilters(entry);
      entry.hidden = !visible;
      if (visible) {
        visibleIds[entry.id] = true;
        visibleCount += 1;
      }
    });

    marks.forEach(function (mark) {
      var visible = Boolean(visibleIds[mark.dataset.publicationId]);
      mark.classList.toggle("is-muted", !visible);
      mark.setAttribute("aria-hidden", String(!visible));
      mark.setAttribute("tabindex", visible ? "0" : "-1");
    });

    updateSections();
    resultCount.textContent = visibleCount +
      (visibleCount === 1 ? " publication" : " publications");
  }

  explorer.querySelectorAll("[data-strand-filter]").forEach(function (button) {
    button.addEventListener("click", function () {
      activeStrand = button.dataset.strandFilter;
      explorer.querySelectorAll("[data-strand-filter]").forEach(function (peer) {
        peer.setAttribute("aria-pressed", String(peer === button));
      });
      updateExplorer();
    });
  });

  search.addEventListener("input", function () {
    searchTerm = normalise(search.value);
    updateExplorer();
  });

  year.addEventListener("change", function () {
    activeYear = year.value;
    updateExplorer();
  });

  function selectTimelineMark(mark) {
    marks.forEach(function (peer) {
      peer.classList.toggle("is-selected", peer === mark);
    });
    selectedPaper.textContent = mark.dataset.label;
  }

  marks.forEach(function (mark) {
    mark.addEventListener("click", function () {
      selectTimelineMark(mark);
    });
    mark.addEventListener("keydown", function (event) {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        selectTimelineMark(mark);
      }
    });
  });

  var bibtexElement = document.getElementById("publication-bibtex-data");
  if (bibtexElement) {
    try {
      JSON.parse(bibtexElement.textContent).forEach(function (record) {
        bibtexData[record.publication_id] = record;
      });
    } catch (error) {
      document.querySelectorAll("[data-bibtex-id]").forEach(function (button) {
        button.hidden = true;
      });
    }
  }

  function downloadBibtex(record) {
    var blob = new Blob([record.bibtex + "\n"], {
      type: "application/x-bibtex;charset=utf-8"
    });
    var url = URL.createObjectURL(blob);
    var link = document.createElement("a");
    link.href = url;
    link.download = record.bibtex_filename;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);
  }

  document.querySelectorAll("[data-bibtex-id]").forEach(function (button) {
    button.addEventListener("click", function () {
      var record = bibtexData[button.dataset.bibtexId];
      if (record) downloadBibtex(record);
    });
  });

  updateExplorer();
})();
