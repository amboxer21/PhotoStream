#!/bin/bash
# SIZE => cat Photostream_photos | egrep --color "source\":\"https:\\\/\\\/[A-Za-z0-9.]+\\\/[A-Za-z0-9-]+\\\/[A-Za-z0-9]+\\\/[A-Za-z0-9\.-]+\/[A-Za-z0-9]+"
cp albums albums~
cat albums | grep -o '\(\"id\":\)\(\"[0-9]*\"\)' | awk -F ":" '{gsub(/\"/,"");print $2}' | sed 'n;d' > Album_ID_list
cat albums | grep -o '\(\}\,\"name\":\"[A-Za-z0-9 ]*\"\)' | awk 'FS=":" {gsub(/\"/,"");print $2}' > Album_Names;

cp Album_Names Album_Names~;
cp Album_ID_list Album_ID_list~;

readarray -t array < <(cat Album_ID_list);

for i in "${array[@]}"; do
  wget "https://graph.facebook.com/$i/photos?access_token=$token_string" -O "Photostream_Album_$i" &&
  chmod a+rwx "Photostream_Album_$i";
  cat "Photostream_Album_$i" >> "Photostream_photos";
done

# Backup Photostream_photos
cp Photostream_photos Photostream_photos~ && echo -e "Finished backing up Photostream_photos\n";

# Next urls
cat Photostream_photos | egrep -o --color "next\":\"[A-Za-z0-9:\/.?_=]*&limit=25" | sed 's/\(next\":\"\)//g' | awk '{gsub(/\\/,""); print}' > next_urls

# Source urls
cat Photostream_photos | egrep --color -o "source\":\"[A-Za-z0-9.:\/_-]*_n.jpg" | sed 's/\(source\":\"\)//g' | awk '{gsub(/\\/,""); print}' > source_urls
