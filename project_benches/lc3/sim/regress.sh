#!/bin/bash
# Compiles the LC3 bench once, runs the test suite in parallel on the
# compiled design, merges the coverage with the test plan and writes the
# coverage summary.
#
#   bash regress.sh            # incremental compile, 4 simulations at once
#   CLEAN=1 bash regress.sh    # full recompile first
#   JOBS=1  bash regress.sh    # one simulation at a time
#
# Results are written to ../results:
#   compile.log           compile/optimize transcript
#   <test>.log            transcript of each simulation
#   <test>.ucdb           coverage of each simulation
#   lc3_merged.ucdb       merged coverage (with the test plan)
#   coverage_report.txt   coverage summary

cd "$(dirname "$0")" || exit 1

# test:seed
SUITE="lc3_closure_test:1 lc3_alu_test:1 lc3_mem_test:2 lc3_ctrl_test:3"
RESULTS=../results
JOBS=${JOBS:-4}

START=$(date +%s)
[ -n "$CLEAN" ] && make -s clean
rm -rf "$RESULTS"
mkdir -p "$RESULTS"

echo "compiling ..."
if ! make -s compile > "$RESULTS/compile.log" 2>&1; then
  echo "COMPILE FAILED -- see $RESULTS/compile.log"
  grep -E "\*\* (Error|Fatal)" "$RESULTS/compile.log" | head -20
  exit 1
fi
COMPILED=$(date +%s)

for entry in $SUITE; do
  test=${entry%%:*}
  seed=${entry##*:}
  while [ "$(jobs -rp | wc -l)" -ge "$JOBS" ]; do wait -n; done
  echo "running $test (seed $seed) ..."
  make -s sim TEST="$test" SEED="$seed" QUIET=1 > /dev/null 2>&1 &
done
wait
SIMULATED=$(date +%s)

STATUS=0
make -s merge  > "$RESULTS/merge.log" 2>&1 || STATUS=1
make -s report > /dev/null 2>&1 || STATUS=1
END=$(date +%s)

echo
echo "================ LC3 REGRESSION SUMMARY ================"
printf "%-18s %-7s %-7s %-7s %-12s %-12s %s\n" TEST RESULT ERRORS INSTRS STREAM_COV PIPELINE_COV SIM_TIME
for entry in $SUITE; do
  test=${entry%%:*}
  log="$RESULTS/$test.log"
  result=FAILED
  grep -q "TEST PASSED" "$log" 2>/dev/null && result=PASSED
  [ "$result" = PASSED ] || STATUS=1
  errors=$(grep -m1 "UVM_ERROR :" "$log" 2>/dev/null | awk '{print $NF}')
  count=$(grep -m1 "instructions delivered to the LC3" "$log" 2>/dev/null | awk '{print $NF}')
  cover=$(grep -m1 "INSTRUCTION COVERAGE (this test)" "$log" 2>/dev/null | awk '{print $NF}')
  pcover=$(grep -m1 "BEHAVIOUR COVERAGE (this test)" "$log" 2>/dev/null | awk '{print $NF}')
  simtime=$(grep "Time: " "$log" 2>/dev/null | tail -1 | sed 's/.*Time: *\([0-9.]* *[a-z]*\).*/\1/')
  printf "%-18s %-7s %-7s %-7s %-12s %-12s %s\n" "$test" "$result" "${errors:-?}" "${count:-?}" "${cover:-?}" "${pcover:-?}" "${simtime:-?}"
done
echo "--------------------------------------------------------"
echo "merged coverage : $(grep -i -m1 'TOTAL COVERGROUP COVERAGE' "$RESULTS/coverage_report.txt" 2>/dev/null || echo 'see ../results/coverage_report.txt')"
echo "wall-clock time : $((END - START)) s  (compile $((COMPILED - START)) s, simulations $((SIMULATED - COMPILED)) s, merge+report $((END - SIMULATED)) s)"
echo "results         : $(cd "$RESULTS" && pwd)"
[ "$STATUS" = 0 ] && echo "REGRESSION PASSED" || echo "REGRESSION FAILED"
exit $STATUS
