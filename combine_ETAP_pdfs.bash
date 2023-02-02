#!/bin/bash

# Combine PDF files, output in a CombinedFiles subdirectory
# sudo apt-get install ghostscript

# files should be in current directory
# ls *Appl* gives list of applicants

outdir=CombinedFiles
if [ ! -d "$outdir" ]; then
	mkdir $outdir
fi

#allow spaces in file names
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

for f in $(ls *Appl*) 
do
	#echo file $f
	basename=`echo $f | sed -e 's/_Appl.*//' `
	shortbase=`echo $basename | sed -e 's/ //' -e 's/_[0-9]*\([0-9][0-9]\)/\1/' `
	#echo basename $basename
	#echo shortbase $shortbase
	echo Processing $shortbase
	gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=tmp.pdf $basename*

	# make bookmarks file
	pg=1
	rm -f $shortbase.info
	for g in $basename*pdf
	do
		title=`echo $g | sed -e 's/^.*_//' -e 's/.pdf//'`
		echo $title
		echo "[/Title ($title) /Page $pg /OUT pdfmark" >> $shortbase.info
		gpgs=`pdfinfo $g | grep Pages | sed 's/.* \([0-9]\)$/\1/'`
		pg=`expr $pg + $gpgs`	
	done

	gs -sDEVICE=pdfwrite -q -dBATCH -dNOPAUSE -sOutputFile=$outdir/$shortbase.pdf -dPDFSETTINGS=/prepress $shortbase.info -f tmp.pdf
	rm -f tmp.pdf
	
done

IFS=$SAVEIFS

