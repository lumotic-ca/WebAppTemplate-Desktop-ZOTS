# Matcha ERP branding

## App icon source

Tauri generates all platform icons from a single **square** source image.

| Requirement | Recommendation |
|---|---|
| Format | PNG or JPEG |
| Minimum size | **1024×1024 px** |
| Aspect ratio | **1:1 (square)** — non-square images are center-cropped |
| Content | Logo centered with ~10–15% padding so edges are not clipped in rounded icons |

### Current source

- `app-icon-source.jpeg` — original (608×579)
- `app-icon-1024.png` — padded to square and upscaled for Tauri

### Use your Matcha logo

1. Replace `app-icon-source.jpeg` in this folder (or copy from the repo root `tauri-template/IMG_0655.jpeg`).

2. Check dimensions (optional):

   ```bash
   identify branding/app-icon-source.jpeg
   # or: file branding/app-icon-source.jpeg
   ```

3. Regenerate icons:

   ```bash
   cd apps/matcha/ERP/tauri
   npx tauri icon branding/app-icon-source.jpeg -o src-tauri/icons
   ```

If the photo is rectangular (typical for phone JPEGs), crop it to a square in an image editor first, or Tauri will crop from the center and may cut off parts of the logo.
