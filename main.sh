#!/bin/bash
set -e

# FILE ARGUMENT
FILENAME=$1
if [ -z "$FILENAME" ]; then
    echo "Please insert a file name"
    exit 1
fi
echo "Processing $FILENAME..."
TEMP_FILE="temp.uml"
touch $TEMP_FILE

# Check for PlantUML installation
command -v plantuml >/dev/null 2>&1 && echo "PlantUML installed, proceeding..." || { echo "PlantUML is not installed. Please install to proceed"; exit 1; }

# Check and make while loop
i=1
while IFS= read -r LINE
do
    # If start of UML diagram
    if [[ "$LINE" == *@startuml* ]]; then
        echo "$LINE" > $TEMP_FILE
        INSIDE_DIAGRAM=true
        DIAGRAM_NAME=$(echo "$LINE" | cut -d' ' -f2)
        echo "Generating $DIAGRAM_NAME..."
    # If end of UML diagram
    elif [[ "$LINE" == *@enduml* ]]; then
        echo "$LINE" >> $TEMP_FILE
        INSIDE_DIAGRAM=false
        # Generate SVG
        plantuml -tsvg -o . $TEMP_FILE
        ((i=i+1))
    # If inside UML diagram
    elif [[ "$INSIDE_DIAGRAM" == true ]]; then
        echo "$LINE" >> $TEMP_FILE
    fi
done < "$FILENAME"

rm $temp_file
