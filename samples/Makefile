# Makefile for MQTT D language sample apps

DC = dmd
#DC = gdc

RM = rm -f

ifeq ($(DC), gdc)
  DFLAGS = -Wall -O2 -g
else
  DFLAGS = -g
  OUTPUT_OPTION = -of$@
endif

SRCS += $(wildcard *.d)
TGTS = $(SRCS:.d=)

PAHO_C_LIB ?= $(abspath ../../../org.eclipse.paho.mqtt.c)
 
.PHONY: all
all: $(TGTS)

COMPILE.d = $(DC) $(DFLAGS) $(TARGET_ARCH)

ifeq ($(DC), gdc)
  %: %.d
	$(COMPILE.d) $(OUTPUT_OPTION) $< -I.. -L../../lib -lpaho-mqttd -L$(PAHO_C_LIB)/build/output -lpaho-mqtt3a
else
  %: %.d
	$(COMPILE.d) $(OUTPUT_OPTION) $< -I.. -L-l:../../lib/libpaho-mqttd.so -L-l:$(PAHO_C_LIB)/build/output/libpaho-mqtt3a.so -defaultlib=libphobos2.so
endif

.PHONY: clean
clean:
	-$(RM) $(TGTS)


