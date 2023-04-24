#!/bin/bash
# Author: Micael Cossa

# Boolean values tracker for clarity
BOOLEAN_TRUE=0
BOOLEAN_FALSE=1

# Enables file descriptor 3 for reading (Avoid collusion)
exec 3<> /dev/stdin

readonly BOOLEAN_TRUE
readonly BOOLEAN_FALSE 

# Checks if Folder exists and it is a folder
doesFolderExist() {
    if [ -d "$1" ]; then
        return $BOOLEAN_TRUE
    else
        return $BOOLEAN_FALSE
    fi
}

# Checks if file exists and it is not a folder
doesFileExist() {
    if [ -f "$1" ]; then
        return $BOOLEAN_TRUE
    else
        return $BOOLEAN_FALSE
    fi
}

#asks the user if he wants to overwite
# Expected Parameters
# $1 = Destination folder
checkOverwrite() {
   
    read -u 3 -p "Do you wish to overwrite existing contents? (y/anything) " OVERWRITE_STR

    if [ "$OVERWRITE_STR" = "y" ]; then
        echo "Overwritting..."
        return $BOOLEAN_TRUE
    else
        return $BOOLEAN_FALSE
    fi
}
# Copies all contents of one folder to another
# Expected paramters :
# $1 = source folder
# $2 = destination folder
# $3 = overrite (BOOLEAN_TRUE or BOOLEAN_FALSE)
copyContents() {
    
    if [ $3 -eq $BOOLEAN_TRUE ]; then
        cp -r "$1" "$2"
    else
        cp -r -n "$1" "$2"
    fi
    echo "All files have been written."
}

# Program starts here
# Checks if there are no arguments 
if [ $# -eq 0 ]; then # No arguments provided

    # variable that tracks whether the user inputted correct source and destination folders.
    CORRECTFOLDERS=$BOOLEAN_FALSE

    SRC=""
    DEST=""
    RET2=$BOOLEAN_TRUE
    
    # A while loop to persist the user to input correct values
    while [ $CORRECTFOLDERS -eq $BOOLEAN_FALSE ] 
    do
        echo "Please input the source folder "
        read SRC
        
        doesFolderExist $SRC
        RET=$?
        
       
        if [ $RET -eq $BOOLEAN_FALSE ]; then
            echo "Invalid source folder"
            continue
        fi
        
        echo "Please input the destination folder "

        read DEST
            
        doesFolderExist "$DEST"

        RET=$?

	    # Check if destination folder exists
        if [ $RET -eq $BOOLEAN_FALSE ]; then
            mkdir "$DEST"
        else
            # Checks if the user wants to overwrite destination folder.
            checkOverwrite "$dest"
            RET2=$?
        fi
        
        CORRECTFOLDERS=$BOOLEAN_TRUE  
    done
    
    copyContents "$SRC/." "$DEST" $RET2
    
    unset SRC
    unset DEST
    unset RET2
    unset CORRECTFOLDERS


elif [ $# -eq 1 ]; then # There is only one argument
    
    doesFileExist "$(readlink -f $1)"
    
    RET=$? # Return value
    
    if [ $RET -eq $BOOLEAN_TRUE ]; then # Checks whether the file exists and it is a regular file
    
        #whereis $1 # Moves to the directory of the file 
    
        echo "$1 was found."
        echo "Reading file...."
        
        # Removes variable.
        unset RET

        # Reads line by line and separates each line with the " " and returns a string array
        # Expected format: "source dest"
        while IFS=" " read -r src dest
        do
		
            # checks to see if its a valid source
            if [ "$src" != "" ]; then
            
                # Checks if source folder exists
                doesFolderExist "$src"

		        RET1=$?
                
                # Checks if source folder exists
                if [ $RET1 -eq $BOOLEAN_FALSE ]; then
                    echo "Invalid source locattion provided"
                else
                    
                    doesFolderExist "$dest"

                    RET2=$?

                    # Making sure it copies the contents to an existing folder
                    if [ $RET2 -eq $BOOLEAN_FALSE ]; then
                        mkdir "$dest"
                    fi
                    
                    # Checks if the user wants to overwrite destination folder.
                    checkOverwrite "$dest"

                    RET3=$?
                    
                    # Copies Contents
                    copyContents "$src/." "$dest" $RET3                
                    
                    
                    unset RET3
                fi
                unset RET1
            fi 
        done < "$(readlink -f $1)"  

        echo "Done."

    else
        echo "Please input the path of a file that exists and is not a folder."
    fi

# More than one argument provided
else
    echo "Too many arguments! Please only input one file"
fi



