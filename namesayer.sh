#!/bin/bash
showMainMenu() {
    clear
    echo "=============================================================="
    echo "Welcome to NameSayer"
    echo -e "=============================================================="
    echo -e "Please select from one of the following options:\n"
    echo "	(l)ist existing creations"
    echo "	(p)lay an existing creation"
    echo "	(d)elete an existing creation"
    echo "	(c)reate a new creation"
    echo "	(q)uit authoring tool"
    echo ""
    mainMenuPrompt
}

mainMenuPrompt() {
    read -p "Enter a selection [l/p/d/c/q]: " select
    case $select in
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
			clear
			echo "Quitting Namesayer"
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
    read -p "Choose a (#) number to delete or (q)uit to the main menu: " delete
    case $delete in
        [qQ] | [qQ][uU][iI][tT])
            showMainMenu
        ;;
        *)
            if [ "$delete" -eq "$delete" ] && ! [ -z "$delete" ]; then
                if [ $delete -gt ${#files[@]} ] || [ $delete -eq '0' ]; then
                    deleteCreation
                else
                    delete=$((delete - 1))
                    read -p "Please enter the creation name to confirm its deletion: " confirm
                    cd ./lib/
                    confirm="${confirm}.mkv"
                    if [ "${files[$delete]}" == "$confirm" ]; then
                        rm "${files[$delete]}" 2> /dev/null
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
        ;;
    esac
}

playCreation() {
    clear
    printListofCreations
    read -p "Choose a (#) number to play or (q)uit to the main menu: " play
    case $play in
        [qQ] | [qQ][uU][iI][tT])
            showMainMenu
        ;;
        *)
            if [ $play -eq $play 2>/dev/null ]; then
                if [ $play -gt ${#files[@]} 2>/dev/null ] || [ -z "$play" ] || [ "$play" -eq '0' ]; then
                    playCreation
                else
                    play=$((play - 1))
                    ffplay -autoexit ./lib/"${files[$play]}" &> /dev/null
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
    file_count=$(eval $"ls -l | grep -v ^l | wc -l")
    if [ $file_count -gt 1 ]; then
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
    
    read -p "Give a name to your creation: " name
    if [ -z $name 2> /dev/null ]; then
        echo "Please enter a valid input."
        createCreation
    else
        if [ -f ./lib/"$name".mkv ]; then
            echo "Creation with this name already exists"
            createCreation
        fi
        
        recordAudio "$name"
        ffmpeg -f lavfi -i color=c=white:s=1920x1080:d=5 -vf "drawtext=fontsize=60: \
        fontcolor=black:x=(w-text_w)/2:y=(h-text_h)/2:text='$name'" ./lib/"$name"_video.mkv 2>/dev/null
        
        ffmpeg -i ./lib/"$name"_video.mkv -i ./lib/"$name"_audio.mkv -codec copy -shortest \
        ./lib/"$name".mkv 2> /dev/null
        
        rm ./lib/"$name"_video.mkv 2>/dev/null
        rm ./lib/"$name"_audio.mkv 2>/dev/null
        
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
    read -p "Would you like to (l)isten to the recording, (k)eep it or (r)edo it? " option
    case $option in
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
    
    directory=./lib
    if [ ! -d "$directory" ]; then
        mkdir -p $directory
    fi
}

clear
checkStorageDirExists
showMainMenu
