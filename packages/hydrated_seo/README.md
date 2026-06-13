# hydrated_seo

A Static Site Generation (SSG) and pre-rendering package for Flutter Web SEO.

## Purpose

Flutter Web builds compile to client-side Single Page Applications (SPAs) that render in a Canvas (CanvasKit) or custom DOM tree. By default, web crawlers (like Googlebot) initially see an empty page with a loading spinner.

This package serves the compiled build locally, launches a headless browser via Puppeteer, visits configured routes (like `/`), waits for the Flutter app to signal that it is ready, and saves the fully populated HTML DOM snapshot back to `index.html`. It also automatically generates a `sitemap.xml` and a `robots.txt` file.

---

## Future Enhancements & Revisits

When this package is updated or production builds are refactored in the future, the following findings from the **June 2026 SEO Audit** should be addressed:

### 1. Production Build Integration
- **Status:** The pre-rendering script `prerender.dart` works locally but is **never invoked** in [cloudflare-pages-build.sh](../../cloudflare-pages-build.sh).
- **Action Needed:** Add the execution step to the build script immediately after `flutter build web`:
  ```bash
  echo "🚀 Running hydrated_seo pre-rendering pipeline..."
  dart run packages/hydrated_seo/bin/prerender.dart
  ```

### 2. Headless Chrome Sandbox in CI/CD
- **Status:** The current `puppeteer.launch()` configuration in [bin/prerender.dart](bin/prerender.dart) does not pass any CLI flags.
- **Action Needed:** Standard CI/CD environments (like Cloudflare Pages build containers) will crash unless sandboxing is disabled. When integrating in production, configure the browser launch parameters to include:
  ```dart
  final browser = await puppeteer.launch(
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  );
  ```

### 3. Open Graph (og:image) SVG Support
- **Status:** The `ogImage` link configured in [lib/main.dart](../../lib/main.dart) uses `t1_logo.svg`. Professional sharing platforms (specifically LinkedIn) do not support SVG format for rich card previews.
- **Action Needed:** Update the `ogImage` to reference a high-quality raster format, such as Terese's professional profile photo (`assets/profile_pic.jpg`).

### 4. Rich Schema.org Markup
- **Status:** The JSON-LD Person schema in `lib/main.dart` is basic.
- **Action Needed:** Enrich the `Person` schema with properties like `image`, `gender`, `description`, and education (`alumniOf`: "Lund University") to improve Google's rich search card and Knowledge Panel compilation index.
