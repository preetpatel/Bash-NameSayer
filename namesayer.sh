#!/bin/bash
showMainMenu() {
    clear
    echo "=============================================================="
    echo "Welcome to NameSayer"
    echo "=============================================================="
    echo ""
    echo "Please select from one of the following options:\n"
    echo ""
    echo "	(l)ist existing creations"
    echo "	(p)lay an existing creation"
    echo "	(d)elete an existing creation"
    echo "	(c)reate a new creation"
    echo "	(q)uit authoring tool"
    echo ""
    mainMenuPrompt
}

mainMenuPrompt() {
    read -p "Enter a selection [l/p/d/c/q]: " SELECT
    case $SELECT in 
		[lL] | [lL][iI][sS][tT])
		    listCreations
	    	;;
		[pP] | [pP][lL][aA][yY])
		    playCreation
		    ;;
		[dD] | [dD][eE][lL][eE][tT][eE])
		    deleteCreation
		    ;;
		[cC] | [cC][rR][eE][aA][tT][eE])
		    createCreation
		    ;;
		[qQ] | [qQ][uU][iI][tT])
		    exit
		    ;;
		*)
	    	mainMenuPrompt
	    	;;
    esac
}

deleteCreation() {
    clear
    printListofCreations
    read -p "Choose a (#) number to delete or (q)uit to the main menu: " DELETE
    case $DELETE in
		[qQ] | [qQ][uU][iI][tT])
	    	showMainMenu
	    	;;
		*)
			if [ "$DELETE" -eq "$DELETE" ]; then
			if ! [ "$DELETE" == '' ]; then 	
			if [ $DELETE -gt ${#files[@]} ]; then
	    		deleteCreation
			else
				DELETE=$((DELETE - 1))
				read -p "Please enter the creation name to confirm its deletion: " confirm 
				cd ./lib/
				confirm="${confirm}.mkv"
				if [ "${files[$DELETE]}" == "$confirm" ]; then 
				rm "${files[$DELETE]}" 2> /dev/null
				echo -e "File has been deleted\n"
				    read -n 1 -s -r -p "Press any key to return to the main menu "
				else
				    echo "That did no match the requested deletion file"
				    read  -n 1 -s -r -p "Press any key to retry "
				   cd ..
				   deleteCreation

				fi
				cd ..
        		showMainMenu
    		fi
		else
		    deleteCreation
		fi
		else 
		    deleteCreation
		fi
    		;;
    esac
}

playCreation() {
    clear
    printListofCreations
    read -p "Choose a (#) number to play or (q)uit to the main menu: " PLAY
    case $PLAY in
		[qQ] | [qQ][uU][iI][tT])
		    showMainMenu
		    ;;
		*)
			if [ $PLAY -eq $PLAY 2>/dev/null ]; then
			if [ $PLAY -gt ${#files[@]} 2>/dev/null ] || [ -z "$PLAY" ]; then
	    		playCreation
			else
				PLAY=$((PLAY - 1))
				ffplay -autoexit ./lib/"${files[$PLAY]}" &> /dev/null
        		showMainMenu
			fi
			else
			    playCreation
			fi
    		;;
    esac
}

printListofCreations() {

    cd ./lib/
    FILE_COUNT=$(eval $"ls -l | grep -v ^l | wc -l")
    if [ $FILE_COUNT -gt 1 ]; then
		count=1
		files=[]
		for mkv in *.mkv; do 
	    	echo "($count) "${mkv%.*}""
	    	files[$((count - 1))]=$mkv
	    	count=$((count + 1))
		done
		cd ..
	else 
		cd ..
		echo "No creations exist. You can create one from the Main Menu"
		read  -n 1 -s -r -p "Press any key to go back to the Main Menu "
    	clear
    	showMainMenu
    fi
    
	echo ""
}

listCreations() {
    clear
    echo "List of all Creations:"
    printListofCreations 
    read  -n 1 -s -r -p "Press any key to go back to the Main Menu "
    clear
    showMainMenu

}

createCreation() {
	
	read -p "Give a name to your creation: " NAME
	if [ -z $NAME 2> /dev/null ]; then 
	    echo "Please enter a valid input."
	    createCreation
	else
	if [ -f ./lib/"$NAME.mkv" ]; then	
	    echo "Creation with this name already exists"
	    createCreation
	fi

        recordAudio "$NAME"
	ffmpeg -f lavfi -i color=c=white:s=1920x1080:d=5 -vf "drawtext=fontsize=60: \
	fontcolor=black:x=(w-text_w)/2:y=(h-text_h)/2:text='$NAME'" ./lib/"$NAME"_video.mkv 2>/dev/null 

 	ffmpeg -i ./lib/"$NAME"_video.mkv -i ./lib/"$NAME"_audio.mkv -codec copy -shortest ./lib/"$NAME".mkv 2> /dev/null

	rm ./lib/"$NAME"_video.mkv 2>/dev/null
	rm ./lib/"$NAME"_audio.mkv 2>/dev/null

	read  -n 1 -s -r -p "Creation successful. Press any key to return to the main menu. "
	clear
	showMainMenu
	fi
}

recordAudio() {
    
	echo "Please record your voice saying $1 loud and clear. You will have 5 seconds to do this."
	read  -n 1 -s -r -p "Press any key to start recording the audio "
	echo -e "\nRecording... You have 5 seconds"
	ffmpeg -t 5 -f alsa -ac 2 -i default ./lib/"$1"_audio.mkv 2> /dev/null
    listenToAudio "$1"
}

listenToAudio() {
    
	echo ""
	read -p "Would you like to (l)isten to the recording, (k)eep it or (r)edo it? " OPTION
    case $OPTION in 
		[lL] | [lL][iI][sS][tT][eE][nN])
		    echo "Playing sound"
		    ffplay -nodisp -t 5 -autoexit ./lib/"$1"_audio.mkv 2> /dev/null
		    listenToAudio "$1"
		    ;;
		[rR] | [rR][eE][dD][oO])
		    rm ./lib/"$1"_audio.mkv
		    recordAudio "$1"
		    ;;
		[kK] | [kK][eE][eE][pP])
		    ;;
		*)
		    listenToAudio "$1"
		    ;;
    esac
}


checkStorageDirExists() {

    DIRECTORY=./lib
    if [ ! -d "$DIRECTORY" ]; then
		mkdir -p $DIRECTORY
    fi
}

clear
checkStorageDirExists
showMainMenu
