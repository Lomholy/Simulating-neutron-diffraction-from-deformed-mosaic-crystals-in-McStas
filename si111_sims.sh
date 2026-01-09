rm -r ./data/si11*


#!/usr/bin/env bash
set -euo pipefail

# Function for floating point multiplication using awk
mul() { awk -v a="$1" -v b="$2" 'BEGIN { printf("%.6f\n", a*b) }'; }


for mos in 6 12 24 48 96; do
  # Compute DeltaBragg bounds: ±0.2 * mos (floating point)
  DeltaBragg_low=$(mul -0.04 "$mos")
  DeltaBragg_high=$(mul 0.04 "$mos")

  echo "mos=${mos} -> DeltaBragg=[${DeltaBragg_low}, ${DeltaBragg_high}]"

  # ---- FLAT profile (long run) ----
  mcrun -c Showcase.instr \
    -d data/si111_flat_profile${mos} \
    Bending_radius=1000 \
    -n 1e7 \
    mos=${mos} crystal="Si111" dhkl=3.13536 cut_angle=0 lam0=2.4 slit_width=0.0001 &

  # ---- FLAT rocking scan (bounded by computed DeltaBragg) ----
  mcrun -c -N 100 --scan_split=15 Showcase.instr \
    -d data/si111_flat_rocking${mos} \
    Bending_radius=1000 \
    DeltaBragg=${DeltaBragg_low},${DeltaBragg_high} \
    -n 1e5 \
    mos=${mos} crystal="Si111" dhkl=3.13536 cut_angle=0 lam0=2.4 slit_width=0.0001 
  wait
done

for mos in 3 6 12 24 48; do
  # Compute DeltaBragg bounds: ±0.2 * mos (floating point)
  DeltaBragg_low=$(mul -0.08 "$mos")
  DeltaBragg_high=$(mul 0.08 "$mos")
  # ---- BENT profile (long run)
  # NOTE: Your original had Bending_radius=3 here (likely intentional for "bent").
  # Keep 3 if that's your bent profile radius; change to 1000 if not.
  mcrun -c Showcase.instr \
    -d data/si111_bent_profile${mos} \
    Bending_radius=3 \
    -n 1e7 \
    mos=${mos} crystal="Si111" dhkl=3.13536 cut_angle=0 lam0=2.4 slit_width=0.0001 &

  # ---- BENT rocking scan (bounded by computed DeltaBragg)
  mcrun -c -N 100 --scan_split=15 Showcase.instr \
    -d data/si111_bent_rocking${mos} \
    Bending_radius=3 \
    DeltaBragg=${DeltaBragg_low},${DeltaBragg_high} \
    -n 1e5 \
    mos=${mos} crystal="Si111" dhkl=3.13536 cut_angle=0 lam0=2.4 slit_width=0.0001 &

  # Wait for this iteration's four jobs to finish before moving to next 'mos'
  wait
done

# Final synchronization (redundant since we wait in-loop, but harmless)
wait


