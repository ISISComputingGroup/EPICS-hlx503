program hlx503 ("P")

#include "seqPVmacros.h"
%% #include "errlog.h"

PV(int, recondensing_sp, "{P}RECONDENSING:SP", Monitor);
PV(int, recondensing, "{P}RECONDENSING", NoMon);
PV(int, part, "{P}RECONDENSE:PART", NoMon);
PV(int, timed_out, "{P}RECONDENSE:TIMED_OUT", NoMon);
PV(int, skipped_sp, "{P}RECONDENSE:SKIPPED:SP", Monitor);
PV(int, skipped, "{P}RECONDENSE:SKIPPED", NoMon);
PV(int, cancelled_sp, "{P}RECONDENSE:CANCELLED:SP", Monitor);
PV(int, cancelled, "{P}RECONDENSE:CANCELLED", NoMon);
PV(float, post_condense_temp_sp, "{P}RECONDENSE:TEMP:SP:RBV", Monitor);
PV(float, temp_he3pot_sp, "{P}TEMP:HE3POT:SP", NoMon);
PV(float, temp_sorb_sp, "{P}TEMP:SORB:SP", NoMon);
PV(float, temp_sp, "{P}TEMP:SP", Monitor);
PV(int, adjust_pids_sp, "{P}ADJUST_PIDS:SP", NoMon);
PV(int, mode_htr_sp, "{P}MODE:HTR:SP", NoMon);
PV(float, heater_percent_sp, "{P}HEATERP:SP", NoMon);
PV(float, recondense_sorb_temp_sp, "{P}RECONDENSE:SORB:TEMP:SP:RBV", Monitor);
PV(float, recondense_sorb_p, "{P}RECONDENSE:SORB:P:SP:RBV", Monitor);
PV(float, recondense_sorb_i, "{P}RECONDENSE:SORB:I:SP:RBV", Monitor);
PV(float, recondense_sorb_d, "{P}RECONDENSE:SORB:D:SP:RBV", Monitor);
PV(float, p_sp, "{P}P:SP", NoMon);
PV(float, i_sp, "{P}I:SP", NoMon);
PV(float, d_sp, "{P}D:SP", NoMon);
PV(string, ctrlchannel, "{P}CTRLCHANNEL", Monitor);
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
        } state part1_a
    }

    state part1_a {
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
            // Set control channel, temperature and PIDs
            PVPUT(temp_sorb_sp, recondense_sorb_temp_sp);
            PVPUT(p_sp, recondense_sorb_p);
            PVPUT(i_sp, recondense_sorb_i);
            PVPUT(d_sp, recondense_sorb_d);
        }
        when (skipped_sp == 1) {
            PVPUT(skipped, 1);
        } state part2
        when (cancelled_sp == 1) {
            PVPUT(cancelled, 1);
        } state not_recondensing
        when (strcmp(ctrlchannel, "SORB") == 0 && temp_sp == recondense_sorb_temp_sp) {} state part1_b
    }

    state part1_b {
        entry { 
            // Set control channel to He3Pot Low temperature
            PVPUTSTR(ctrlchannel_sp, "1KPOTHE3POTLO");
            errlogSevPrintf(errlogInfo, "%s: Set control channel to %s.\n", "hlx503.st", "1KPOTHE3POTLO");
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
