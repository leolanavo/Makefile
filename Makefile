# A simple Makefile to automate work.
# By: Leonardo Lana

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
# TEX -> the name of the .tex file.               #
#                                                 #
###################################################

BIN      :=  
TARF     := 
TEX      := 
FINALDIR := 
CFLAGS   := 

CC  := gcc
RM  := rm -f
MV  := mv
CP  := cp -r
TAR := tar -cvf 

OBJDIR := obj
SRCDIR := src
BINDIR := .
INCDIR := include
TXTDIR := txt
LTXDIR := report

#This will add any .c in the src directory 
#file to the list of compilation.
SRC := $(wildcard $(SRCDIR)/*.c)
OBJ := $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRC))

# main target
.PHONY: all
all: $(BINDIR)/$(BIN)

# build rules
$(BINDIR)/$(BIN): $(OBJ) | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $^

$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(INCDIR)/%.h | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

# directory creation rules
$(OBJDIR) $(BINDIR) $(SRCDIR) $(INCDIR) $(LTXDIR) $(TXTDIR) $(FINALDIR):
	mkdir -p $@

.PHONY: debug
# phony targets for automation
.PHONY: init
init: | $(SRCDIR) $(INCDIR) $(LTXDIR) $(TXTDIR)
	git init
	echo $(OBJDIR) > .gitignore
	echo $(TXTDIR) >> .gitignore
	echo $(FINALDIR) >> .gitignore
	echo $(BIN) >> .gitignore
	echo $(LTXDIR)/*.log >> .gitignore
	echo $(LTXDIR)/*.dvi >> .gitignore
	echo $(LTXDIR)/*.aux >> .gitignore
	git add $(SRCDIR)
	git add $(INCDIR)
	git add $(LTXDIR)
	git add .gitignore
	git add Makefile
	git commit -m "Initial commit"

.PHONY: template
template:
	touch $(LTXDIR)/$(TEX)
	echo '\\documentclass[a4paper, 12pt]{article}' > $(LTXDIR)/$(TEX)
	echo '\\usepackage[brazilian]{babel}' >> $(LTXDIR)/$(TEX)
	echo '\\usepackage[utf8]{inputenc}' >> $(LTXDIR)/$(TEX)
	echo '\\usepackage[T1]{fontenc}' >> $(LTXDIR)/$(TEX)
	echo '\\usepackage[a4paper]{geometry}' >> $(LTXDIR)/$(TEX)
	echo '\\usepackage{amsmath}' >> $(LTXDIR)/$(TEX)
	echo '\\usepackage{amssymb}' >> $(LTXDIR)/$(TEX)
	echo '\\usepackage{indentfirst}' >> $(LTXDIR)/$(TEX)
	echo '' >> $(LTXDIR)/$(TEX)
	echo '\\title{}' >> $(LTXDIR)/$(TEX)
	echo '\\author{}' >> $(LTXDIR)/$(TEX)
	echo '\\date{}' >> $(LTXDIR)/$(TEX)
	echo '' >> $(LTXDIR)/$(TEX)
	echo '\\begin{document}' >> $(LTXDIR)/$(TEX)
	echo '\\maketitle' >> $(LTXDIR)/$(TEX)
	echo '' >> $(LTXDIR)/$(TEX)
	echo '\\end{document}' >> $(LTXDIR)/$(TEX)

.PHONY: clean
clean:
	$(RM) $(OBJDIR)/*.o
	$(RM) $(LTXDIR)/*.dvi
	$(RM) $(LTXDIR)/*.aux
	$(RM) $(LTXDIR)/*.log

.PHONY: latex
latex:
	pdflatex $(LTXDIR)/$(TEX)

.PHONY: organize
organize:
	-$(MV) *.o $(OBJDIR)
	-$(MV) *.c $(SRCDIR)
	-$(MV) *.h $(INCDIR)
	-$(MV) *.txt $(TXTDIR)
	-$(MV) *.dvi $(LTXDIR)
	-$(MV) *.aux $(LTXDIR)
	-$(MV) *.tex $(LTXDIR)
	-$(MV) *.pdf $(LTXDIR)
	-$(MV) *.log $(LTXDIR)

.PHONY: tar
tar: | $(FINALDIR)
	$(CP) $(SRCDIR) $(FINALDIR)
	$(CP) $(LTXDIR) $(FINALDIR)
	$(RM) $(FINALDIR)/$(LTXDIR)/*.dvi
	$(RM) $(FINALDIR)/$(LTXDIR)/*.aux
	$(RM) $(FINALDIR)/$(LTXDIR)/*.log
	$(RM) $(FINALDIR)/$(LTXDIR)/*.tex
	$(CP) $(INCDIR) $(FINALDIR)
	$(CP) Makefile $(FINALDIR)
	$(TAR) $(TARF).tar $(FINALDIR)

.PHONY: upload
	git add --all
	git commit -m "Upload all the files"
	git push origin master
