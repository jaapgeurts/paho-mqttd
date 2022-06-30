# Makefile for MQTT Paho "D" language libraries
#
# The DMD compiler seems to be able to make a shared library, no problem.
# Still can't figure out how to do that with GDC. So a static library for GDC.
#
 
DC = ldc2
#DC = gdc

RM = rm -f

ifeq ($(DC), gdc)
  DFLAGS = -fPIC -Wall -O2 -g
#  LDFLAGS = -shared
  TGT = libpaho-mqttd.a
else
  DFLAGS = -fPIC -g
  LDFLAGS = -shared -defaultlib=phobos2
  OUTPUT_OPTION = -of$@
  TGT = libpaho-mqttd.so
endif


PAHO_C_LIB ?= $(abspath ../../org.eclipse.paho.mqtt.c)

SRCS += $(wildcard *.d)
OBJS = $(SRCS:.d=.o)
 
.PHONY: all
all: $(TGT)

COMPILE.d = $(DC) $(DFLAGS) $(TARGET_ARCH) -c

%.o: %.d
	$(COMPILE.d) $(OUTPUT_OPTION) $<

ifeq ($(DC), gdc)
  $(TGT): $(OBJS)
#	$(DC) $(LDFLAGS) $(OUTPUT_OPTION) $^ $(PAHO_C_LIB)/build/output/libpaho-mqtt3a.so  -defaultlib=phobos2
	$(AR) $(ARFLAGS) $@ $^
else
$(TGT): $(OBJS)
	$(DC) $(LDFLAGS) $(OUTPUT_OPTION) $^ $(PAHO_C_LIB)/build/output/libpaho-mqtt3a.so
endif

# This could be used for a static library 
#$(TGT): $(OBJS)
#	$(AR) $(ARFLAGS) $@ $^

.PHONY: clean
clean:
	-$(RM) $(TGT) $(OBJS)

