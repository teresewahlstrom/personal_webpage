# personal_webpage (Flutter Web)

This repository serves a Flutter Web version of the personal webpage.

## Local Development

```bash
flutter pub get
flutter run -d chrome
```

## Build

```bash
flutter build web
```

Build output is generated at:

`build/web`

## Cloudflare Pages (GitHub Integration)

Use these settings in Cloudflare Pages:

- Root directory: `/`
- Build command: `bash cloudflare-pages-build.sh`
- Build output directory: `build/web`

Backward-compatibility note:
- If your Pages project is still set to `npm run deploy`, this repository supports it via `package.json`.
- If your Pages output directory is still `dist`, the build script mirrors `build/web` to `dist`.
