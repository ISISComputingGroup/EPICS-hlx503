#include "seqPVmacros.h"

program hlx503 ("P")


PV(int, recondensing_sp, "{P}RECONDENSING:SP", Monitor);
PV(int, recondensing, "{P}RECONDENSING", NoMon);
PV(int, part, "{P}RECONDENSE:PART", NoMon);
PV(int, timed_out, "{P}RECONDENSE:TIMED_OUT", NoMon);
PV(int, skipped_sp, "{P}RECONDENSE:SKIPPED:SP", Monitor);
PV(int, skipped, "{P}RECONDENSE:SKIPPED", NoMon);
PV(float, post_condense_temp_sp, "{P}RECONDENSE:TEMP:SP:RBV", Monitor);
PV(float, temp_he3pot_sp, "{P}TEMP:HE3POT:SP", Monitor);


ss recondense {

    state init {
        entry {
            PVPUT(recondensing_sp, 0);
            PVPUT(recondensing, 0);
            PVPUT(part, 5);
            PVPUT(timed_out, 0);
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
        }
        when (recondensing_sp == 1) {
            PVPUT(recondensing, 1);
        } state setup
    }

    state setup {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(part, 0);
        }
        when (skipped_sp == 1) {
            PVPUT(skipped, 1);
        } state part1
    }

    state part1 {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(part, 1);
        }
        when (skipped_sp == 1) {
            PVPUT(skipped, 1);
        } state part2
    }

    state part2 {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(part, 2);
        }
        when (skipped_sp == 1) {
            PVPUT(skipped, 1);
        } state part3
    }

    state part3 {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(part, 3);
        }
        when (skipped_sp == 1) {
            PVPUT(skipped, 1);
        } state finish
    }

    state finish {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(part, 4);
        }
        when() {} state finish
    }

}
