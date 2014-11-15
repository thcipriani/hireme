PANDOC      := $(shell which pandoc)

LESSC        = node_modules/less/bin/lessc
LESS         = src/less/main.less
LESSFLAGS    = -x
AUTOPREFIXER = node_modules/autoprefixer/autoprefixer
PRECSS       = css/main.css
CSS          = css/main-min.css

TEMPLATE     = src/layout/default
RESUME       = src/résumé.md
INDEX        = index.html

PANDOC_SWITCHES =--atx-headers --section-divs --template "$(TEMPLATE)" -c 'http://fonts.googleapis.com/css?family=Old+Standard+TT:400,400italic&subset=latin,latin-ext' -c "$(CSS)"

all: $(INDEX)

$(LESSC):
	@npm install

$(AUTOPREFIXER):
	@npm install

$(PRECSS): $(LESS) $(LESSC) $(AUTOPREFIXER)
	$(LESSC) $(LESSFLAGS) "$(LESS)" > "$@"

$(CSS): $(PRECSS)
	$(AUTOPREFIXER) $(PRECSS) -o "$@"

$(INDEX): $(RESUME) $(CSS)
	$(PANDOC) $(PANDOC_SWITCHES) -f markdown -t html5 -o "$@" "$(RESUME)"

serve:
	python2 -mSimpleHTTPServer

watch:
	while true; do \
    inotifywait -e modify "$(LESS)" "$(RESUME)" && make; \
	done;


.PHONY: serve watch