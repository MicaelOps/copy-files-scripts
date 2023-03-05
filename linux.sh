#!/bin/sh
# Author: Micael Cossa

# Defines the character that is going to separate the strings in the file
SEPARATOR=" "

# Boolean values tracker
BOOLEAN_TRUE=0
BOOLEAN_FALSE=1

readonly SEPARATOR 
readonly BOOLEAN_TRUE
readonly BOOLEAN_FALSE 

# Checks if Folder exists and it is a folder
doesFolderExist(){
    if [ -d "$1" ]; then
        return $BOOLEAN_TRUE
    else
        return $BOOLEAN_FALSE
    fi
}

# Checks if file exists and it is not a folder
doesFileExist(){
    if [ -f "$1" ]; then
        return $BOOLEAN_TRUE
    else
        return $BOOLEAN_FALSE
    fi
}

# Checks if the destination folder exists and asks the user if he wants to overwite
# Expected Parameters
# $1 = Destination folder
checkOverwrite(){
    
    doesFolderExist "$1"
    
    RET=$?
    
    if [ $RET == $BOOLEAN_TRUE ]; then
        
        echo "Destination folder exists!"
        echo "Do you wish to overwrite existing contents? (y/n)"
        read OVERWRITE_STR
        
        if [ $OVERWRITE_STR == "y" ]; then

            echo "Overwritting..."
        
            return $BOOLEAN_TRUE
        else
            return $BOOLEAN_FALSE
        fi
    else
        return $BOOLEAN_TRUE
    fi 
}
# Copies all contents of one folder to another
# Expected paramters :
# $1 = source folder
# $2 = destination folder
# $3 = overrite (BOOLEAN_TRUE or BOOLEAN_FALSE)
copyContents() {
    
    if [ $3 == $BOOLEAN_TRUE ]; then
        cp -v -r $1 $2
    else
        cp -v -r -n $1 $2
    fi
    echo "All files have been written."
}

# Program starts here

# Checks if there are no arguments 
if [ $# == 0 ]; then # No arguments provided

    # variable that tracks whether the user inputted correct source and destination folders.
    CORRECTFOLDERS=$BOOLEAN_FALSE

    SRC=""
    DEST=""
    
    # A while loop to persist the user to input correct values
    while [ $CORRECTFOLDERS == $BOOLEAN_FALSE ] 
    do
        echo "Please input the source folder "
        read SRC
        
        doesFolderExist $SRC
        RET=$?
        
       
        if [ $RET == $BOOLEAN_FALSE ]; then
            echo "Invalid source folder"
            continue
        fi
        
        echo "Please input the destination folder "
        
        doesFolderExist $DEST
        read DEST
        
        RET=$?
        
        if [ $RET == $BOOLEAN_FALSE ]; then
            echo "Invalid destination folder"
            continue
        fi
        
        
        CORRECTFOLDERS=$BOOLEAN_TRUE  
    done
    
    #check if it needs to be overwritten
    checkOverwrite $DEST
    
    RET2=$?
    
    copyContents "$SRC" "$DEST" $RET2
    
    unset SRC
    unset DEST
    unset RET2
    unset CORRECTFOLDERS


elif [ $# == 1 ]; then # There is only one argument
    
    doesFileExist $(readlink -f $1)
    
    RET=$? # Return value
    
    if [ $RET == $BOOLEAN_TRUE ]; then # Checks whether the file exists and it is a regular file
    
        #whereis $1 # Moves to the directory of the file 
    
        echo "$1 was found."
        echo "Reading file...."
        
        # Removes variable.
        unset RET
        
        # Reads line by line and separates each line with the " " and returns a string array
        # Expected format: "source dest"
        while IFS= read -r patharray
        do
            echo "executed"
            if [ ${#patharray[@]} != 2 ]; then # checks the array to see if there are exactly 2 arguments (src,dst)
                echo "Invalid format detected on the file."
            else 
            
                # Checks if source folder exists
                doesFolderExist "${patharray[0]}"
                RET1=$?
                
                # Checks if source folder exists
                if [ $RET1 == $BOOLEAN_FALSE ]; then
                    echo "Invalid locattions provided"
                else
                
                    # Checks if the user wants to overwrite destination folder if exists.
                    checkOverwrite "${patharray[1]}"
                    
                    # Returns BOOLEAN_TRUE or BOOLEAN_FALSE
                    RET2=$?
                    copyContents "${patharray[0]}" "${patharray[1]}" $RET2
                    
                    unset RET2
                fi
                unset RET1
            fi 
        done < $(readlink -f $1)  

        echo "Operation completed."
    else
        echo "Please input the path of a file that exists and is not a folder."
    fi


# More than one argument provided
else
    echo "Too many arguments! Please only input one file"
fi


