TOP=..
include $(TOP)/configure/CONFIG
#=======================================

# Install .dbd and .db files
DB += hlx503.db
DB += hlx503_recondense.db
DBD += hlx503.dbd

# Sequence file
LIBRARY_IOC = hlx503
hlx503_SRCS += hlx503.st
hlx503_LIBS += seq pv
hlx503_LIBS += $(EPICS_BASE_IOC_LIBS)

#protocol files

#=======================================
include $(TOP)/configure/RULES
