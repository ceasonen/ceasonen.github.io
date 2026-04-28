# Conclusion

- Date: 2026-04-19
- Action: restored the website directly from git commit `228b6adf30ad5a3946042a552f01f30c3567eea2`.

## What was done

- Replaced the current tracked site files with the versions from `228b6ad` using `git checkout 228b6adf30ad5a3946042a552f01f30c3567eea2 -- .`.
- This restore covered the homepage, 404 pages, awards page, CV page, publications page, and `bio.jpg`, along with the matching PRISM static export files already tracked by that commit.
- No manual visual redesign was kept in place after the restore.
- Existing paper files in `papers/` were left untouched because they are outside the direct restore target for the visual rollback.

## Verification

- Verified that `git diff --name-status 228b6adf30ad5a3946042a552f01f30c3567eea2 -- .` only reports post-commit additions such as `conclusion.md` and the extra `papers/` assets, with no remaining diffs on the restored site files.
- Verified that `git status --short --untracked-files=all` shows the expected restored tracked pages staged against current `HEAD`.
- Verified by keyword search that the restored pages again contain the original PRISM navigation and page structure from the target commit.

## 2026-04-19 Text-Only Update

- Updated only text outputs in `index.html`, `index.txt`, `publications/index.html`, and `publications/index.txt`.
- Kept the restored PRISM visual style unchanged; no CSS, JS chunk, route layout, or other visual asset was edited.
- Refreshed the homepage avatar reference to `/bio.jpg?v=20260419` so the updated local `bio.jpg` is picked up without relying on stale browser cache.
- Simplified the homepage/publications content to the requested paper list and anonymous-safe current work wording.
- Corrected the first publication metadata so the visible author line and embedded BibTeX both match the updated IJCNN entry.

## 2026-04-19 Verification For Text-Only Update

- Check 1: `git diff --name-only` shows only `index.html`, `index.txt`, `publications/index.html`, and `publications/index.txt` as modified site outputs before commit.
- Check 2: repeated `rg` searches confirmed there are no remaining awards/CV nav entries, no old KR/WCL-specific manuscript wording, and no stale `chen2026arg` / old BibTeX residue in the exported files.
- Check 3: `git diff --stat -- index.html index.txt publications/index.html publications/index.txt` confirms the final delta is limited to text substitutions, with no broad structural rewrite.

## 2026-04-19 Full Git Restore To Previous Version

- Restored the site files directly from git commit `9610fc9` instead of doing any manual patching on the exported HTML.
- This restore covered `index.html`, `index.txt`, `publications/index.html`, and `publications/index.txt`, which are the only tracked site files that differed from `9610fc9`.
- No CSS, JS chunk, layout asset, route page, or image file was edited during this restore.
- This action was done first to recover the previous working site state before any further publication edits.

## 2026-04-19 Verification For Full Git Restore

- Check 1: `git diff --name-status 9610fc9..HEAD` was reviewed before restore and showed only the five expected files differed.
- Check 2: after checkout from `9610fc9`, the site content files match the previous git version again, with only `conclusion.md` carrying the new action log.
- Check 3: the restore was performed from git directly, not by reconstructing or hand-editing the page structure.

## 2026-04-19 Text-Only Navigation And Content Expansion

- Kept the restored PRISM visual style unchanged and modified only exported text/content files.
- Expanded the site navigation to `About`, `Publications`, `News`, `Highlights`, and `CV` in the existing template structure.
- Added a new `news/` page by reusing the existing exported page template and replacing only route/content text.
- Rewrote homepage, publications, CV, and highlights copy to be more professional and research-focused.
- Added the two requested under-review first-author manuscripts:
  `If You Hear It, Help Find It: Orthogonal Knowledge Distillation for Open-Vocabulary Audio-Visual Event Localization` and
  `Auditable Algorithmic Reasoning via Contract-Grounded Traces`.
- Updated hidden RSC payload text so navigation labels, metadata, routes, and page content match the visible HTML, while leaving CSS and JS assets untouched.

## 2026-04-19 Verification For Text-Only Navigation And Content Expansion

- Check 1: inline script syntax was validated for `index.html`, `publications/index.html`, `cv/index.html`, `awards/index.html`, and `news/index.html`; all passed after fixing the `cv/index.html` payload chunk.
- Check 2: repeated keyword and route searches confirmed the new navigation labels are present, the `news` route payload is correct, and the two under-review papers appear in homepage/publications/CV text outputs.
- Check 3: `git status --short` and `git diff --name-only` confirm the final site delta is restricted to exported text files:
  `index.html`, `index.txt`, `publications/index.html`, `publications/index.txt`, `cv/index.html`, `cv/index.txt`, `awards/index.html`, `awards/index.txt`, `news/index.html`, and `news/index.txt`.

## 2026-04-19 CV Route And Manuscript Metadata Fix

- Repaired the `cv` client-route payload by fixing the broken `zh -> en` boundary in `cv/index.txt`; this was the text-layer route issue affecting the `CV` page load path.
- Updated the `News` page text so it no longer claims both submissions are first-author papers; it now states that the ACM MM submission is co-first and second-listed, while the NeurIPS submission is first-author.
- Updated `CV` text in both exported route data and visible HTML to state the authorship roles for the two under-review papers, explicitly naming Yi Xu and Wenzhuo Lei.
- Kept all edits within exported text files only; no CSS, JS chunk, layout component, or visual styling asset was modified.

## 2026-04-19 Verification For CV Route And Manuscript Metadata Fix

- Check 1: targeted string searches confirmed the site files no longer contain the stale `First-Author Manuscripts Under Review`, `Two first-author manuscripts...`, `一作稿件在投`, or `目前两篇一作稿件...` wording.
- Check 2: `conda run --no-capture-output -n ai node` validation reported `RSC_OK` for `index.html`, `publications/index.html`, `news/index.html`, and `cv/index.html`, confirming the hidden payload scripts still parse.
- Check 3: a direct boundary check on `cv/index.txt` now passes for the repaired `"},"en":{"type":"text"...` transition, and final content checks confirm the MM / NeurIPS roles plus Yi Xu / Wenzhuo Lei appear where intended.

## 2026-04-20 Push And Release Verification

- Performed a final release check on the exported site files before pushing.
- Confirmed the text-only manuscript updates remain consistent across homepage, publications, news, and CV outputs.
- Prepared the staged site changes for commit and push on `main`.

## 2026-04-20 Verification For Push And Release

- Check 1: keyword scans confirmed the stale `First-Author Manuscripts Under Review` / `一作稿件在投` wording is absent from the site files, while the new MM and NeurIPS authorship-role text is present.
- Check 2: hidden payload parsing passed again with `RSC_OK` on `index.html`, `publications/index.html`, `news/index.html`, and `cv/index.html`; the repaired `cv/index.txt` boundary check also passed.
- Check 3: final role-specific checks passed for the ACM MM co-first-second-listed wording and the NeurIPS first-author wording in both `news` and `cv` exports before push.

## 2026-04-28 IJCAI Publication Reordering

- Updated the personal website publication order so the IJCAI paper `OrthKD: Extracting Generalized Clinical Knowledge from Heterogeneous Teachers for Lightweight Deployment` appears first.
- Moved the IJCNN corresponding-author paper `Enabling Visual Reasoning in Text-Only LLMs via Symbolic Scene Descriptions` to second.
- Shifted the remaining papers after those two while preserving their existing relative order: WCL, ACM MM under review, and NeurIPS under review.
- Applied the order consistently across homepage selected papers, the publications page, and the CV publication list.
- Updated the site footer last-updated date from April 19, 2026 to April 28, 2026 in the touched exports.

## 2026-04-28 Verification For IJCAI Reordering

- Check 1: order scans passed for `index.txt`, `index.html`, `publications/index.txt`, `publications/index.html`, `cv/index.txt`, and `cv/index.html`, confirming IJCAI first and IJCNN second.
- Check 2: publication-id scans passed for `index.txt` and `publications/index.txt`, confirming the hidden exported data order is `xu2026orthkd`, `lei2026symbolic`, `chen2026privacy`, `chen2026ovorthkd`, `chen2026argtrace`.
- Check 3: script parsing passed for `index.html`, `publications/index.html`, and `cv/index.html`, confirming the edited RSC payload scripts remain syntactically valid.
