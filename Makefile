SOURCES = $(shell find -name "*.moon")
OUTPUTS = $(SOURCES:.moon=.lua)

.PHONY: all clean

all: $(OUTPUTS)

run: $(OUTPUTS)
	love .

clean:
	$(RM) $(OUTPUTS)

%.lua: %.moon
	moonc $<