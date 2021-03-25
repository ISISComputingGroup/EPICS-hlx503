program hlx503 ("P")

#include "seqPVmacros.h"

PV(int, recondensing_sp, "{P}RECONDENSING:SP", Monitor);
PV(int, recondensing, "{P}RECONDENSING", NoMon);
PV(int, part, "{P}RE:PART", NoMon);
PV(int, timed_out, "{P}RE:TIMED_OUT", NoMon);
PV(int, skipped_sp, "{P}RE:SKIPPED:SP", Monitor);
PV(int, skipped, "{P}RE:SKIPPED", NoMon);
PV(int, cancelled_sp, "{P}RE:CANCELLED:SP", Monitor);
PV(int, cancelled, "{P}RE:CANCELLED", NoMon);
PV(float, post_condense_temp_sp, "{P}RE:TEMP", Monitor);
PV(float, temp_he3pot_sp, "{P}TEMP:HE3POT:SP", NoMon);
PV(float, temp_sorb_sp, "{P}TEMP:SORB:SP", NoMon);
PV(float, temp_sp, "{P}TEMP:SP", Monitor);
PV(int, adjust_pids_sp, "{P}ADJUST_PIDS:SP", NoMon);
PV(int, mode_htr_sp, "{P}MODE:HTR:SP", NoMon);
PV(float, heater_percent_sp, "{P}HEATERP:SP", NoMon);
PV(float, recondense_sorb_temp_sp, "{P}RE:SORB:TEMP", Monitor);
PV(float, recondense_sorb_temp_final_sp, "{P}RE:SORB:TEMP:FIN", Monitor);
PV(float, sorb_temp, "{P}TEMP:SORB", Monitor);
PV(float, he3pot_temp, "{P}TEMP:HE3POT", Monitor);
PV(float, recondense_sorb_p, "{P}RE:SORB:P", Monitor);
PV(float, recondense_sorb_i, "{P}RE:SORB:I", Monitor);
PV(float, recondense_sorb_d, "{P}RE:SORB:D", Monitor);
PV(float, p_sp, "{P}P:SP", NoMon);
PV(float, i_sp, "{P}I:SP", NoMon);
PV(float, d_sp, "{P}D:SP", NoMon);
PV(string, ctrlchannel, "{P}CTRLCHANNEL", Monitor);
PV(string, ctrlchannel_sp, "{P}CTRLCHANNEL:SP", NoMon);
PV(int, timeout, "{P}RE:TIMEOUT", Monitor);
PV(int, timeout_on, "{P}RE:TIMEOUT:ON", Monitor);
PV(float, he3pot_target_part1, "{P}RE:HE3POT:TEMP:PART1", Monitor);
PV(float, he3pot_target_part2, "{P}RE:HE3POT:TEMP:PART2", Monitor);
PV(int, success, "{P}RE:SUCCESS", NoMon);
PV(int, post_part2_wait_time, "{P}RE:PART2:WAIT_TIME", Monitor);

ss recondense {

    state init {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(cancelled_sp, 0);
            PVPUT(cancelled, 0);
            PVPUT(timed_out, 0);
            PVPUT(success, 0);
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
            PVPUT(success, 0);
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
            PVPUT(success, 0);
            PVPUT(skipped, 1);
        } state part2
        when (cancelled_sp == 1) {
            PVPUT(success, 0);
            PVPUT(cancelled, 1);
        } state not_recondensing
        when(timeout_on == 1 && delay(timeout)) {
            PVPUT(success, 0);
            PVPUT(timed_out, 1);
        } state finish
        when(sorb_temp > (recondense_sorb_temp_sp - 0.5) || he3pot_temp < he3pot_target_part1) {
            PVPUT(success, 1);
        } state part2
    }

    state part2 {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(part, 2);
        }
        when (skipped_sp == 1) {
            PVPUT(success, 0);
            PVPUT(skipped, 1);
        } state part3
        when (cancelled_sp == 1) {
            PVPUT(success, 0);
            PVPUT(cancelled, 1);
        } state not_recondensing
        when(timeout_on == 1 && delay(timeout)) {
            PVPUT(success, 0);
            PVPUT(timed_out, 1);
        } state finish
        when(sorb_temp > (recondense_sorb_temp_sp - 0.5) || he3pot_temp < he3pot_target_part2) {
            PVPUT(success, 1);
        } state part2_wait
    }

    state part2_wait {
        when(delay(post_part2_wait_time)) {} state part3
    }

    state part3 {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(part, 3);
            PVPUTSTR(ctrlchannel_sp, "SORB");
            PVPUT(heater_percent_sp, 0);
            PVPUT(temp_sorb_sp, 0);
        }
        when (skipped_sp == 1) {
            PVPUT(success, 0)
            PVPUT(skipped, 1);
        } state finish
        when (cancelled_sp == 1) {
            PVPUT(success, 0);
            PVPUT(cancelled, 1);
        } state not_recondensing
        when(timeout_on == 1 && delay(timeout)) {
            PVPUT(success, 0);
            PVPUT(timed_out, 1);
        } state finish
        when(sorb_temp < recondense_sorb_temp_final_sp) {
            PVPUT(success, 1);
        } state part3_wait
    }

    state part3_wait {
        when(delay(2)) {} state finish
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
