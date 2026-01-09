# First, erase the current directory, to make fresh data
rm -r ./data/*



mosaicity=0 # Perfect crystal
for radius in 3 5 10
do
    mcrun -c Showcase.instr -d data/X_profile_radius_${radius}_mos_${mosaicity}\
     Bending_radius=$radius mos=${mosaicity} linDetWidth=0.005 &
    mcrun -c Showcase.instr -n 1e7 -d data/X_profile_radius_${radius}_mos_${mosaicity}_wavelength\
     Bending_radius=$radius mos=${mosaicity} linDetWidth=0.005 dlambda=1e+3 &
    mcrun -c -N 100 --scan_split 15 Showcase.instr\
     -d data/Rocking_curve_radius_${radius}_mos_${mosaicity} -n 1e+5 \
     Bending_radius=$radius mos=${mosaicity} DeltaBragg=-0.2,0.2
done

wait

#
mosaicity=6 # Using mono_bent as a mosaic crystal at different bending radii
for radius in 3 5 10 1000
do
    mcrun -c Showcase.instr -d data/X_profile_radius_${radius}_mos_${mosaicity}\
     Bending_radius=$radius mos=${mosaicity} &

    mcrun -c -N 100 --scan_split=15 Showcase.instr\
     -d data/Rocking_curve_radius_${radius}_mos_${mosaicity} -n 1e+5\
     Bending_radius=$radius mos=${mosaicity} DeltaBragg=-0.2,0.2
done
wait

mcrun Showcase.instr --scan_split=15 -c -d data/X_profile_thickness -n 1e+5\
 Bending_radius=1000 mos=6 -N 200 cryst_thickness=0.000001,0.0125 anisotropy=0 # Scan thickness

mcrun -c -N 200 --scan_split=15 Showcase.instr\
 -d data/Rocking_curve_transfer -n 1e+5\
 Bending_radius=1000 mos=6 anisotropy=0 DeltaBragg=-0.2,0.2

wait

#
#
mcrun Showcase.instr -c -d data/X_profile_NCrystal use_other_mono=2 # Finally run the N crystal simulations

mcrun -c -N 100 --scan_split 15 Showcase.instr -d data/Rocking_curve_NCrystal\
 -n 1e+5 DeltaBragg=-0.2,0.2 use_other_mono=2

wait
#
# Run the 1000 R simulations for Cu311:

mcrun -c -N 100 --scan_split=15 Showcase.instr -d data/Rocking_curve_flat_mos_6_Cu -n 1e+5 Bending_radius=1000 mos=6 DeltaBragg=-0.2,0.2 crystal="Cu311" dhkl=1.089933
mcrun Showcase.instr --scan_split=15 -c -d data/X_profile_thickness_Cu -n 1e+5\
 Bending_radius=1000 mos=6 -N 200 cryst_thickness=0.000001,0.0125 anisotropy=0 crystal="Cu311" dhkl=1.089933 # Scan thickness
wait
# prim ext = 1, 0.99, 0.45, 0.04
rm -r ./data/dom_scan*
mosaicity=6
for dom_thick in 0.001 10 50 100 500 1000
do
  mcrun -c -N 100 --scan_split=15 Showcase.instr -d data/dom_scan_mos${dom_thick}\
    Bending_radius=10 domain_thick=${dom_thick}\
    DeltaBragg=-0.2,0.2 -n 1e+5 mos=${mosaicity} # crystal="Si111" dhkl=3.13536
done

mosaicity=0
for dom_thick in 0.001 10 50 100 500 1000
do
  mcrun -c -N 100 --scan_split=15 Showcase.instr -d data/dom_scan_per${dom_thick}\
    Bending_radius=10 domain_thick=${dom_thick}\
    DeltaBragg=-0.2,0.2 -n 1e+5 mos=${mosaicity} # crystal="Si111" dhkl=3.13536
done
