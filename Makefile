SOURCES = $(wildcard *.moon)
OUTPUTS = $(SOURCES:.moon=.lua)

.PHONY: all clean

all: $(OUTPUTS)

clean:
	$(RM) $(OUTPUTS)

%.lua: %.moon
	moonc $<