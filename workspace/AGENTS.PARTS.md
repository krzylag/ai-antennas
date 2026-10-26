# Available Antenna Parts and Equipment

Use this inventory for antenna designs, construction plans, and bills of materials. Dimensions below are physical conductor dimensions unless stated otherwise.

## Conductors

| ID | Item | Material | Dimensions | Notes |
| --- | --- | --- | --- | --- |
| AL-TUBE-6X1 | Tube | Aluminium | 6 mm outside diameter, 1 mm wall thickness. Max element length 1 m. | Hollow tube; 4 mm inside diameter. |
| AL-ROD-5 | Rod | Aluminium | 5 mm diameter | Solid round rod. Max element length is 2000 mm |
| AL-ROD-4 | Rod | Aluminium | 4 mm diameter | Solid round rod. Max element length 1000 mm |
| CU-YDY-1.8 | Installation wire YDY | Copper | 1.8 mm conductor diameter. Max element length is 1000 mm | Use as a flexible wire conductor. Preferred for coils, avoid using for active elements. |
| CU-YDY-2.5 | Installation wire YDY | Copper | 2.5 mm conductor diameter. Max element length is 1000 mm | Use as a flexible wire conductor. Preferred for coils, avoid using for active elements. |

## Equipment

| ID | Item | Capability | Notes |
| --- | --- | --- | --- |
| 3DP-CREALITY-SERMOON-V1-PRO | Creality Sermoon V1 Pro | 3D printer | Available for insulating spacers, element clamps, supports, and enclosures. Validate temperature, UV, and mechanical suitability of the selected filament. |
| MEAS-NANOVNA-H4 | NanoVNA H4 | Vector network analyser | Available for measuring antenna impedance, SWR, and tuning results. |

## Design Rules

- State which inventory IDs are used in every construction plan and bill of materials.
- Model aluminium tubing and rods as aluminium conductors with the listed outside diameter. For NEC geometry, use the outside diameter as the wire diameter unless a more suitable segmented model is required.
- Treat YDY wire diameter as the electrical conductor diameter. Do not assume insulation properties, connector types, filament type, fasteners, coaxial cable, baluns, or weatherproofing materials are available unless the user provides them.
