HW_INPUTS := $(sort $(wildcard hw*.md) $(wildcard cr*.md) $(wildcard final*.md))
PDF_OUTPUTS := $(HW_INPUTS:.md=.pdf)
PDF_OUTPUT_FILES := $(sort $(PDF_OUTPUTS:%=out/%))
HTML_OUTPUTS := $(HW_INPUTS:.md=.html)
HTML_OUTPUT_FILES := $(sort $(HTML_OUTPUTS:%=out/%))

H_PGFPLOTS := #

PANDOC_HEADERS := 0az-pandoc-common.tex
PANDOC_EXTRA_HEADERS :=

PANDOC_OPTS := --standalone --template eisvogel.tex --from commonmark+hard_line_breaks
PANDOC_PDF_OPTS =

.PHONY: all clean latest watch

all: $(PDF_OUTPUT_FILES)  # $(HTML_OUTPUT_FILES)
	@echo '[all] Done processing.'

clean:
	rm -f $(PDF_OUTPUT_FILES)  # $(HTML_OUTPUT_FILES)

latest: $(lastword $(PDF_OUTPUT_FILES))

watch: all
	@exec ./watch.sh

out/%.pdf: %.md | out
	pandoc $(PANDOC_OPTS) $(foreach header,$(PANDOC_HEADERS),-H $(header)) $(foreach header,$(PANDOC_EXTRA_HEADERS),-H $(header)) $(PANDOC_PDF_OPTS) -o $@ $<

out/%.html: %.md | out
	pandoc $(PANDOC_OPTS) $(foreach header,$(PANDOC_HEADERS),-H $(header)) $(foreach header,$(PANDOC_EXTRA_HEADERS),-H $(header)) $(PANDOC_HTML_OPTS) -o $@ $<

out:
	mkdir -p $@
