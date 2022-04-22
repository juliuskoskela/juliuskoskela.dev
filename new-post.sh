# Create a new post with appropriate date and time.

echo "Insert title of the post:"
read -p "title: " title

echo "Insert tags for the post (comma separated):"
read -p "tags: " tags

filedate=$(date '+%Y-%m-%d')
filename=$(echo $title | sed -e 's/[\t ]\+/-/g')
filename=content/posts/$filedate-$filename.md

touch $filename
echo "---" >> $filename
echo "title: $title" >> $filename
echo "tags: [$tags]" >> $filename
echo "date:" $filedate >> $filename
echo "draft: false" >> $filename
echo "---" >> $filename
