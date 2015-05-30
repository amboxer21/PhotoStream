#!/bin/bash

	if [ ! -f temp  ]; then
		touch temp;  
	fi

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
        next_parser > next_urls;
}; next_url;
    
function source_parser() {
        cat temp | egrep --color -o "source\":\"[A-Za-z0-9.:\/_-]*_n.jpg" | sed 's/\(source\":\"\)//g' | awk '{gsub(/\\/,""); print}';
};  
    
# Source urls
function source_url() {
        source_parser > source_urls;
}; source_url;
###### END OF SEPERATOR ######

function append_to_next_urls() {
	echo "END_of_FILE" >> next_urls;
}; 

function reset() {
	echo > temp;
};

function final_next_parser() {
  reset;
  append_to_next_urls;

	for i in `cat next_urls 2>/dev/null`; do 
		if [[ `echo $i` == "END_of_FILE" ]]; then
			echo -e "EOF Reached\n";
		else
			wget $i -O temp;
			#echo -e "${i}\n";
      			sed "s/$i//g"
		fi
	done
}; final_next_parser;
