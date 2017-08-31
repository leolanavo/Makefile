#######################################
# A simple Makefile to automate work. #
# By: Leonardo Lana                   #
#######################################

#########################################################
# Quick tip: when you start a project, enter its folder #
# and type in the terminal: make init.                  #
#########################################################

###################################################
# Subtitles:                                      #
#                                                 #
# BIN -> the name of the executable.              #
# CFLAGS -> the list of flags you want.           #
# FINALDIR -> the name of the directory that will #
#             be compressed in .tar.              #
# TARF -> the name of the .tar file.              #
#                                                 #
###################################################

BIN   	  := 
TARF      := 
FINALDIR  := 

CFLAGS    := -Wall -std=c11 -lreadline
EXECFLAGS := -O2
TESTFLAGS := -g

CC    := gcc
MV    := mv
RM    := rm -f
RMDIR := rm -rf
CP    := cp -r
ECHO  := echo -e
MKDIR := mkdir -p
TAR   := tar -cvf

BINDIR := bin
SRCDIR := src
OBJDIR := build
TSTDIR := test
TXTDIR := txt
INCDIR := include
LTXDIR := report
ROOT := $(SRCDIR) $(INCDIR) $(LTXDIR) $(TXTDIR) \
        $(FINALDIR) $(BINDIR) $(TSTDIR) $(OBJDIR)
BINROOT := $(foreach r,$(INCDIR) $(SRCDIR) $(OBJDIR),$(foreach b,$(BIN),$r/$b))

# main target
.PHONY: all
all: CFLAGS += $(EXECFLAGS)
all: $(addprefix $(BINDIR)/,$(BIN))

.PHONY: debug
debug: CFLAGS += $(TESTFLAGS)
debug: $(addprefix $(TSTDIR)/,$(BIN))

# Create the necessary lists of dependencies for each binary
define create_vars
$(eval $1.SRC := $(strip $(wildcard $(SRCDIR)/*.c) $(wildcard $(SRCDIR)/$1/*.c)))
$(eval $1.OBJ := $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $($1.SRC)))
$(eval $1.INC := $(strip $(wildcard $(INCDIR)/*.h) $(wildcard $(INCDIR)/$1/*.h)))
endef
$(foreach x,$(BIN),$(call create_vars,$x))

# Compile each one of the binaries
define bin-factory
$$(BINDIR)/$1: $$($1.OBJ) | $$(BINDIR)
	$$(CC) $$(CFLAGS) -o $$@ $$^
endef
$(foreach x,$(BIN),$(eval $(call bin-factory,$x)))

define test-factory
$$(TSTDIR)/$1: $$($1.OBJ) | $$(TSTDIR)
	$$(CC) $$(CFLAGS) -o $$@ $$^
endef
$(foreach x,$(BIN),$(eval $(call test-factory,$x)))

define object-factory
$$(OBJDIR)/$1.o: $$(SRCDIR)/$1.c $$(wildcard $$(INCDIR)/$1.h) | $$(OBJDIR) $$(BINROOT)
	$$(CC) $$(CFLAGS) -c -o $$@ $$<
endef
$(foreach b,$(BIN),\
	$(foreach obj,$($b.OBJ),\
		$(eval $(call object-factory,$(patsubst $(OBJDIR)/%.o,%,$(obj))))))

# Directory creation rules
$(ROOT) $(BINROOT):
	@$(MKDIR) $@

# phony targets for automation
.PHONY: init
init: | $(ROOT) $(BINROOT)
	@$(ECHO) "Creating the .gitignore..."
	@$(ECHO) "$(OBJDIR)\n$(FINALDIR)\n$(TXTDIR)\n$(BINDIR)\n$(TSTDIR)\n.git" > .gitignore
	@$(ECHO) "Finished"

.PHONY: clean
clean:
	@$(RMDIR) $(OBJDIR)
	@$(RMDIR) $(TSTDIR)
	@$(RM) $(LTXDIR)/*.dvi $(LTXDIR)/*.aux $(LTXDIR)/*.log

.PHONY: organize
organize:
	@$(MV) *.o $(OBJDIR)
	@$(MV) *.c $(SRCDIR)
	@$(MV) *.h $(INCDIR)
	@$(MV) *.txt $(TXTDIR)

.PHONY: package
package: clean | $(FINALDIR)
	
	@$(ECHO) "Copying files..."
	@$(CP) $(SRCDIR) $(FINALDIR)
	@$(CP) $(INCDIR) $(FINALDIR)
	@$(CP) $(LTXDIR) $(FINALDIR)
	@$(CP) Makefile $(FINALDIR)
	
	@$(ECHO) "Compressing..."
	@$(TAR) $(TARF).tar.gz $(FINALDIR)
	
	@$(ECHO) "Cleaning..."
	@$(RMDIR) $(FINALDIR)
