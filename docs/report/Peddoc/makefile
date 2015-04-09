target = arm_report
WITH_INDEX = Yes
WITH_GLOSSARY = Yes
WITH_BIBTEX = No
latex_SOURCES = $(target).tex *.tex
html = html
all: $(target).pdf
.PHONY: clean
%.pdf: $(latex_SOURCES)
	pdflatex $(target)
	pdflatex $(target)

ifeq ($(WITH_INDEX),Yes)
	@echo "*"
	@echo "* Running makeindex for index..."
	@echo "*"
	makeindex -s ${target}.idx $(target)
endif

ifeq ($(WITH_BIBTEX),Yes)
	@echo "*"
	@echo "* Running bibtex..."
	@echo "*"
	bibtex $(target)
endif

ifeq ($(WITH_GLOSSARY),Yes)
	@echo "*"
	@echo "* Running makeindex for glossary..."
	@echo "*"
	makeindex -s $(target).ist -t $(target).glg -o $(target).gls $(target).glo
endif

	pdflatex $(target)
	pdflatex $(target)
	thumbpdf --modes pdftex $(target).pdf
	pdflatex $(target)

clean:
	-rm -rf tmp.tmp *.tpt $(html)/* $(target).ps $(target).dvi $(target).pdf *.bbl *.lol *.lof *.lpr *.blg *.ist *.bst *.cfg *.nls *.nlo *.lot *.aux Inhalt/*.aux *.toc *.idx *.ind *.ilg *.log *.out *.brf *.cb *~ thumb* *.rtf *.backup Inhalt/*.backup Bilder/*.log Inhalt/*.log ./*.gls ./*.glg ./*.glo ./*.glsdefs ./*.acn

