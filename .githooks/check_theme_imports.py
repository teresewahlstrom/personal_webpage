#!/usr/bin/env python3
"""
Check staged Dart files under packages/tw_primitives/lib/src/theme do not import from outside that folder.

This script is intended to be run from a pre-commit hook. It inspects the staged content
so it works even before files are committed.
"""
import os
import re
import subprocess
import sys

def run(cmd):
    return subprocess.check_output(cmd, shell=True, text=True).strip()

def get_repo_root():
    try:
        return run('git rev-parse --show-toplevel')
    except Exception:
        return os.getcwd()


def get_main_package_name(repo_root):
    pubspec = os.path.join(repo_root, 'pubspec.yaml')
    if not os.path.exists(pubspec):
        return None
    try:
        with open(pubspec, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line.startswith('name:'):
                    # naive parse: name: my_name
                    parts = line.split(':', 1)
                    if len(parts) == 2:
                        return parts[1].strip()
    except Exception:
        return None
    return None

def staged_files():
    out = run('git diff --cached --name-only --diff-filter=ACM')
    if not out:
        return []
    return out.splitlines()

IMPORT_RE = re.compile(r"^\s*(?:import|export)\s+['\"]([^'\"]+)['\"]")


def is_theme_container_scrollbar_exception(path, resolved, repo_root):
    """Allow theme/container files to depend on the public scrollbar barrel."""
    rel_path = os.path.normpath(path)
    container_prefix = os.path.normpath('packages/tw_primitives/lib/src/theme/container') + os.sep
    if not rel_path.startswith(container_prefix):
        return False

    allowed = os.path.normpath(
        os.path.join(repo_root, 'packages', 'tw_primitives', 'lib', 'scrollbar.dart'),
    )
    return os.path.normpath(resolved) == allowed

def get_staged_file_contents(path):
    # Use git show to read the staged version
    try:
        return run(f'git show :"{path}"')
    except subprocess.CalledProcessError:
        # file might be new/untracked in index; fallback to reading from disk
        with open(path, 'r', encoding='utf-8') as f:
            return f.read()

def resolve_package_path(repo_root, package_uri):
    # package:tw_primitives/... -> packages/tw_primitives/lib/...
    if package_uri.startswith('package:'):
        _, rest = package_uri.split(':', 1)
        # If this is an import from our package, resolve it to the local file path
        if rest.startswith('tw_primitives/'):
            return os.path.normpath(os.path.join(repo_root, 'packages', 'tw_primitives', 'lib', rest[len('tw_primitives/'):]))
        # For other packages (e.g. package:flutter/...), we don't resolve to repo files;
        # treat them as external and allow them.
        return None
    return None

def main():
    repo_root = get_repo_root()
    theme_dir = os.path.normpath(os.path.join(repo_root, 'packages', 'tw_primitives', 'lib', 'src', 'theme'))

    violations = []

    for path in staged_files():
        # Only check Dart files in the theme folder
        norm = os.path.normpath(path)
        if not norm.startswith(os.path.normpath('packages/tw_primitives/lib/src/theme') + os.sep):
            continue
        if not norm.endswith('.dart'):
            continue

        content = get_staged_file_contents(path)
        for lineno, line in enumerate(content.splitlines(), start=1):
            m = IMPORT_RE.match(line)
            if not m:
                continue
            target = m.group(1)
            # Allow dart: imports
            if target.startswith('dart:'):
                continue
            # Resolve package: imports. Allow external packages (package:flutter etc.).
            if target.startswith('package:'):
                _, rest = target.split(':', 1)
                pkg = rest.split('/', 1)[0]

                # If this is an import from our package, resolve and ensure it's inside theme_dir
                if pkg == 'tw_primitives':
                    resolved = resolve_package_path(repo_root, target)
                    if is_theme_container_scrollbar_exception(path, resolved, repo_root):
                        continue
                    try:
                        if not os.path.commonpath([resolved, theme_dir]) == theme_dir:
                            violations.append((path, lineno, target, f'resolves to {os.path.relpath(resolved, repo_root)}'))
                    except Exception:
                        violations.append((path, lineno, target, f'resolves to {os.path.relpath(resolved, repo_root)}'))
                    continue

                # Disallow imports from other local workspace packages or the main app package
                main_pkg = get_main_package_name(repo_root)
                other_pkg_dir = os.path.join(repo_root, 'packages', pkg)
                if pkg == main_pkg or os.path.isdir(other_pkg_dir):
                    violations.append((path, lineno, target, 'imports local workspace package or main app'))
                    continue

                # Otherwise it's an external pub package (e.g., package:flutter) -> allow
                continue
            # Relative import
            # Join with file's directory
            file_dir = os.path.dirname(os.path.join(repo_root, path))
            resolved = os.path.normpath(os.path.join(file_dir, target))
            if is_theme_container_scrollbar_exception(path, resolved, repo_root):
                continue
            # If it's a package: style or absolute file, ensure it is inside theme_dir
            if not os.path.commonpath([resolved, theme_dir]) == theme_dir:
                violations.append((path, lineno, target, f'resolves to {os.path.relpath(resolved, repo_root)}'))

    if violations:
        print('\nTheme import policy violation: files under packages/tw_primitives/lib/src/theme must only import from inside that folder.')
        for path, lineno, target, reason in violations:
            print(f'- {path}:{lineno}: {target}  ({reason})')
        print('\nTo enable the hook for local development run:')
        print('  npm run install:git-hooks')
        sys.exit(1)

    return 0

if __name__ == '__main__':
    sys.exit(main())
