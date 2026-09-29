ifdef DEB_BUILD_GNU_TYPE
    REGRESS_OPTS =--temp-config=./pgsentinel.conf
else
    REGRESS_OPTS =--temp-config=./pgsentinel.conf --temp-instance=./tmp_check
endif

REGRESS = pgsentinel-test

MODULE_big = pgsentinel
OBJS = $(patsubst %.c,%.o,$(wildcard ./*.c))

# YB: warnings are errors by default. Build with YB_WERROR= to leave them
# as warnings, e.g. when pgsentinel is built as part of another image.
YB_WERROR ?= -Werror

ifeq ($(CC),gcc)
    PG_CPPFLAGS = -std=gnu11 -Wall -Wextra $(YB_WERROR) -Wno-unused-parameter -Wno-uninitialized -Wno-implicit-fallthrough -Iinclude
else
    PG_CPPFLAGS = -std=gnu11 -Wall -Wextra $(YB_WERROR) -Wno-unused-parameter -Wno-implicit-fallthrough -Iinclude
endif

EXTRA_CLEAN += $(addprefix ./,*.gcno *.gcda)

EXTENSION = pgsentinel
DATA = $(wildcard $(EXTENSION)*--*.sql)
PGFILEDESC = "pgsentinel - active session history"

LDFLAGS_SL += $(filter -lm, $(LIBS))

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
