#!/bin/bash

	if [ ! -f temp  ]; then
		touch temp;  
	fi

	# Zero out all files relevant to final next url parser.
	for i in `echo "next_urls source_urls temp"`; do 
		echo > $i;
	done

cp albums albums~

#Retreive album ID's.
function get_album_ids() {
	cat albums~ | egrep -o '\"id\":\"[0-9]*\",\"from\"' | sed 's/\(\"id\":\"\)\([0-9]*\)\(\",\".*$\)/\2/g' > Album_ID_list;
	cp Album_Names Album_Names~;
}; get_album_ids;

# Retreive album names
function get_album_names() {
	cat albums~ | egrep -o '\"name\":\"[a-zA-Z0-9 ]*\"}\,\"name\":\"[a-zA-Z0-9 ]*\"' | awk '{gsub(/\"/,"")} FS=":" {print $3}'  > Album_Names;
	cp Album_ID_list Album_ID_list~;
}; get_album_names;

readarray -t album_id_list < <(cat Album_ID_list);

function grab_albums() {
	for i in "${album_id_list[@]}"; do
		wget "https://graph.facebook.com/$i/photos?access_token=$token_string" -O "Photostream_Album_$i" &&
		chmod a+rwx "Photostream_Album_$i";
		cat "Photostream_Album_$i" >> "Photostream_photos";
	done

	cp Photostream_photos Photostream_photos~; 
}; grab_albums;

# Remove unecessary files.
find . -name "Photostream_Album_[0-9]*" -exec rm -rf {} \;

cat Photostream_photos~ > temp;

###### START OF SEPERATOR ######
function next_parser() {
        cat temp | egrep -o --color "next\":\"[A-Za-z0-9:\/.?_=]*&limit=25" | sed 's/\(next\":\"\)//g' | awk '{gsub(/\\/,""); print}';
};

# Next urls
function next_url() { 
        next_parser >> next_urls;
}; next_url;
    
function source_parser() {
        cat temp | egrep --color -o "source\":\"[A-Za-z0-9.:\/_-]*_n.jpg\?\_[A-Za-z0-9_]*=[A-Za-z0-9&_]*=[A-Za-z0-9&_]*=[A-Za-z0-9]*" | sed 's/\(source\":\"\)//g' | awk '{gsub(/\\/,""); print}';
};  
    
# Source urls
function source_url() {
        source_parser >> source_urls;
}; source_url;
###### END OF SEPERATOR ######

function reset() {
	echo > temp;
}; reset;

function final_next_parser() {

	for i in `cat next_urls 2>/dev/null`; do 
		# Escapes the forward slashes on each iteration of the loop to allow you to pass the variable to sed.
		mod_string=$(echo $i | awk '{gsub(/\//, "\\/"); print}')

		if [[ ! $mod_string == `echo $mod_string | egrep "http.*\-used"` ]]; then 

			# While the current line in next_urls file is not equal to EOF
			wget $i -O temp && sed -i "s/$mod_string/$mod_string-used/g" next_urls;
			# Parse next urls from temp file
			next_url;
			# Parse source urls from temp file
			source_url;
		fi
	done
}; final_next_parser;
