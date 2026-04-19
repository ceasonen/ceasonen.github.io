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

## 2026-04-19 Restore-And-Add MM NeurIPS

- Restored the broken exported homepage/publications files back to the previous good git state from commit `9610fc9` before making any new edits.
- Then added exactly two under-review entries on that clean baseline: one ACM Multimedia paper (the orthogonal distillation paper) and one NeurIPS paper.
- Kept the scope at the export/text layer only: `index.html`, `index.txt`, `publications/index.html`, and `publications/index.txt`.
- Did not edit `_next/static/css`, `_next/static/chunks`, `404`, `awards`, `cv`, images, or any other visual asset.
- Removed the temporary local repair script after the data injection was verified.

## 2026-04-19 Verification For Restore-And-Add

- Check 1: `git diff --name-only` stays limited to the four exported text files after restoring the good baseline and inserting the two new entries.
- Check 2: repeated `rg` searches confirmed both new titles and both under-review venue strings appear in homepage and publications exports.
- Check 3: JavaScript syntax validation of inline scripts in `index.html` and `publications/index.html` passes after the repair, which guards against the blank-page failure caused by malformed embedded payload strings.
