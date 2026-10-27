# Antenna Simulation Workspace

This directory is the writable project workspace. Create all source files, NEC inputs, plots, reports, and simulation outputs here. Do not write project output outside `/workspace`.

Use separate subdirectory under `/workspace` for each project.

## Task Router

- For antenna mechanical design, construction instructions, material selection, element dimensions, mounting, or a bill of materials, first read `AGENTS.PARTS.md`. Use only the listed available parts unless the user explicitly authorizes additional materials.
- For electromagnetic modelling and simulation, use `xnec2c` or `nec2c` as described below. Save every input and output in dedicated project folder under `/workspace`.

`xnec2c` is installed in the container and may be launched from the shell. It is the graphical X11 front-end for NEC2 antenna simulations; the underlying solver is also available as `nec2c`. Prefer batch calls to `nec2c` for automated runs. Keep each `.nec` input and its generated output in project's folder, so the host user can inspect them.

Some antenna simulations can run for more than ten minutes. Do not impose a short timeout on `xnec2c` or `nec2c`; wait for completion unless the user asks to stop it.

When `local-deepseek/qwen-coder` is selected, it supports OpenCode tool calls. The other local models are text-only; use them for analysis or generation rather than autonomous tool use.
