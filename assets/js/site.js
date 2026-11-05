(function () {
  var root = document.documentElement;
  var key = "fleetdm-ps-theme";
  var button = document.getElementById("theme-toggle");

  function current() {
    return root.getAttribute("data-theme") === "dark" ? "dark" : "light";
  }

  function apply(theme) {
    root.setAttribute("data-theme", theme);
    if (!button) return;
    button.textContent = theme === "dark" ? "Light theme" : "Dark theme";
    button.setAttribute("aria-pressed", theme === "dark" ? "true" : "false");
  }

  apply(current());

  if (button) {
    button.addEventListener("click", function () {
      var next = current() === "dark" ? "light" : "dark";
      try { localStorage.setItem(key, next); } catch (e) {}
      apply(next);
    });
  }

  document.querySelectorAll(".content h2, .content h3").forEach(function (heading) {
    var next = heading.nextElementSibling;
    if (!next) {
      heading.hidden = true;
      return;
    }
    var rank = { H2: 2, H3: 3 };
    var nextRank = rank[next.tagName];
    // A following subheading is the section body. Hide only an empty section
    // whose next heading is the same level or higher.
    if (nextRank && nextRank <= rank[heading.tagName]) heading.hidden = true;
  });

  var navToggle = document.getElementById("nav-toggle");
  if (navToggle && window.matchMedia) {
    var navQuery = window.matchMedia("(max-width: 860px)");
    var syncNavToggle = function () {
      navToggle.tabIndex = navQuery.matches ? 0 : -1;
    };
    syncNavToggle();
    if (navQuery.addEventListener) navQuery.addEventListener("change", syncNavToggle);
    else if (navQuery.addListener) navQuery.addListener(syncNavToggle);
  }

  document.querySelectorAll(".content pre").forEach(function (pre) {
    if (pre.querySelector(".copy")) return;
    var copy = document.createElement("button");
    copy.type = "button";
    copy.className = "copy";
    copy.textContent = "Copy";
    copy.addEventListener("click", function () {
      var code = pre.querySelector("code");
      var text = (code ? code.innerText : pre.innerText).replace(/\s+$/, "");
      if (!navigator.clipboard || !navigator.clipboard.writeText) return;
      navigator.clipboard.writeText(text).then(function () {
        copy.textContent = "Copied";
        window.setTimeout(function () { copy.textContent = "Copy"; }, 1400);
      }, function () {});
    });
    pre.appendChild(copy);
  });

  var filter = document.getElementById("cmdlet-filter");
  var empty = document.querySelector(".nav-empty");
  if (!filter) return;

  filter.addEventListener("input", function () {
    var q = filter.value.trim().toLowerCase();
    var matches = 0;

    document.querySelectorAll(".nav-static").forEach(function (block) {
      var shown = 0;
      block.querySelectorAll("a").forEach(function (link) {
        var match = !q || link.textContent.toLowerCase().indexOf(q) !== -1;
        link.parentElement.hidden = !match;
        if (match) shown += 1;
      });
      block.hidden = !!q && shown === 0;
      matches += shown;
    });

    document.querySelectorAll(".nav-group").forEach(function (group) {
      var shown = 0;
      group.querySelectorAll(".nav-cmd").forEach(function (link) {
        var match = !q || link.textContent.toLowerCase().indexOf(q) !== -1;
        link.parentElement.hidden = !match;
        if (match) shown += 1;
      });
      group.hidden = !!q && shown === 0;
      if (q && shown > 0) group.open = true;
      if (!q) group.open = group.hasAttribute("data-current-group");
      matches += shown;
    });

    var groups = document.querySelector(".nav-groups");
    if (groups) {
      var any = groups.querySelector(".nav-group:not([hidden])");
      groups.hidden = !!q && !any;
    }

    if (empty) empty.hidden = !q || matches > 0;
  });
})();
