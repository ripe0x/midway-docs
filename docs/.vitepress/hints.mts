// Rewrites GitBook hint blocks into VitePress default-theme containers before
// the markdown-it pipeline parses them, so GitBook Git Sync and the VitePress
// build read the exact same source files.
//
//   {% hint style="warning" %}   ->   ::: warning
//   ...                                ...
//   {% endhint %}                ->   :::

import type MarkdownIt from "markdown-it";

const STYLE_TO_CONTAINER: Record<string, string> = {
  info: "info",
  warning: "warning",
  danger: "danger",
  success: "tip",
};

const hintOpenRe = /\{%\s*hint\s+style="(info|warning|danger|success)"\s*%\}/g;
const hintCloseRe = /\{%\s*endhint\s*%\}/g;

export function gitbookHints(md: MarkdownIt): void {
  md.core.ruler.before("normalize", "gitbook_hints", (state) => {
    state.src = state.src
      .replace(hintOpenRe, (_match, style: string) => `::: ${STYLE_TO_CONTAINER[style]}`)
      .replace(hintCloseRe, ":::");
  });
}
