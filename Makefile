PREF=2020-NaaktgeborenC+SilvaRKO-FTAF

clean:
	for EXT in log aux blg bbl out toc dvi; do \
		rm -vf ${PREF}.$$EXT; \
	done

cc/%.pdf: cc/%.svg
	inkscape \
		--export-type=pdf \
		--export-pdf-version=1.4 \
		--export-filename=$@ \
		$<

fig/%.pdf: fig/%.svg
	inkscape \
		--export-type=pdf \
		--export-pdf-version=1.4 \
		--export-filename=$@ \
		$<

%.ps: fig/%.pdf
	inkscape \
		--export-type=ps \
		--export-filename=$@ \
		$<

${PREF}.pdf: ${PREF}.tex 0*tex PreprintVersion.tex \
		cc/by.pdf \
		bibfile.bib
	pdflatex --enable-write18 ${PREF}.tex
	bibtex ${PREF}
	pdflatex --enable-write18 ${PREF}.tex
	pdflatex --enable-write18 ${PREF}.tex

