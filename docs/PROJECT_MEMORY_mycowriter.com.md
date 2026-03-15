# Project Memory - mycowriter.com

Purpose: continuity log for monetization planning when direct repo access is unavailable.

## 2026-03-11
- Scope intentionally minimal:
  - AdSense integration only
  - no large image-storage migration needed for current usage
- Ad policy:
  - public pages may show ads
  - authenticated pages must never load AdSense script
- Next implementation entry required in mycowriter.com repo when accessible:
  - add layout-level AdSense toggle by auth state
  - validate Core Web Vitals and policy-safe placement

## 2026-03-12
- Reviewed after `myDNAobv` R2 production rollout.
- No scope change for `mycowriter.com`: remain on AdSense-only implementation plan.
- RubyMine handoff doc revalidated; still no storage-migration scope added.

## 2026-03-14
- AdSense integration implemented in repo behind flags (public-only). Includes helper gating via `adsense_authenticated?`, script injection in layout, inline/footer slot partials, and tests.
- Privacy policy page added with opt-out controls; GPC is honored and sets an opt-out cookie.
- `public/ads.txt` placeholder added; must be replaced with live publisher record before approval.
- Remaining ops items: privacy/cookie disclosure review, CSP review if enforcing.
- Removed unused user/admin stack (Devise/Pundit, articles/sections/paragraphs, API keys) to keep site demo-only.
- Database remains shared with MRDBID; no destructive migrations in mycowriter.
- Mycowriter production uses the shared MRDBID database; per-app mycowriter_* databases are intentionally unused and may be dropped.
