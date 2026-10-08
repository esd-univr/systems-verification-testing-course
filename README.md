# Systems Verification & Testing

Public course workspace for the Systems Verification & Testing course.

This repository is configured to run in GitHub Codespaces using the course HDL toolchain.

## Open in GitHub Codespaces

1. Sign in to GitHub.
2. Open this repository.
3. Select **Code** -> **Codespaces** -> **Create codespace on main**.
4. Wait for the environment to start.

The Codespace uses:

`ghcr.io/esd-univr/hdl-course-toolchain:latest`

The development container opens as the non-root `student` user. No local installation of the HDL toolchain is required.

## Repository structure

```text
.devcontainer/   Codespaces / Dev Container configuration
lesson-01/       Lesson 01 — RTL modelling
```

Only released lessons are published here.

## Updating an existing Codespace

For newly published lesson material or other repository changes:

```bash
git pull --ff-only
```

If `.devcontainer/` changes, pull first and then run **Codespaces: Rebuild Container** from the VS Code Command Palette.

## Restarting Lesson 01

From inside `lesson-01/`:

```bash
make clean
git restore .
```

This restores tracked Lesson 01 files to the current checked-out commit.
