#!/bin/bash

       if [ ! -f temp  ]; then
              touch temp;
       fi

       # Zero out all files relevant to final next url parser.
function reset() {
       for i in `echo "next_urls source_urls temp Album_ID_list Photo_ID_list tmp Photo_url tmp_urls"`; do
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
        #cat tmp && sleep 10; # <- DEBUG 
}; get_albums;

echo -e "Left function get_albums.\n";

final=0; # Initialize final. Set it to zero.
while [[ ! $final == 1 ]]; do
        echo -e "Entering loop.\n";
        # If next and previous links are not present then just push the tmp file from above into the Album_ID_list file
        # and break the loop by setting final to 1.
        if [[ ! `cat Album_ID_list | egrep -o next` && ! `cat Album_ID_list | egrep -o previous` ]]; then
		cat tmp > Album_ID_list;
		final=1;
        # If next link is found inside of the Album_ID_parser then wget it and save it to the albums~ file. 
        # This is important because it is the entry point to our recursion algorithm. Then it calls the get_albums() function once again.
        elif [[ `cat Album_ID_list | egrep -o next` ]]; then
              echo -e "Next link found.\n";
              wget `cat Album_ID_list | egrep "^next.*$" | sed 's/next://g'` -O albums~ && get_albums;
        # This statement checks if any previous links are present and whether next links are absent. If this statement evaluates as true then  
        # that means that this is the end of the JSON linking and there are no more objects to be grabbed or handed.
        elif [[ `cat Album_ID_list | egrep -o previous` && ! `cat Album_ID_list | egrep -o next` ]]; then
              echo > Album_ID_list && echo -e "`cat tmp | sed 's/^[previous|next].*$//g;/^$/d'`" >> Album_ID_list;
              final=1;
        fi
done

echo -e "Left loop.\n";

cp Album_Names Album_Names~;

echo -e "Copied album_names to album_names~\n";

readarray -t album_id_list < <(cat Album_ID_list);
echo -e "Read Album_ID_list into array\n";

# NEED TO APPLY THE ABOVE RECURSIVE PARSING ALGORITHM TO THE FUNCTION BELOW!
function grab_albums() {
echo -e "Entering function grab_albums\n";
       for i in "${album_id_list[@]}"; do
              wget "https://graph.facebook.com/$i/photos?access_token=$token_string" -O "Photostream_Album_$i" &&
              echo $token_string > token_string;
              chmod a+rwx "Photostream_Album_$i";
              cat "Photostream_Album_$i" >> "Photostream_photos";
       done
}; grab_albums;

cp Photostream_photos Photostream_photos~;

echo -e "Leaving function grab_albums\n";

reset;
echo -e "resetting\n";

echo -e "copy Photostream_photos~ to temp\n";
cat Photostream_photos~ > temp;

echo -e "copying Photostream_photos to Photostream_photos~";
cp Photostream_photos Photostream_photos~;

function get_photos() {
       echo -e "Entering function get_photos\n";
       sed -i 's/},{/\n},{\n/g;s/"\n/",/g;s/,/,\n/g;s/\("created_time\)/\1/g;s/}}$/\n/g' Photostream_photos~
       #cat Photostream_photos~ | egrep "^\"source" | sed 's/\"\|,\|\\//g;s/source://g' | egrep -v "[a-z0-9\.\-]*\/[a-z][0-9]*x[0-9]*" > source_urls;
       cat Photostream_photos~ | egrep "^\"source" | sed 's/\"\|,\|\\//g;s/source://g' | egrep -o "^https.*[a-z]720[a-z]720.*$" > source_urls;
       ##cat Photostream_photos~ | egrep "^\"next" | sed 's/\"\|,\|\\//g;s/next://g;s/}}//g;s/{data.*$//g' > next_urls; ## DO NOT DELETE!!!
       cat Photostream_photos~ | egrep "^\"(next|previous)" | sed 's/\"\|,\|\\//g;s/}}//g;s/{data.*$//g' > next_urls;
       #sed -i 's/\/photos?access_token=/?fields=photos{source}\&access_token=/g' next_urls
       #cat next_urls >> Photostream_photos~;
}; get_photos;

final=0
while [[ ! $final == 1 ]]; do
       for i in `cat next_urls | sed 's/\/photos?access_token=/?fields=photos{source}\&access_token=/g'`; do
              ##wget "$i" -O Photostream_photos~ && sleep 1 && cat Photostream_photos~ >> tmp_urls; # DO NOT DELETE!!
              #if [[ `wget -S --spider $(echo $i | egrep "next.*$" | sed 's/next://g') -O Photostream_photos~ && cat Photostream_photos~ >> tmp_urls 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then 
              wget `echo $i | egrep "next.*$" | sed 's/next://g'` -O Photostream_photos~ && cat Photostream_photos~ >> tmp_urls; 
                     echo -e "Downloading ${i}\n";
                     sleep 1;
              #fi
              #get_photos;
       done
       final=1;
       echo -e "Final = $final.\n";
done

<<begin
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
begin

























echo -e "Leaving function get_photos\n";




<<COMMENT
       final=0; 
       while [[ ! $final == 1 ]]; do
              if [[ ! `cat Photo_ID_list | egrep -o next` && ! `cat Photo_ID_list | egrep -o previous` ]]; then
                     cat tmp > Photo_url;
                     final=1;
              elif [[ `cat Photo_ID_list | egrep -o next` ]]; then
                     echo -e "Next link found.\n";
                     wget `cat Photo_ID_list | egrep "^next.*$" | sed 's/next://g'` -O Photostream_photos~ && get_photos;
              elif [[ `cat Photo_ID_list | egrep -o previous` && ! `cat Photo_ID_list | egrep -o next` ]]; then
                     echo > Photo_url && echo -e "`cat tmp | sed 's/^[previous|next].*$//g;/^$/d'`" >> Photo_url;
                     final=1;
              elif [[ `cat Photo_ID_list | egrep -o source` ]]; then
                     cat Photostream_photos~ | egrep "^\"source" | sed 's/\"\|,\|\\//g;s/source://g' | egrep -v "[a-z0-9\.\-]*\/[a-z][0-9]*x[0-9]*" >> source_urls;
              fi
       done
#done
COMMENT


<<NOTE
if you cat next urls and take a url for example:

https://graph.facebook.com/v2.4/205920726246194/photos?access_token=CAAOtWQNXd2ABANozFwAF3vPBvwHLDiJxnFaMBiCaqCIzSC4ZA5vb9xRZBW2tIdM26ZAGzOxEFIqd3uRAKA4N3TLFlMOHMc62iHuAM2PrSfw7AoyuJXZBICtNolN7XZCdBa9pIkGdzy2fo18hP7decrr9ZBmP5ViJdRgcCb0LtLyy4eUFNBtYaPQFIZAJprXmNRUob6ZAXebb9N6H517c3LMC&fields=idu00252Cnameu00252Cpicture&limit=25&after=MTI3NDUzMDE3NDI2Mjk5}}

and modify it to look like this:
https://graph.facebook.com/v2.4/205920726246194?fields=photos{source}&access_token=CAAOtWQNXd2ABANozFwAF3vPBvwHLDiJxnFaMBiCaqCIzSC4ZA5vb9xRZBW2tIdM26ZAGzOxEFIqd3uRAKA4N3TLFlMOHMc62iHuAM2PrSfw7AoyuJXZBICtNolN7XZCdBa9pIkGdzy2fo18hP7decrr9ZBmP5ViJdRgcCb0LtLyy4eUFNBtYaPQFIZAJprXmNRUob6ZAXebb9N6H517c3LMC

The you can get the next source and next urls:
https://scontent.xx.fbcdn.net/hphotos-xtp1/v/t1.0-9/1395296_203857659785834_2116670839_n.jpg?oh=a08bbb5f9d4e525d61f17a0f3b68d168&oe=56792ADE
the link without the pXXXxXXX is the one we need

this will play the above changes -> sed 's/\/photos?access_token=/?fields=photos{source}&access_token=/g' next_urls

NEED TP APPLY RECURSION HERE AT THIS POINT

NOTE
