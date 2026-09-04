import { defineConfig } from "vitepress";
import { sidebarFromSummary } from "./summary.mts";
import { gitbookHints } from "./hints.mts";

// Run as `vitepress build docs`, so root = docs and srcDir defaults to '.' (docs itself).
// SUMMARY.md drives GitBook Git Sync directly; it is excluded from the VitePress
// build and instead parsed into the sidebar below, so the two stay in sync by
// construction instead of by hand-maintained duplication.

export default defineConfig({
  title: "Midway",
  description: "Midway protocol documentation",
  cleanUrls: true,
  lastUpdated: true,
  srcExclude: ["SUMMARY.md"],

  // GitBook Git Sync reads README.md per directory; VitePress wants index.md
  // for a directory's index route. Rewriting here keeps the source files
  // named README.md (required for Git Sync) while routing them to '/',
  // '/quickstart/', '/reference/', and '/reference/contracts/'.
  rewrites: {
    "README.md": "index.md",
    ":dir/README.md": ":dir/index.md",
    ":dir/:sub/README.md": ":dir/:sub/index.md",
  },

  markdown: {
    config(md) {
      gitbookHints(md);
      // The `rewrites` above route README.md source files to index.md, but
      // that only changes output routing, not the .md links markdown
      // authors write. Rewrite link targets to match so
      // [Quickstart](quickstart/README.md) resolves instead of 404ing.
      md.core.ruler.before("normalize", "gitbook_readme_links", (state) => {
        state.src = state.src.replace(
          /\]\(((?:[^)]*\/)?)README\.md(#[^)]*)?\)/g,
          (_match, prefix: string, anchor = "") => `](${prefix}index.md${anchor})`,
        );
      });
    },
  },

  themeConfig: {
    search: { provider: "local" },
    outline: [2, 3],

    nav: [
      { text: "Quickstart", link: "/quickstart/" },
      { text: "Reference", link: "/reference/" },
      { text: "Security", link: "/security/operator-powers" },
    ],

    sidebar: sidebarFromSummary(new URL("../SUMMARY.md", import.meta.url).pathname),

    socialLinks: [{ icon: "github", link: "https://github.com/ripe0x/midway-docs" }],
  },
});
