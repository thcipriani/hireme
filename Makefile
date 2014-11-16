PANDOC      := $(shell which pandoc)

LESSC        = ./node_modules/less/bin/lessc
LESS         = ./src/less/main.less
LESSFLAGS    = -x
AUTOPREFIXER = ./node_modules/autoprefixer/autoprefixer
PRECSS       = ./css/main.css
CSS          = ./css/main-min.css

TEMPLATE     = ./src/layout/default
RESUME       = ./src/résumé.md
RESUMEEDU    = ./src/résumé-edu.md
TEMP         = /tmp/resume.md
INDEX        = ./index.html

PANDOCFLAGS =--atx-headers --section-divs --template "$(TEMPLATE)" -c 'http://fonts.googleapis.com/css?family=Old+Standard+TT:400,400italic&subset=latin,latin-ext' -c "$(CSS)"
PANDOCTEXFLAGS =-V geometry:"top=2cm, bottom=2cm, left=3cm, right=3cm"

REPO_ASSERT := $(shell git config --get remote.origin.url)
REPO ?= $(REPO_ASSERT)

all: pdf README.md $(INDEX)

# install deps
$(LESSC):
	@npm install

$(AUTOPREFIXER):
	@npm install

# create unprefixed css
$(PRECSS): $(LESS) $(LESSC) $(AUTOPREFIXER)
	$(LESSC) $(LESSFLAGS) "$(LESS)" > "$@"

# autoprefix final css
$(CSS): $(PRECSS)
	$(AUTOPREFIXER) $(PRECSS) -o "$@"

# create /hireme
$(INDEX): $(RESUME) $(CSS)
	$(PANDOC) $(PANDOCFLAGS) -f markdown -t html5 -o "$@" "$(RESUME)"

# copy to readme.md
README.md: $(RESUME)
	cp "$<" "$@"

# create pdf résumé
résumé.pdf: $(RESUME) $(RESUMEEDU)
	cat $(RESUME) $(RESUMEEDU) > $(TEMP)
	sed -i -e '7,13d' $(TEMP) # delete "About Me"
	$(PANDOC) $(PANDOCTEXFLAGS) -o "$@" $(TEMP)

# easier than typing “résumé”
pdf: résumé.pdf

# update github pages repo
gh-pages: $(INDEX)
	git clone "$(REPO)" "$@"
	@(cd "$@" && git checkout "$@") || (cd "$@" && git checkout --orphan "$@" && git rm -rf .)
	cp -R "./css" "$@"
	cp -R "$(INDEX)" "$@"

# local development
serve:
	python2 -mSimpleHTTPServer

# recompile everything when I do anything
watch:
	while true; do \
    inotifywait -e modify "$(LESS)" "$(RESUME)" && make; \
	done;

.PHONY: serve watch pdf commit