SRC = index

all: test $(SRC).html slides.html

slides.html: $(SRC).md makefile
	pandoc --mathjax -t revealjs -s -o $@ $< -V revealjs-url=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.6.0 -V theme=moon

$(SRC).html: $(SRC).pmd
	pweave --format=md2html $(SRC).pmd
	# Hack to remove padding from first line of code blocks
	sed -i -e "s/padding: 2px 4px//g" $(SRC).html

$(SRC).md: $(SRC).pmd
	pweave --format=pandoc $(SRC).pmd

$(SRC).py: $(SRC).pmd
	ptangle $(SRC).pmd

$(SRC).pdf: $(SRC).html
	chromium-browser --headless --print-to-pdf=$(SRC).pdf $(SRC).html
	
run: $(SRC).py
	python3 $(SRC).py

test: $(SRC).py
	cat testhead.py $(SRC).py > $(SRC)-test.py

	# Hack to prevent multiprocessing on module import
	sed -i -e "s/from multiprocessing/from multiprocessing.dummy/g" $(SRC)-test.py
	
	python3 -m doctest $(SRC)-test.py

clean:
	rm -f $(SRC).pdf $(SRC).md $(SRC).py $(SRC)-test.py $(SRC).html slides.html
	rm -rf figures
	rm -rf __pycache__