program hlx503 ("P")

#include "seqPVmacros.h"

PV(int, recondensing_sp, "{P}RECONDENSING:SP", Monitor);
PV(int, recondensing, "{P}RECONDENSING", NoMon);
PV(int, part, "{P}RECONDENSE:PART", NoMon);
PV(int, timed_out, "{P}RECONDENSE:TIMED_OUT", NoMon);
PV(int, skipped_sp, "{P}RECONDENSE:SKIPPED:SP", Monitor);
PV(int, skipped, "{P}RECONDENSE:SKIPPED", NoMon);
PV(int, cancelled_sp, "{P}RECONDENSE:CANCELLED:SP", Monitor);
PV(int, cancelled, "{P}RECONDENSE:CANCELLED", NoMon);
PV(float, post_condense_temp_sp, "{P}RECONDENSE:TEMP:SP:RBV", Monitor);
PV(float, temp_he3pot_sp, "{P}TEMP:HE3POT:SP", Monitor);
PV(int, adjust_pids_sp, "{P}ADJUST_PIDS:SP", NoMon);
PV(int, mode_htr_sp, "{P}MODE:HTR:SP", NoMon);
PV(int, heater_percent_sp, "{P}HEATERP:SP", NoMon);
PV(int, temp_sp, "{P}TEMP:SP", NoMon);
PV(string, ctrlchannel_sp, "{P}CTRLCHANNEL:SP", NoMon);

ss recondense {

    state init {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(cancelled_sp, 0);
            PVPUT(cancelled, 0);
            PVPUT(timed_out, 0);
        }
        when () {} state not_recondensing
    }

    state not_recondensing {
        entry {
            PVPUT(recondensing_sp, 0);
            PVPUT(recondensing, 0);
            PVPUT(part, 0);
        }
        when (recondensing_sp == 1) {
            PVPUT(recondensing, 1);
        } state part1
    }

    state part1 {
        entry {
            // Reset status PVs
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(cancelled_sp, 0);
            PVPUT(cancelled, 0);
            PVPUT(part, 1);
            PVPUT(timed_out, 0);
            // Disable use of PIDs from tpar files
            PVPUT(adjust_pids_sp, 0);
            // Set heater to manual, 0% and temp setpoint to 0K
            PVPUT(mode_htr_sp, 0);
            PVPUT(heater_percent_sp, 0);
            PVPUT(temp_sp, 0);
            // Set to sorb control channel and temperature
        }
        when (skipped_sp == 1) {
            PVPUT(skipped, 1);
        } state part2
        when (cancelled_sp == 1) {
            PVPUT(cancelled, 1);
        } state not_recondensing
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
        when (cancelled_sp == 1) {
            PVPUT(cancelled, 1);
        } state not_recondensing
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
        when (cancelled_sp == 1) {
            PVPUT(cancelled, 1);
        } state not_recondensing
    }

    state finish {
        entry {
            PVPUT(part, 4);
        }
        when () {
            PVPUT(temp_he3pot_sp, post_condense_temp_sp);
        } state not_recondensing
    }
}
