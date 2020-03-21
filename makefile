#########################
TARGET = mainMIPS-DF
#########################

DEBUG=-Wall -O0 -g
RELEASE=-Wall -O3

CFLAGS=$(DEBUG)
DFLAGS=
LDFLAGS=-lsystemc

CC=gcc
CXX=g++

#OBJS=main.o

SRCDIR  = src
OBJDIR  = obj
DESTDIR = target

SOURCES := $(wildcard $(SRCDIR)/*.cpp)
OBJS    := $(SOURCES:$(SRCDIR)/%.cpp=$(OBJDIR)/%.o)

#############################################################

$(TARGET): $(OBJS)
	@mkdir -p $(DESTDIR)
	$(CXX) $(CFLAGS) $(DFLAGS) -o $(DESTDIR)/$@ $(OBJS) $(LDFLAGS)

$(OBJS): $(OBJDIR)/%.o : $(SRCDIR)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CFLAGS) $(DFLAGS) -c $< -o $@

c: clean
	
clean:
	rm -rf $(OBJDIR) $(DESTDIR)