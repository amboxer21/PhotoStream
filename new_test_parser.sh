#!/bin/bash

touch temp;
cat Photostream_photos > temp;

## START OF SEPERATOR
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
## END OF SEPERATOR

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
		if ( `echo $i` == "END_of_FILE" ); then
			echo -e "EOF Reached\n";
		else
			#wget $i -O temp;
			echo -e "${i}\n";
		fi
	done
}; final_next_parser;
