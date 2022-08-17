program hlx503 ("P")

#include "ibexSeqPVmacros.h"

// Recondense status PVs
PV(int, recondensing_sp, "{P}RECONDENSING:SP", Monitor);
PV(int, recondensing, "{P}RECONDENSING", NoMon);
PV(string, part, "{P}RE:PART", NoMon);
PV(int, timed_out, "{P}RE:TIMED_OUT", NoMon);
PV(int, skipped_sp, "{P}RE:SKIPPED:SP", Monitor);
PV(int, skipped, "{P}RE:SKIPPED", NoMon);
PV(int, cancelled_sp, "{P}RE:CANCELLED:SP", Monitor);
PV(int, cancelled, "{P}RE:CANCELLED", NoMon);
PV(int, success, "{P}RE:SUCCESS", NoMon);
PV(int, part_success, "{P}RE:SUCCESS:_PART", Monitor);

// Recondense user settings PVs
PV(float, post_condense_temp_sp, "{P}RE:TEMP", Monitor);
PV(float, recondense_sorb_p, "{P}RE:SORB:P", Monitor);
PV(float, recondense_sorb_i, "{P}RE:SORB:I", Monitor);
PV(float, recondense_sorb_d, "{P}RE:SORB:D", Monitor);
PV(float, recondense_sorb_temp_sp, "{P}RE:SORB:TEMP", Monitor);
PV(float, recondense_sorb_temp_final_sp, "{P}RE:SORB:TEMP:FIN", Monitor);

// Recondense target and control PVs
PV(int, timeout, "{P}RE:TIMEOUT", Monitor);
PV(int, timeout_on, "{P}RE:TIMEOUT:ON", Monitor);
PV(float, he3pot_target_part1, "{P}RE:HE3POT:TEMP:PART1", Monitor);
PV(float, he3pot_target_part2, "{P}RE:HE3POT:TEMP:PART2", Monitor);
PV(int, post_part2_wait_time, "{P}RE:PART2:WAIT_TIME", Monitor);

// Temperature PVs
PV(float, temp_he3pot_sp, "{P}TEMP:HE3POT:SP", NoMon);
PV(float, temp_sorb_sp, "{P}TEMP:SORB:SP", NoMon);
PV(float, temp_sp, "{P}TEMP:SP", Monitor);
PV(float, sorb_temp, "{P}TEMP:SORB", Monitor);
PV(float, he3pot_temp, "{P}TEMP:HE3POT", Monitor);
PV(float, he3pot_temp_hi, "{P}TEMP:HE3POTHI", Monitor);


// PID PVs
PV(string, adjust_pids_sp, "{P}ADJUST_PIDS:SP", Monitor);
PV(string, autopid, "{P}AUTOPID", Monitor);
PV(string, autopid_sp, "{P}AUTOPID:SP", Monitor);
PV(float, p_sp, "{P}P:SP", Monitor);
PV(float, i_sp, "{P}I:SP", Monitor);
PV(float, d_sp, "{P}D:SP", Monitor);
PV(string, old_adjust_pids, "{P}RE:_OLD_ADJUST_PIDS", Monitor);
PV(string, old_autopid, "{P}RE:_OLD_AUTOPID", Monitor);
PV(float, old_p, "{P}RE:_OLD_P", Monitor);
PV(float, old_i, "{P}RE:_OLD_I", Monitor);
PV(float, old_d, "{P}RE:_OLD_D", Monitor);

// Heater PVs
PV(int, mode_htr_sp, "{P}MODE:HTR:SP", NoMon);
PV(float, heater_percent_sp, "{P}HEATERP:SP", NoMon);
PV(int, heater_off, "{P}HEATER:OFF", NoMon);

// Control channel PVs
PV(string, ctrlchannel, "{P}CTRLCHANNEL", Monitor);
PV(string, ctrlchannel_sp, "{P}CTRLCHANNEL:SP", NoMon);


ss recondense {

    state init {
        entry {
            // Reset all status PVs
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUT(cancelled_sp, 0);
            PVPUT(cancelled, 0);
            PVPUT(timed_out, 0);
            PVPUT(success, 0);
            PVPUT(part_success, 0);
        }
        // Start off not recondensing
        when () {} state not_recondensing
    }

    state not_recondensing {
        entry {
            // Set status that we are not recondensing 
            PVPUT(heater_off, 1);
            PVPUT(temp_sp, 0.0);
            PVPUT(recondensing_sp, 0);
            PVPUT(recondensing, 0);
            PVPUTSTR(part, "NOT RECONDENSING");
            // Do not reset all status PVs so the status of the last recondense is kept
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
            PVPUT(timed_out, 0);
            PVPUT(success, 0);
            PVPUT(part_success, 0);
            // Set status that we are on part 1 of a recondense
            PVPUTSTR(part, "PART 1");
            // Set heater to manual, 0%
            PVPUT(heater_off, 1);
            // Store PID settings to reapply post-recondense
            PVPUTSTR(old_adjust_pids, adjust_pids_sp);
            PVPUTSTR(old_autopid, autopid);
            PVPUT(old_p, p_sp);
            PVPUT(old_i, i_sp);
            PVPUT(old_d, d_sp);
            // Use PIDs from PVs not tpar files or autopid
            PVPUTSTR(adjust_pids_sp, "NO");
            PVPUTSTR(autopid_sp, "OFF");
            // Set PIDs
            PVPUT(p_sp, recondense_sorb_p);
            PVPUT(i_sp, recondense_sorb_i);
            PVPUT(d_sp, recondense_sorb_d);
            // Set temperature then heater mode to auto
	    PVPUT(heater_off, 1);
            PVPUT(temp_sorb_sp, recondense_sorb_temp_sp);
        }
        when (skipped_sp == 1) {
            PVPUT(part_success, 0);
            PVPUT(skipped, 1);
        } state part2_wait
        when (cancelled_sp == 1) {
            PVPUT(part_success, 0);
            PVPUT(success, 0);
            PVPUT(cancelled, 1);
        } state not_recondensing
        when(timeout_on == 1 && delay(timeout)) {
            PVPUT(part_success, 0);
            PVPUT(timed_out, 1);
        } state finish
        when(sorb_temp > (recondense_sorb_temp_sp - 0.5) && he3pot_temp_hi < he3pot_target_part1) {
            PVPUT(part_success, 1);
        } state part2_wait
    }

    state part2_wait {
        when(delay(post_part2_wait_time)) {} state part3
    }

    state part3 {
        entry {
            PVPUT(skipped_sp, 0);
            PVPUT(skipped, 0);
            PVPUTSTR(part, "PART 3");
            PVPUT(temp_sorb_sp, 0);
        }
        when (skipped_sp == 1) {
            PVPUT(part_success, 0)
            PVPUT(skipped, 1);
        } state finish
        when (cancelled_sp == 1) {
            PVPUT(part_success, 0);
            PVPUT(success, 0);
            PVPUT(cancelled, 1);
        } state not_recondensing
        when(timeout_on == 1 && delay(timeout)) {
            PVPUT(part_success, 0);
            PVPUT(timed_out, 1);
        } state finish
        when(sorb_temp < recondense_sorb_temp_final_sp) {
            // Part success will remain true if it was set to true in part 1
        } state part3_wait
    }

    state part3_wait {
        when(delay(2)) {} state finish
    }

    state finish {
        entry {
            PVPUTSTR(part, "FINISHING");
        }
        when () {
            if (part_success == 1) {
                PVPUT(success, 1);
            }
            PVPUT(temp_he3pot_sp, post_condense_temp_sp);
            // Reset PID status from pre-recondense
            PVPUTSTR(adjust_pids_sp, old_adjust_pids);
            PVPUTSTR(autopid_sp, old_autopid);
            PVPUT(p_sp, old_p);
            PVPUT(i_sp, old_i);
            PVPUT(d_sp, old_d);
        } state not_recondensing
    }
}
