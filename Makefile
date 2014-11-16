PANDOC      := $(shell which pandoc)

LESSC        = node_modules/less/bin/lessc
LESS         = src/less/main.less
LESSFLAGS    = -x
AUTOPREFIXER = node_modules/autoprefixer/autoprefixer
PRECSS       = css/main.css
CSS          = css/main-min.css

TEMPLATE     = src/layout/default
RESUME       = src/résumé.md
RESUMEEDU    = src/résumé-edu.md
TEMP         = /tmp/resume.md
INDEX        = index.html

PANDOCFLAGS =--atx-headers --section-divs --template "$(TEMPLATE)" -c 'http://fonts.googleapis.com/css?family=Old+Standard+TT:400,400italic&subset=latin,latin-ext' -c "$(CSS)"
PANDOCTEXFLAGS =

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
	$(PANDOC) $(PANDOCFLAGS) -f markdown -t html5 -o "$@" "$(RESUME)"

résumé.tex: $(RESUME) $(RESUMEEDU)
	cat $(RESUME) $(RESUMEEDU) > $(TEMP)
	sed -i -e '7,13d' $(TEMP) # delete "About Me"
	$(PANDOC) $(PADCOTTEXFLAGS) -f markdown -t latex  -o "$@" $(TEMP)

serve:
	python2 -mSimpleHTTPServer

watch:
	while true; do \
    inotifywait -e modify "$(LESS)" "$(RESUME)" && make; \
	done;


.PHONY: serve watch