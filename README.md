# Systems Verification & Testing

Public student workspace for the Systems Verification & Testing course.

Released lesson material is published progressively in this repository. The same
checkout can be used either in GitHub Codespaces or locally through the shared
HDL course toolchain.

## Option 1 — GitHub Codespaces

1. Sign in to GitHub.
2. Open this repository.
3. Select **Code** -> **Codespaces** -> **Create codespace on main**.
4. Wait for the environment to start.

The Codespace uses:

`ghcr.io/esd-univr/hdl-course-toolchain:latest`

The development container opens as the non-root `student` user with the HDL
toolchain already on `PATH`. No local installation of the toolchain or Docker
is required.

From the repository root:

```bash
cd lesson-01
make help
```

## Option 2 — Local machine with HDL Course Toolchain

Docker or Docker Desktop must already be installed and running.

Clone this repository:

```bash
git clone https://github.com/esd-univr/systems-verification-testing-course.git
cd systems-verification-testing-course
```

Install the course launcher once:

```bash
curl -fsSL https://github.com/esd-univr/hdl-course-toolchain/releases/latest/download/install.sh | bash
```

Then, **from the root of this repository**, enter the course environment:

```bash
hdl-toolchain --workspace . -- zsh -l
```

The repository root is mounted inside the container as `/work`. Stay in this
shell while working on the lessons. For example:

```bash
cd lesson-01
make help
```

The launcher obtains the qualified
`ghcr.io/esd-univr/hdl-course-toolchain:latest` image automatically and keeps
generated files in this repository workspace.

## Repository structure

```text
.devcontainer/   Codespaces / Dev Container configuration
lesson-01/       Lesson 01 — RTL modelling
```

Only released lessons are published here. New `lesson-XX/` directories are
added progressively during the course.

## Getting new lesson material

If you already have the repository, update it from its root:

```bash
git pull --ff-only
```

This is enough when new lesson files are published or existing course material
is updated.

If `.devcontainer/` changes in a Codespace, pull first and then run
**Codespaces: Rebuild Container** from the VS Code Command Palette.

## Restarting an exercise

To discard your changes to the tracked files of Lesson 01 and start again:

```bash
cd lesson-01
make clean
git restore .
```

This removes generated build output and restores the tracked Lesson 01 files to
the current checked-out version.

To reset the entire repository checkout instead, return to the repository root
and use Git deliberately on the files you want to restore.
