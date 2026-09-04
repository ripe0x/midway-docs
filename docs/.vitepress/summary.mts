// Parses docs/SUMMARY.md into a VitePress sidebar. No dependencies: SUMMARY.md
// is a flat GFM list (## group headers, top-level "* [Title](path.md)" items,
// 2-space-indented nested items). Keeps the sidebar in sync with the same file
// GitBook Git Sync reads, so the nav never drifts from SUMMARY.md by hand.

import { readFileSync } from "node:fs";

function mdPathToLink(mdPath: string): string {
  if (mdPath === "README.md") return "/";
  if (mdPath.endsWith("/README.md")) {
    return "/" + mdPath.slice(0, -"README.md".length);
  }
  return "/" + mdPath.slice(0, -".md".length);
}

interface SidebarItem {
  text: string;
  link?: string;
  items?: SidebarItem[];
}

interface SidebarGroup {
  text: string;
  collapsed: boolean;
  items: SidebarItem[];
}

const groupRe = /^##\s+(.+?)\s*$/;
const itemRe = /^(\s*)\*\s+\[([^\]]+)\]\(([^)]+)\)\s*$/;

export function sidebarFromSummary(summaryPath: string): SidebarGroup[] {
  const lines = readFileSync(summaryPath, "utf8").split("\n");
  const groups: SidebarGroup[] = [];
  let currentGroup: SidebarGroup | null = null;
  let lastTopLevelItem: SidebarItem | null = null;

  for (const line of lines) {
    const groupMatch = line.match(groupRe);
    if (groupMatch) {
      currentGroup = { text: groupMatch[1], collapsed: false, items: [] };
      groups.push(currentGroup);
      lastTopLevelItem = null;
      continue;
    }

    const itemMatch = line.match(itemRe);
    if (!itemMatch || !currentGroup) continue;
    const [, indent, text, target] = itemMatch;
    const item: SidebarItem = { text, link: mdPathToLink(target) };

    if (indent.length > 0 && lastTopLevelItem) {
      (lastTopLevelItem.items ??= []).push(item);
    } else {
      currentGroup.items.push(item);
      lastTopLevelItem = item;
    }
  }

  return groups;
}
