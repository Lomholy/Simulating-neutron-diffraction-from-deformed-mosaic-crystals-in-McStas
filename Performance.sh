# First, erase the current directory, to make fresh data

mosaicity=6 # Using mono_bent as a mosaic crystal at different bending radii
# rm -r ./data/timing_ncrysts*
# rm -r ./data/perf_run_*
# for lamella in 1 10 100 200 250 300 350 375 400 425 450 475 500
# do
#     mcrun -c Performance.instr -d data/perf_run_${lamella}_1\
#      mos=${mosaicity} ncrysts=${lamella}>data/timing_ncrysts_${lamella}_1.txt&
#     mcrun -c Performance.instr -d data/perf_run_${lamella}_2\
#      mos=${mosaicity} ncrysts=${lamella}>data/timing_ncrysts_${lamella}_2.txt&
#     mcrun -c Performance.instr -d data/perf_run_${lamella}_3\
#      mos=${mosaicity} ncrysts=${lamella}>data/timing_ncrysts_${lamella}_3.txt&
#     wait
# done
# wait
#
# # Then run the 10 lamella case for different ncounts
# for neutrons in 100000 1000000 3000000 5000000 7000000 9000000 13000000 16000000 20000000 25000000 32000000 40000000 50000000 64000000 80000000 100000000
#   do 
#     mcrun -c Performance.instr -n $neutrons -d data/perf_run_10_ncount_$neutrons\
#       mos=${mosaicity} ncrysts=10>data/timing_ncount_${neutrons}.txt&
#   done
# wait
#
# # Then do mpi scan and show that speed is almost constant when spreading out
# rm -r ./data/timing_mpi*
# rm -r ./data/mpi_r*
#
# for mpi in $(seq 1 15); 
# do
#   ncount=$(( 40000000 ))  # Bash integer arithmetic (no scientific notation)
#
#   mcrun -c Performance.instr \
#         --mpi="${mpi}" \
#         -d "data/mpi_run_${mpi}" \
#         mos="${mosaicity}" \
#         ncrysts=10 \
#         -n "${ncount}" > "data/timing_mpi_${mpi}.txt"
# done
#
#
#
#

# Perform performance testing against NCrystal.

rm -r ./data/timing_ncrystal*
rm -r ./data/timing_mono_ben*
# NCRYSTAL GE5111
for i in $(seq 1 50);
do
  start=`date +%s.%N`
  mcrun Performance.instr -n1e7\
  -d data/timing_ncrystal_${i}\
  use_other_mono=1 > "dummy.txt" # 
  end=`date +%s.%N`
  runtime=$( echo "$end - $start" | bc -l )
  echo "${runtime}" >> "data/timing_ncrystal.txt"
done
#
# MONOCHROMATOR BENT GE511 
for i in $(seq 1 50);
do
  start=`date +%s.%N`
  mcrun Performance.instr -n1e7\
  -d data/timing_mono_ben_${i}\
  use_other_mono=0 > "dummy.txt" # 
  end=`date +%s.%N`
  runtime=$( echo "$end - $start" | bc -l )
  echo "${runtime}" >> "data/timing_mono_ben.txt"
done

# NCRYSTAL CU111
for i in $(seq 1 50);
do
  start=`date +%s.%N`
  mcrun Performance.instr -n1e7\
  -d data/timing_ncrystal_cu111${i}\
  dhkl=2.087063\
  config=1\
  cut_angle=0\
  use_other_mono=1 > "dummy.txt" # 
  end=`date +%s.%N`
  runtime=$( echo "$end - $start" | bc -l )
  echo "${runtime}" >> "data/timing_ncrystal_cu111.txt"
done

# MONOCHROMATOR BENT CU111
for i in $(seq 1 50);
do
  start=`date +%s.%N`
  mcrun Performance.instr -n1e7\
  -d data/timing_mono_ben_cu111${i}\
  crystal="Cu111" dhkl=2.087063\
  cut_angle=0\
  use_other_mono=0 > "dummy.txt" # 
  end=`date +%s.%N`
  runtime=$( echo "$end - $start" | bc -l )
  echo "${runtime}" >> "data/timing_mono_ben_cu111.txt"
done
#
# mcrun Performance.instr config=1 dhkl=2.087063 use_other_mono=1 cut_angle=0 --autoplot
