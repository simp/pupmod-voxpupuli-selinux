# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this module is

`simp-vox_selinux` is a SIMP-namespaced fork of [voxpupuli/puppet-selinux](https://github.com/voxpupuli/puppet-selinux). It manages SELinux mode/type, modules, booleans, fcontexts, ports, and permissive types. The fork exists only to re-namespace `selinux` → `vox_selinux` so SIMP consumers can migrate off the legacy SIMP `selinux` module without colliding with the upstream Vox Pupuli module.

**Critical constraint:** This fork should not deviate from upstream behavior outside of the namespace rename. Bug fixes and features belong upstream — open PRs against `voxpupuli/puppet-selinux` first, then port them here. The eventual plan is for SIMP users to migrate directly to the upstream module and retire this fork.

## The renamespacing mechanism

`simp_vox_migration.sh` is the script that was used to convert an upstream import into this fork. It is the source of truth for what got renamed:

- Module name: `puppet/selinux` → `simp/vox_selinux`
- Puppet class/define namespace: `selinux::*` / `Selinux::*` → `vox_selinux::*` / `Vox_selinux::*`
- Hiera data keys, spec `describe` blocks, and `contain_*` matchers are rewritten the same way
- `metadata.json` `name`, `summary`, `source`, `project_page`, `issues_url` are reset to SIMP values

When pulling in changes from upstream, re-running (or re-applying the spirit of) this script is how you keep the namespace consistent. Note that Ruby code under `lib/` (custom types, providers, facts) is **not** renamespaced — those remain `Puppet::Type::Selinux_*` etc., matching upstream.

## Common commands

```bash
bundle install
bundle exec rake spec        # rspec-puppet unit tests
bundle exec rake lint        # puppet-lint
bundle exec rake syntax
bundle exec rake reference   # regenerate REFERENCE.md from puppet-strings
./test-acceptance-with-vagrant   # full acceptance matrix via Beaker+Vagrant
```

Run a single spec file: `bundle exec rspec spec/classes/init_spec.rb`

Pin Puppet version for `bundle install`: `PUPPET_VERSION='~> 7.0' bundle install` (default in `Gemfile` is `~> 6.0`).

## Layout notes specific to this module

- `manifests/init.pp` — the `vox_selinux` class; takes optional hashes (`boolean`, `fcontext`, `module`, `permissive`, `port`, `exec_restorecon`) and fans them out via `create_resources`.
- `data/` — Hiera data with per-OS package names (the class requires several params with no defaults; defaults come from `data/os/<family>.yaml`).
- `lib/facter/`, `lib/puppet/`, `lib/puppet_x/` — custom facts, types, providers (un-renamespaced; mirror upstream).
- `.fixtures.yml` pulls `puppetlabs-stdlib` and `puppetlabs-selinux_core` for tests.

## Upstream-tracking workflow

1. Identify the upstream commit/release you want to pull in.
2. Apply it on top of this branch (cherry-pick, merge, or re-import).
3. Re-run the renamespacing transforms from `simp_vox_migration.sh` against any newly-introduced files — pay attention to the `vox_vox` / `Vox_vox` cleanup lines, which guard against double-substitution.
4. Update `metadata.json` version and regenerate `REFERENCE.md` and `CHANGELOG.md`.

If you find yourself wanting to fix a bug only here, stop — fix it upstream and pull it back in instead.
