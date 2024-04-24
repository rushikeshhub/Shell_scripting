#!/bin/bash

#################### In this script we accepting user deails and disabling,deleting,archiving the user data ###########

# Checking is running scropt with admin preveliges

if [[ "${UID}" -ne 0 ]]
then
	echo  " Please run script with ROOT USER " >&2
	exit 1

fi

readonly ARCHIVE_DIR='/archive'

# writing all functions 

usage()
{
	echo "Usage : ${0} [-dra] USER [USERS]..." >&2
	echo "Disabling linux  local account " >&2
	echo " -d Deleting account " >&2
	echo " -r removing account with home file directories" >&2
	echo " -a Archivinghome directory assosiated with account" >&2
	exit 1
}


# parsing the option 

while getopts dra OPTION
do
	case ${OPTION} in 
		d) DELETE_ACCOUNT='true' ;;
		r) REMOVE_OPTION='-r' ;;
		a) ARCHIVE_ACCOUNT='true' ;;
		?) usage ;;
	esac
done


shift "$(( OPTIND - 1 ))"

# check user passed atleast one argument 

if  [[ "${#}" -lt 1 ]]
then 
	usage 
fi

# looping through all USRNAME

for USERNAME in "${@}"
do
	echo "Pasersing USERNAME : ${USERNAME}"

	# checking user id is greater than 1000

	USERID=$(id -u ${USERNAME})

	if [[ "${USERID}" -lt 1000 ]]
	then
		echo "Refusing to remove ${USERNAME} with id ${USERID}" >&2
		exit 1
	fi

	if [[ "${ARCHIVE_ACCOUNT}" = 'true' ]]
	then
		if [[ ! -d "${ARCHIVE_DIR}" ]]
		then
			echo "Creating ${ARCHIVE_DIR} directory"
			mkdir -p ${ARCHIVE_DIR}
			if [[ "${?}" -ne  0 ]]
			then
				echo "Achive directory ${ARCHIVE_DIR} is not created" >&2
				exit 1
			fi
		fi

		# Archib=ving the HOME directory and moving it to archive folder

		HOMEDIR="/home/${USERNAME}"
		ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"

		if [[  -d "${HOMEDIR}" ]]
		then
			echo " Archiving ${HOMEDIR} to ${ARCHIVE_DIR}"

			tar -zcf ${ARCHIVE_FILE} ${HOMEDIR} &> /dev/null

			if [[ "${?}" -ne 0 ]]
			then
				echo " Could not create ${ARCHIVE_FILE}" >&2
				exit 1
			fi
		else
			echo " ${HOMEDIR} No such file or directory " >&2
			exit 1
		fi
        fi	
       
	

        if [[ "${DELETE_ACCOUNT}" =  'true' ]]
        then
	     userdel ${REMOVE_OPTION} ${USERNAME}
	     if [[ "${?}" -ne 0 ]]
             then
                 echo " USER ${USERNAME} not able to delete" >&2
                 exit 1
	     fi
           
	     echo " USER ${USERNAME} deleted succesfully "
        else
	     chage -E 0 ${USERNAME}

	     if [[ "${?}" -ne 0 ]]
             then
                 echo " USER ${USERNAME} not able to disabled" >&2
                 exit 1
             fi
             echo " USER ${USERNAME} disabled succesfully "
	fi
	

done
