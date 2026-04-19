# Conclusion

- Date: 2026-04-19
- Scope: updated the personal website to remove awards/extra archived information, refresh the bio image reference, and keep only the requested public-facing paper entries.

## Changes made

- Rebuilt the visible site pages as simplified static HTML with a shared stylesheet in `site.css`.
- Homepage now focuses on research profile, selected papers, and a public-safe current-work summary.
- Publications page now lists only three entries: one IJCAI paper, one IEEE WCL submission, and one IJCNN submission.
- Added `current-work/index.html` with anonymous-safe descriptions for ongoing work.
- Retired the old `awards` and `cv` pages so they no longer expose competition records or archived materials.
- Added a cache-busting query to the bio image reference: `bio.jpg?v=20260419`.
- Replaced the old `.txt` route payload files with neutral placeholders so outdated content is not exposed there either.

## Verification

- Checked the paper titles and author information against the local source files in `papers/ijcai/ijcai26.tex`, `papers/wcl/main.tex`, and `papers/ijcnn/main.tex`.
- Confirmed that old awards and extra archived information were removed from the rewritten HTML and `.txt` routes.
- Confirmed that the homepage and publications page now point to the updated bio image reference with a cache-busting version suffix.
