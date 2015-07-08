#!/bin/sh

#==================================================#
# This script to update playlist in content server.#
# Script Last modified date : 29/12/2014           #
# Script Last modified by   : mahesh               #
#==================================================#

RSYNC_OPTIONS="-rav --delete"
SERVER="etomer@content.vyoma-media.com"

MASTERS_DIR="/opt/masters"
CHECK_UPDTAE_DIR="/opt/check_update"
PLAYLIST_SERVER_DIR="/opt/playlist"

PLAYLIST_LOCAL_DIR="/opt/content-update"

DATE=$(date +%d-%m-%Y)
TIME=$(date +%H:%M:%S)

TOTAL_MASTERS=0
LOG_FILE="/opt/content_server_update_${DATE}_${TIME}.log"

# fuction for rsync media from local pc to server.
rsync_playlist() {

    if [ -d "$PLAYLIST_LOCAL_DIR" ]; then

       if [ -d "$PLAYLIST_LOCAL_REGION_DIR" ]; then
          echo "Playlist upload started on ${DATE} ${TIME}" | tee -a $LOG_FILE
          rsync ${RSYNC_OPTIONS} ${PLAYLIST_LOCAL_DIR}/  ${SERVER}:${PLAYLIST_SERVER_DIR}/$SELECTED_REGION_NAME/
   
          if [ $? -eq 0 ]; then
             echo " " | tee -a $LOG_FILE
	     echo "*** Server playlist update completed. ****" | tee -a $LOG_FILE
          else
             echo " " | tee -a $LOG_FILE
             echo "*** Playlist updation FAILED..!!!, please try again...***" | tee -a $LOG_FILE
          fi
       else
          echo " " | tee -a $LOG_FILE
          echo "*** No folder found inside content-update for $SELECTED_REGION_NAME. ***"
          echo "Note: default folders [Mumbai,Gujrath-MUM01], [Banglore-BLR01], [Hyderabad-HYD01] and [Delhi-DEL01]."
       fi
    else
       echo " " | tee -a $LOG_FILE
       echo "*** content-update folder not found in /opt of your pc, please create. ***" | tee -a $LOG_FILE
    fi
}

# fuction handles main update process.
update_configure() {
    echo "Enter the number of playlist this time... [ please enter a number like 1 or 2.. etc ]" | tee -a $LOG
    read number

    if [ $number -gt 15 ]; then 
       echo "Sorry, more than 15 playlist at the same time is not possible." | tee -a $LOG_FILE
       exit 1
    else
       for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
       do
    
       if [ $i -le ${number} ]; then
          echo " " | tee -a $LOG_FILE
          echo "Select any one batch for playlist-${i}" | tee -a $LOG_FILE
          echo " " | tee -a $LOG_FILE
          list_playlist
          select_playlist
          echo " " | tee -a $LOG_FILE
          echo "Please select masters associated with $SELECTED_PLAYLIST" | tee -a $LOG_FILE
          echo "Use comma (,) for selecting multiple masters. eg:1,2,3..." | tee -a $LOG_FILE
          flag_creation
          echo " " | tee -a $LOG_FILE
          let TOTAL_MASTERS=($TOTAL_MASTERS+$masters_count)
          echo "Total $TOTAL_MASTERS masters set, and $masters_count masters set for $SELECTED_PLAYLIST"  | tee -a $LOG_FILE
          echo " " | tee -a $LOG_FILE
      fi
      done
      echo " " | tee -a $LOG_FILE
      echo "Update setup completed. Goodbye..." | tee -a $LOG_FILE
    fi
}

# function creates link between playlist and masters.
create_link() {
    ssh $SERVER "rm -f ${MASTERS_DIR}/$SELECTED_MASTER/playlist"

    if [ $? -eq 0 ]; then
    ssh $SERVER "ln -s ${PLAYLIST_SERVER_DIR}/$SELECTED_REGION_NAME/$SELECTED_PLAYLIST/playlist  ${MASTERS_DIR}/$SELECTED_MASTER/"

       if [ $? -eq 0 ]; then
          echo "...link created." | tee -a $LOG_FILE
       else
          echo "Link creation failed!.., please try again."
          exit 1
       fi
    else
       echo "Deleting old link failed!.., please try again."
       exit 1
    fi
}

# function setting flags for master ready for update.
flag_creation() {
    list_masters
    IFS=","
    masters_count=0
    read masters
    echo " " | tee -a $LOG_FILE
    echo "you are entered $masters" | tee -a $LOG_FILE         
    echo " " | tee -a $LOG_FILE
    echo "WARNING: Please make sure the masters list you entered for $SELECTED_PLAYLIST is correct."  | tee -a $LOG_FILE                
    echo "         Proceed? (y/n)"  | tee -a $LOG_FILE
    echo " " | tee -a $LOG_FILE
    read confirm_masters
    if [ $confirm_masters = 'y' ] || [ $confirm_masters = 'Y' ]; then

       for master in $masters
       do

         if [ $master -eq 0 ]; then
            echo " " | tee -a $LOG_FILE
            echo "Selection $master is not possible." | tee -a $LOG_FILE
            echo " " | tee -a $LOG_FILE
         else
            new_master=master-1
            SELECTED_MASTER="${master_names[$new_master]}"

            if [ ! -n "$SELECTED_MASTER" ]; then
               echo " " | tee -a $LOG_FILE
               echo "WARNING..!, your selection $master, may be wrong please check again."  | tee -a $LOG_FILE
               echo " " | tee -a $LOG_FILE
            else
               let masters_count=($masters_count+1)
               echo " " | tee -a $LOG_FILE
               echo "Setting update for : $master  $SELECTED_MASTER" | tee -a $LOG_FILE 
               create_link && ssh $SERVER "touch $CHECK_UPDTAE_DIR/$SELECTED_MASTER" && echo "...flag created." | tee -a $LOG_FILE
            fi
         fi
        done

    elif [ $confirm_masters = 'n' ] || [ $confirm_masters = 'N' ]; then
         echo "Please enter the masters again..." | tee -a $LOG_FILE                     
         flag_creation
    else
         echo "Wrong entry, please try again." | tee -a $LOG_FILE
    fi
}

# function for deleting a already created flag.
delete_flag() {
    list_flags
    IFS=","
    read selected_flags
    echo " " | tee -a $LOG_FILE
    echo "You are entered $selected_flags" | tee -a $LOG_FILE
 
    for flag in $selected_flags
    do
      if [ $flag -eq 0 ]; then
         echo " " | tee -a $LOG_FILE
         echo "Selection $flag is not possible." | tee -a $LOG_FILE
         echo " " | tee -a $LOG_FILE
      else
         new_flag=$flag-1
         SELECTED_FLAG="${flags[$new_flag]}"

         if [ ! -n "$SELECTED_FLAG" ]; then
            echo " " | tee -a $LOG_FILE
            echo "WARNING..!, your selection-$flag, may be wrong please check again." | tee -a $LOG_FILE
            echo " " | tee -a $LOG_FILE
         else   
            echo " " | tee -a $LOG_FILE
            echo "*** Deleting... $SELECTED_FLAG." | tee -a $LOG_FILE 
            ssh $SERVER  "rm -f $CHECK_UPDTAE_DIR/$SELECTED_FLAG" | tee -a $LOG_FILE
            echo "    Deleted." | tee -a $LOG_FILE
         fi
      fi
    done
}

# function for display playlists.

list_playlist() {
    echo "[ Please wait until showing Done!... ]" | tee -a $LOG_FILE
    echo " " | tee -a $LOG_FILE
    unset IFS
    playlist_folders=( `ssh $SERVER ls $PLAYLIST_SERVER_DIR/$SELECTED_REGION_NAME 2>/dev/null`)
                   
    if [ $? -eq 0 ]; then
       i=1

       for t in "${playlist_folders[@]}"
       do 
         playlist_xml=( `ssh $SERVER ls $PLAYLIST_SERVER_DIR/$SELECTED_REGION_NAME/$t/playlist/VTPLMedia/Config/ 2>/dev/null`)
         echo $i $t "   [ Version:" $playlist_xml " ] " | tee -a $LOG_FILE 
         let i=($i+1)
       done
       echo " " | tee -a $LOG_FILE
       echo "Done!." | tee -a $LOG_FILE
       echo " " | tee -a $LOG_FILE
    else
       echo " " | tee -a $LOG_FILE
       echo "*** Display playlist failed..!!!, please try again...***" | tee -a $LOG_FILE
       exit 1
    fi
}

# function for select playlist.
select_playlist() {
    read playlist_name		  

    if [ $playlist_name -le 15 ]; then

       if [ $playlist_name -eq 0 ]; then
          echo " " | tee -a $LOG_FILE
          echo "Selection $flag is not possible." | tee -a $LOG_FILE
          exit 1
       else
          new_playlist_name=$playlist_name-1                    
          SELECTED="${playlist_folders[$new_playlist_name]}"
                         
          if [ -z  $SELECTED ]; then
             echo " " | tee -a $LOG_FILE
             echo "WARNING..!, your selection - $playlist_name, may be wrong please check again." | tee -a $LOG_FILE
             exit
          else    
             echo " " | tee -a $LOG_FILE
             echo "you are selected $SELECTED." | tee -a $LOG_FILE
             SELECTED_PLAYLIST=$SELECTED
          fi
       fi
    else
       echo " " | tee -a $LOG_FILE
       echo "WARNING...!, you are entered a wrong value, plase try again." | tee -a $LOG_FILE
       exit 1
    fi
}

# function for list existing flags.
list_flags() {
    flags=( `ssh $SERVER "cd $CHECK_UPDTAE_DIR/ && ls $SELECTED_REGION 2>/dev/null"`)
    if [ $? -eq 0 ]; then
       echo " " | tee -a $LOG_FILE
       echo "*** Listing active updates for $SELECTED_REGION_NAME. ***" | tee -a $LOG_FILE  
       echo " " | tee -a $LOG_FILE
       i=1

       for f in "${flags[@]}"
       do
         echo $i $f | tee -a $LOG_FILE
         let i=($i+1)
       done
      
    else
       echo " " | tee -a $LOG_FILE
       echo "oops..., no active updates vailable for $SELECTED_REGION_NAME." | tee -a $LOG_FILE
       exit 1
    fi
}

# function for listing masters.
list_masters() {
    unset IFS  
    master_names=( `ssh $SERVER "cd $MASTERS_DIR && ls -d $SELECTED_REGION 2>/dev/null"` )

    if [ $? -eq 0 ]; then
       echo " " | tee -a $LOG_FILE
       echo "*** Listing all $SELECTED_REGION_NAME masters. ***" | tee -a $LOG_FILE
       echo " " | tee -a $LOG_FILE
       i=1

       for t in "${master_names[@]}"
       do
         echo $i $t | tee -a $LOG_FILE
         let i=($i+1)
       done
    else
        echo " " | tee -a $LOG_FILE
        echo "oops..., no masters vailable for $SELECTED_REGION_NAME." | tee -a $LOG_FILE
        exit 1
    fi
}

# function for listing regions.
select_region() {
    echo " " | tee -a $LOG_FILE
    echo "please select a region..." | tee -a $LOG_FILE
    echo " " | tee -a $LOG_FILE
    echo "Enter 1 for Banglore" | tee -a $LOG_FILE
    echo "Enter 2 for Mumbai" | tee -a $LOG_FILE
    echo "Enter 3 for Gujrat" | tee -a $LOG_FILE
    echo "Enter 4 for Hyderabad" | tee -a $LOG_FILE
    echo "Enter 5 for Delhi" | tee -a $LOG_FILE
    read region
    case $region in
         1)
         echo " " | tee -a $LOG_FILE
         echo "*** You are selected Banglore ***" | tee -a $LOG_FILE
         echo " " | tee -a $LOG_FILE
         SELECTED_REGION="Ka*"
         SELECTED_REGION_NAME="Banglore" 
         PLAYLIST_LOCAL_REGION_DIR="/opt/content-update/BLR01"
         ;;
         2)
         echo " " | tee -a $LOG_FILE
         echo "*** You are selected Mumbai ***" | tee -a $LOG_FILE
         echo " " | tee -a $LOG_FILE
         SELECTED_REGION="Mh*"
         SELECTED_REGION_NAME="Mumbai"
         PLAYLIST_LOCAL_REGION_DIR="/opt/content-update/MUM01"
         ;;
         3)
         echo " " | tee -a $LOG_FILE
         echo "*** You are selected Gujrat ***" | tee -a $LOG_FILE
         echo " " | tee -a $LOG_FILE
         SELECTED_REGION="Gj*"
         SELECTED_REGION_NAME="Mumbai"
         PLAYLIST_LOCAL_REGION_DIR="/opt/content-update/MUM01"
         ;;
         4)
         echo " " | tee -a $LOG_FILE
         echo "*** You are selected Hyderabad ***"  | tee -a $LOG_FILE
         echo " " | tee -a $LOG_FILE
         SELECTED_REGION="Ap*"
         SELECTED_REGION_NAME="Hyderabad"
         PLAYLIST_LOCAL_REGION_DIR="/opt/content-update/HYD01"
         ;;
         5)
         echo " " | tee -a $LOG_FILE
         echo "*** You are selected Delhi ***" | tee -a $LOG_FILE
         echo " " | tee -a $LOG_FILE
         SELECTED_REGION="Dl*"
         SELECTED_REGION_NAME="Delhi"
         PLAYLIST_LOCAL_REGION_DIR="/opt/content-update/DEL01"
         ;;
         *)       
         echo " " | tee -a $LOG_FILE
         echo " *** Wrong Selection, please try again... ***" | tee -a $LOG_FILE
         echo " " | tee -a $LOG_FILE
         exit 1
         ;;
    esac
}

# main function.
menu(){
    clear
    echo "Content Server Management." | tee -a $LOG_FILE
    echo "     Version : 0.1.0      " | tee -a $LOG_FILE
    echo ".........................." | tee -a $LOG_FILE
    echo " " | tee -a $LOG_FILE
    echo "started on ${DATE} ${TIME}" | tee -a $LOG_FILE
    echo " " | tee -a $LOG_FILE
    echo "Please select an operation" | tee -a $LOG_FILE
    echo " " | tee -a $LOG_FILE
    echo "Enter 1 for Playlist  upload." | tee -a $LOG_FILE
    echo "Enter 2 for Setup new update." | tee -a $LOG_FILE
    echo "Enter 3 for Remove given update." | tee -a $LOG_FILE
    echo "Enter 4 for List all active update."  | tee -a $LOG_FILE
    echo "Enter 5 for List available masters." | tee -a $LOG_FILE
    echo "Enter 6 for List current playlists." | tee -a $LOG_FILE
    echo "Enter 0 for Exit." | tee -a $LOG_FILE
}


whiptail menu
read option

case $option in
     1)
     echo " " | tee -a $LOG_FILE
     echo "*** You are selected playlist upload. ***" | tee -a $LOG_FILE
     select_region
     rsync_playlist
     echo " " | tee -a $LOG_FILE
     ;;
     2)
     echo " " | tee -a $LOG_FILE
     echo "*** You are selected New update setup. ***" | tee -a $LOG_FILE
     select_region
     update_configure
     echo " " | tee -a $LOG_FILE
     ;;
     3)
     echo " " | tee -a $LOG_FILE
     echo "*** You are selected Remove given update. ***" | tee -a $LOG_FILE
     select_region
     delete_flag
     echo " " | tee -a $LOG_FILE
     ;;
     4)
     echo " " | tee -a $LOG_FILE
     echo "*** You are selected List active updates. ***" | tee -a $LOG_FILE
     select_region
     list_flags
     echo " " | tee -a $LOG_FILE
     ;;
     5) 
     echo " " | tee -a $LOG_FILE
     echo "*** You are selected List available masters ***" | tee -a $LOG_FILE
     select_region
     list_masters
     echo " " | tee -a $LOG_FILE
     ;;
     6)
     echo " " | tee -a $LOG_FILE
     echo "*** You are selected List current playlist Version. ***" | tee -a $LOG_FILE
     select_region
     list_playlist     
     echo " " | tee -a $LOG_FILE
     ;;
     0)
     echo " " | tee -a $LOG_FILE
     echo "Exiting. Good bye..." | tee -a $LOG_FILE
     echo " " | tee -a $LOG_FILE
     exit 0
     ;;
     *)
     echo " " | tee -a $LOG_FILE
     echo "You entered a wrong option..." | tee -a $LOG_FILE
     echo " " | tee -a $LOG_FILE
     ;;
esac

