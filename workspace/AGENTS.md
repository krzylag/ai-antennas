# Antenna Simulation Workspace

This directory is the writable project workspace. Create all source files, NEC inputs, plots, reports, and simulation outputs here. Do not write project output outside `/workspace`.

Use separate subdirectory under `/workspace` for each project.

## Task Router

- For antenna mechanical design, construction instructions, material selection, element dimensions, mounting, or a bill of materials, first read `AGENTS.PARTS.md`. Use only the listed available parts unless the user explicitly authorizes additional materials.
- For electromagnetic modelling and simulation, use `xnec2c` or `nec2c` as described below. Save every input and output in dedicated project folder under `/workspace`.
- For 3D-printable antenna parts, create parametric source files, STL files, slicer outputs, and reports under the project's `/workspace` directory. Check the printer build volume and material/RF constraints in the project instructions before designing parts.

## CAD, meshes, and 3D printing

The container includes `openscad` for parametric CAD and STL export, `admesh` for STL inspection/repair, and `prusa-slicer` for slicing. Example OpenSCAD export:

```bash
openscad -o /workspace/<project>/<part>.stl /workspace/<project>/<part>.scad
admesh -c /workspace/<project>/<part>.stl
```

Use `prusa-slicer --help` to check CLI options before slicing. `rsvg-convert` converts SVG files to PNG or PDF; ImageMagick (`convert`, `identify`) is available for image conversion and inspection.

Python packages are split between two environments:

- `/opt/cad/bin/python` has `numpy`, `trimesh`, and `manifold3d` for mesh geometry, boolean operations, and STL export.
- System `python3` has `numpy`, `matplotlib`, and Pillow (`PIL`) for numerical work, plots, and image previews.

Use the preinstalled tools and environments; do not install packages into `/workspace`. Save generated CAD files, meshes, previews, and print reports in the relevant project directory. Validate each STL with `admesh` and check its dimensions against the printer build volume before considering it ready to print.

`xnec2c` is installed in the container and may be launched from the shell. It is the graphical X11 front-end for NEC2 antenna simulations; the underlying solver is also available as `nec2c`. Prefer batch calls to `nec2c` for automated runs. Keep each `.nec` input and its generated output in project's folder, so the host user can inspect them.

Some antenna simulations can run for more than ten minutes. Do not impose a short timeout on `xnec2c` or `nec2c`; wait for completion unless the user asks to stop it.

When `local-deepseek/qwen-coder` is selected, it supports OpenCode tool calls. The other local models are text-only; use them for analysis or generation rather than autonomous tool use.
