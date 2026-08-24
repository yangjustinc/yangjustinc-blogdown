(() => {
  const headings = document.querySelectorAll("main h2, main h3, main h4");

  for (const heading of headings) {
    if (heading.querySelector(":scope > .heading-anchor")) continue;

    const section = heading.closest(".section[id]");
    const id = heading.id || section?.id;
    if (!id) continue;

    const anchor = document.createElement("a");
    anchor.className = "heading-anchor";
    anchor.href = `#${id}`;
    anchor.setAttribute("aria-label", `Link to ${heading.textContent.trim()}`);
    anchor.title = "Link to this section";
    anchor.textContent = "#";
    heading.append(" ", anchor);
  }
})();
