#!/bin/bash

       if [ ! -f temp  ]; then
              touch temp;
       fi

       # Zero out all files relevant to final next url parser.
function reset() {
       for i in `echo "next_urls source_urls temp Album_ID_list Photo_ID_list tmp"`; do
              echo > $i;
       done
};

reset;

cp albums albums~
function get_albums() {
        echo -e "Entering function.\n";
        # Formats text to json without tabs
        sed -i 's/},{/\n},{\n/g;s/"\n/",/g;s/,/,\n/g;s/\("created_time\)/\1/g;s/}}$/\n/g' albums~;
        # Parses album IDs and next/previous url
        cat albums~ | egrep -i "\"(next|previous).*$|\"id.*$" | sed 's/^\"id":"\|",$\|\\//g;s/"}],\|"$//g;s/"next":"/next:/g;s/"previous":"/previous:/g' > Album_ID_list;
        cat Album_ID_list >> tmp;
}; get_albums;

echo -e "Left function.\n";

final=0;
while [[ ! $final == 1 ]]; do
        echo -e "Entering loop.\n";
        if [[ ! `cat Album_ID_list | egrep -o next` && ! `cat Album_ID_list | egrep -o previous` ]]; then
		cat tmp > Album_ID_list;
		final=1;
        elif [[ `cat Album_ID_list | egrep -o next` ]]; then
              echo -e "Next link found.\n";
              wget `cat Album_ID_list | egrep "^next.*$" | sed 's/next://g'` -O albums~ && get_albums;
        elif [[ `cat Album_ID_list | egrep -o previous` && ! `cat Album_ID_list | egrep -o next` ]]; then
              echo > Album_ID_list && echo -e "`cat tmp | sed 's/^[previous|next].*$//g;/^$/d'`" >> Album_ID_list;
              final=1;
        fi
done

echo -e "Left loop.\n";

cp Album_Names Album_Names~;

readarray -t album_id_list < <(cat Album_ID_list);

# NEED TO APPLY THE ABOVE RECURSIVE PARSING ALGORITHM TO THE FUNCTION BELOW!
function grab_albums() {
       for i in "${album_id_list[@]}"; do
              wget "https://graph.facebook.com/$i/photos?access_token=$token_string" -O "Photostream_Album_$i" &&
              chmod a+rwx "Photostream_Album_$i";
              cat "Photostream_Album_$i" >> "Photostream_photos";
       done

       cp Photostream_photos Photostream_photos~;
}; grab_albums;

reset;

cat Photostream_photos~ > temp;

<<COMMENT1
for i in `ls | egrep -i "photostream_album_[0-9]*$"`; do

       test_album=$i
       cp $test_album $test_album~

       function get_photos() {
              sed -i 's/},{/\n},{\n/g;s/"\n/",/g;s/,/,\n/g;s/\("created_time\)/\1/g;s/}}$/\n/g' $test_album~
              cat $test_album~ | egrep -i "\"(next|previous).*$|\"id.*$" | sed 's/^\"id":"\|",$\|\\//g;s/"}],\|"$//g;s/"next":"/next:/g;s/"previous":"/previous:/g' > Photo_ID_list;
              cat Photo_ID_list >> tmp;
       }; get_photos;

       final=0; 
       while [[ ! $final == 1 ]]; do
              if [[ ! `cat Photo_ID_list | egrep -o next` && ! `cat Photo_ID_list | egrep -o previous` ]]; then
                     cat tmp > Photo_ID_list;
                     final=1;
              elif [[ `cat Photo_ID_list | egrep -o next` ]]; then
                     echo -e "Next link found.\n";
                     wget `cat Photo_ID_list | egrep "^next.*$" | sed 's/next://g'` -O $test_album~ && get_photos;
              elif [[ `cat Photo_ID_list | egrep -o previous` && ! `cat Photo_ID_list | egrep -o next` ]]; then
                     echo > Photo_ID_list && echo -e "`cat tmp | sed 's/^[previous|next].*$//g;/^$/d'`" >> Photo_ID_list;
                     final=1;
              fi
       done
done
COMMENT1
