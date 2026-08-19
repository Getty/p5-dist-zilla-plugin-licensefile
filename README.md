# Dist-Zilla-Plugin-LicenseFile

Ship the repository's committed `LICENSE`, and keep it honest.

## Why

Dist::Zilla generates `LICENSE` into the build. The file ends up in the tarball
on CPAN, but never in the repository — and hosting platforms only look at the
repository. GitHub, Gitea and Forgejo all detect and link a licence from a
committed `LICENSE` file, so a distribution built the default way shows up as
unlicensed on its own project page.

Committing the file fixes that, and introduces a quieter problem: nothing
connects the committed text to the `license` in `dist.ini` any more. Switch the
licence and the repository keeps serving the old one, with no warning and no
failing build.

This distribution is both halves of the fix — a command that writes the file,
and a plugin that refuses to build when it is missing or stale.

## Installation

```bash
cpanm Dist::Zilla::Plugin::LicenseFile
```

## Usage

`@Basic`'s `License` plugin has to go, or the build aborts with
`attempt to add LICENSE multiple times`:

```ini
[@Filter]
-bundle = @Basic
-remove = License

[LicenseFile]
```

Then write the file once and commit it:

```bash
dzil genlicense
git add LICENSE && git commit -m 'Ship the LICENSE file in the repository'
```

From here on `dzil build` compares the committed file against the distribution
metadata and stops if they have drifted apart:

```
[LicenseFile] LICENSE is out of date: it no longer matches the license in
dist.ini. Run 'dzil genlicense' and commit the file
```

`dzil genlicense` is idempotent, so the fix is always the same two commands.

### What ends up in the file

The bare licence text — not `Software::License`'s `fulltext`, which is what
`[License]` writes into the build. `fulltext` prefixes the licence with a
copyright notice, and that prefix alone is enough to stop GitHub's detector:
the same repository reports `NOASSERTION` with `fulltext` and `Artistic-2.0`
with the bare text. Since detection is the whole point of committing the file,
the bare text wins. The copyright notice still reaches the tarball via the
`LICENSE AND COPYRIGHT` POD section, and the holder and year via `META.json`.

### Migrating an existing distribution

The first build after adding the plugin is what tells you the file is missing.
If that is inconvenient — a repository full of distributions to convert, a CI
run you do not want to break yet — downgrade the check to a warning while you
work through them:

```ini
[LicenseFile]
required = 0
```

## Development

```bash
prove -l t/     # run tests
dzil build      # build distribution
dzil release    # release to CPAN
```

## Author

Torsten Raudssus <getty@cpan.org>

## License

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
