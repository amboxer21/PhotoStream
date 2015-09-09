#!/bin/bash

       if [ ! -f temp  ]; then
              touch temp;
       fi

       # Zero out all files relevant to final next url parser.
function reset() {
       for i in `echo "next_urls source_urls temp Album_ID_list tmp"`; do
              echo > $i;
       done
};

#cp albums albums~

reset;

function get_albums() {
        cp albums albums~
        # Formats text to json without tabs
        sed -i 's/},{/\n},{\n/g;s/"\n/",/g;s/,/,\n/g;s/\("created_time\)/\1/g;s/}}$/\n/g' albums~;
        # Parses album IDs and next/previous url
        cat albums~ | egrep -i "\"(next|previous).*$|\"id.*$" | sed 's/^\"id":"\|",$\|\\//g;s/"}],\|"$//g;s/"next":"/next:/g;s/"previous":"/previous:/g' > Album_ID_list;
        cat Album_ID_list >> tmp;
        # Zeros out albums~ file 
        echo > albums~;
}; 

final=0;
while [[ ! $final == 1 ]]; do
        if [[ ! `cat Album_ID_list | egrep -o previous` ]]; then
              echo $final;
              get_albums && wget `cat Album_ID_list | egrep -o "http.*$"` -O albums;
              sleep 3;
        elif [[ `cat Album_ID_list | egrep -o previous` ]]; then
              cat tmp | egrep -v "^(previous|next)" > Album_ID_list;
              final=1;
        fi
done

cp Album_Names Album_Names~;

readarray -t album_id_list < <(cat Album_ID_list);

# NEED TO APPLY THE ABOVE RECURSIVE PARSING ALGORITHM TO THE FUNCTION BELOW!
#function grab_albums() {
#       for i in "${album_id_list[@]}"; do
#              wget "https://graph.facebook.com/$i/photos?access_token=$token_string" -O "Photostream_Album_$i" &&
#              chmod a+rwx "Photostream_Album_$i";
#              cat "Photostream_Album_$i" >> "Photostream_photos";
#       done

#       cp Photostream_photos Photostream_photos~;
#}; grab_albums;

for i in "${album_id_list[@]}"; do
        wget "https://graph.facebook.com/$i/photos?access_token=$token_string" -O "Photostream_Album_$i";
        chmod a+rwx "Photostream_Album_$i";
done
