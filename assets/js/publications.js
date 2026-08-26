(function () {
  "use strict";

  var explorer = document.getElementById("publication-explorer");
  if (!explorer) return;

  var areaLabels = {
    clinical: "Clinical records & services",
    administrative: "Linked data & neurodivergence",
    addiction: "Addiction & treatment",
    inequalities: "Inequalities & social determinants",
    population: "Population health & methods"
  };

  var legacyLabels = {
    "Clinical data": areaLabels.clinical,
    "Administrative data": areaLabels.administrative,
    "Addiction": areaLabels.addiction,
    "Inequalities": areaLabels.inequalities,
    "Population health": areaLabels.population
  };

  function setLabelWithDot(element, label) {
    var dot = element.querySelector(".publication-strand-dot");
    element.textContent = "";
    if (dot) element.appendChild(dot);
    element.appendChild(document.createTextNode(label));
  }

  function applyResearchAreaLanguage() {
    var selectedSection = document.getElementById("programme-defining-outputs");
    if (selectedSection) {
      var selectedHeading = selectedSection.querySelector("h2");
      var selectedIntro = selectedSection.querySelector("p");
      if (selectedHeading) selectedHeading.textContent = "Selected publications";
      if (selectedIntro) {
        selectedIntro.textContent =
          "A curated selection of papers spanning the main substantive and methodological areas of my research.";
      }
    }

    var exploreSection = document.getElementById("explore-my-research");
    if (exploreSection) {
      var exploreIntro = exploreSection.querySelector("p");
      if (exploreIntro) {
        exploreIntro.textContent =
          "The timeline and filters group publications into broad research areas using OpenAlex topics, with curated classifications retained for selected papers. Open-access links are included where available.";
      }
    }

    var filterGroup = explorer.querySelector(".publication-filter-group");
    if (filterGroup) {
      filterGroup.setAttribute("aria-label", "Filter publications by research area");
    }

    explorer.querySelectorAll("[data-strand-filter]").forEach(function (button) {
      var key = button.dataset.strandFilter;
      if (key === "all") {
        button.textContent = "All areas";
      } else if (areaLabels[key]) {
        setLabelWithDot(button, areaLabels[key]);
      }
    });

    explorer.querySelectorAll(".publication-timeline-lane").forEach(function (lane) {
      var label = lane.textContent.trim();
      if (legacyLabels[label]) lane.textContent = legacyLabels[label];
    });

    explorer.querySelectorAll(".publication-entry").forEach(function (entry) {
      var key = entry.dataset.strand;
      var label = entry.querySelector(".publication-strand-label");
      if (label && areaLabels[key]) setLabelWithDot(label, areaLabels[key]);
    });

    var timelineTitle = document.getElementById("publication-timeline-title");
    if (timelineTitle) timelineTitle.textContent = "Publication timeline by research area";
  }

  applyResearchAreaLanguage();

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
