#include "seqPVmacros.h"

program hlx503 ("P")

PV(int, recondensing_sp, "{P}RECONDENSING:SP", Monitor);
PV(int, recondensing, "{P}RECONDENSING", NoMon);
PV(int, part_sp, "{P}RECONDENSE:PART:SP", NoMon);

ss recondense {
    state init {
        entry {
            PVPUT(recondensing_sp, 0);
            PVPUT(recondensing, 0);
            PVPUT(part_sp, 5);
        }
        when (recondensing_sp == 1) {
            PVPUT(recondensing, 1);
        } state setup
    }
    state setup {
        entry {
            PVPUT(part_sp, 0);
        }
        when (recondensing_sp == 0) {} state init
    }
}
