#!/bin/bash
# add -x on shebang for debug purpose

# Public routines - functions named with
#   Pascal_Snake_Case, meant to be 
#   called from other .sh script file.
#
# Private routines - functions named with 
#   _snake_case, meant to be called by 
#   functions in this script file.

#---------------------------------------------
# Public routines section
#---------------------------------------------

function Check_Test_Mode { 
#{{{1

    # check if in "Test" mode.
    # test mode is indicated by '-T' or '-t'

    # $@ all arguments passed to the main script
    # return "t" if Test_Mode, "f" if not

    # usage Test_Mode=$(Check_Test_Mode $@)
    # subsequently can just test with: 
    #     if [[ "$Test_Mode" == "t" ]];
 
    local _arguments=( "$@" )
    local _test_factors=( "-T" "-t" )
    echo $(_check_argument _test_factors _arguments)
#}}}
} 


function Print_Header_Banner {
#{{{1

    # $1 - test mode indicator, 't' for test mode
    # $2 - name of installation process 
    #
    # print main installation start message banner
    #
    # usage:
    #   Print_Header_Banner "$Test_Mode" "Raspberry Pi OS Setup"

    _print_header_banner $1 "\"$2 Started\""

#}}}
}


function Print_Footer_Banner {
#{{{1

    # $1 - name of installation process 
    #      (should match the $2 by Print_Header_Banner)
    #
    # print main installation end message banner
    #
    # usage:
    #   Print_Footer_Banner "Raspberry Pi OS Setup"

    _print_footer_banner "\"$1 Completed\""

#}}}
}


function Make_Directories {
#{{{1

    # $1 test mode indicator, 't' for test mode
    # $2 optional program name to be printed
    #    "" to skip and print default create directories message
    # $3... ($@ after shift 2) directories to be created (with parents)

    local _test_mode=$1
    local _msg="===> Creating directories" 
    [ ! -z "$2" ] && _msg="$_msg for $2" 
    shift 2

    # no error message is failed to make directories
    _execute_thru_files_list \
        $_test_mode \
        "mkdir -pv" \
        "$_msg" \
        "9" \
        "" \
        "$@"

#}}}
}


function Remove_Directories {
#{{{1

    # $1 test mode indicator, 't' for test mode
    # $2 optional program name to be printed
    #    "" to skip and print default copy file message
    # $3... ($@ after shift 2) directories to be removed (recursive/forced)

    local _test_mode=$1
    local _msg="===> Removing directories" 
    [ ! -z "$2" ] && _msg="$_msg for $2" 
    shift 2

    _execute_thru_files_list \
        $_test_mode \
        "rm -rfv" \
        "$_msg" \
        "2" \
        "not found" \
        "$@"
 
#}}}
}


function Copy_Files {
#{{{1

    # $1 test mode indicator, 't' for test mode
    # $2 optional program name to be printed
    #    "" to skip and print default copy file message
    # $3... ($@ after shift 2) combo of $_from $_to arrays
    #
    # usage: 
    # Copy_Files $_test_mode \
    #            $_msg \
    #            "${_from[@]}" \
    #            "${_to[@]}"
    #
    # IMPORTANT:
    # ASSUME the passed in array $2... can be split into two equal arrays


    local _test_mode=$1
    local _msg="===> Copying files/directories" 
    [ ! -z "$2" ] && _msg="$_msg for $2" 
    shift 2

    _execute_thru_files_pairs $_test_mode \
                              "cp -vr" \
                              "$_msg" \
                              $@

#}}}
}


function Backup_Files {
#{{{1

    # $1 test mode indicator, 't' for test mode
    # $2 optional program name to be printed
    #    "" to skip and print default backup file message
    # $3... ($@ after shift 2) combo of $_from $_to arrays
    #
    # usage: 
    # Backup_Files $_test_mode \
    #              $_msg \
    #              "${_from[@]}" \
    #              "${_to[@]}"
    #
    # IMPORTANT:
    # ASSUME the passed in array $2... can be split into two equal arrays


    local _test_mode=$1
    local _msg="===> Backup files/directories" 
    [ ! -z "$2" ] && _msg="$_msg for $2" 
    shift 2

    _execute_thru_files_pairs $_test_mode \
                              "cp -v -p" \
                              "$_msg" \
                              $@

    _execute_thru_files_pairs $_test_mode \
                              "rm -v -f" \
                              "" \
                              $@

#}}}
}


function Create_Symlinks {
#{{{1

    # $1 test mode indicator, 't' for test mode
    # $2 optional program name to be printed
    #    "" to skip and print default create symlink message
    # $3... ($@ after shift 2) combo of $_target $_link_name arrays
    #
    # usage: 
    # Create_Symlinks $_test_mode \
    #                 $_msg \
    #                 "${_target[@]}" \
    #                 "${_link_name[@]}"
    #
    # IMPORTANT:
    # ASSUME the passed in array $2... can be split into two equal arrays

    local _test_mode=$1
    local _msg="===> Creating symlinks" 
    [ ! -z "$2" ] && _msg="$_msg for $2" 
    shift 2

    _execute_thru_files_pairs $_test_mode \
                              "sudo ln -sfv" \
                              "$_msg" \
                              $@

#}}}
}


function Remove_Symlinks {
#{{{1

    # $1 test mode indicator, 't' for test mode
    # $2 optional program name to be printed
    #    "" to skip and print default create symlink message
    # $3... ($@ after shift 2) symlinks to be removed

    local _test_mode=$1
    local _msg="===> Removing symlinks" 
    [ ! -z "$2" ] && _msg="$_msg for $2" 
    shift 2


    # no error message is failed to make directories
    _execute_thru_files_list \
        $_test_mode \
        "rm -v" \
        "$_msg" \
        "3" \
        "" \
        "$@"

#}}}
}


function Execute {
#{{{1

    # construct arguments so that arguments with 
    # spaces can be passed on correctly

    local _p1=""
    local _p2=""
    local _p3=""
    if [ "$1" ]; then
        _p1="$1"
        if [ "$2" ]; then
            _p2="\"$2\""
            if [ "$3" ]; then
                _p3="\"$3\""
            fi
        fi
    fi

    _execute "$_p1" "$_p2" "$_p3"

#}}}
}


function Execute_Commands_List {
#{{{1

    # $1 test mode indicator, 't' for test mode
    # $2 messages to be printed
    # $3... ($@ after shift 2) Commands to execute

    local _test_mode=$1
    local _msg=$2
    shift 2

    _execute_commands_list \
        $_test_mode \
        "$_msg" \
        "$@"

#}}}
}


function Update_System {
#{{{1

    # perform a total system update
    # $1 test mode indicator, 't' for test mode

    local _test_mode=$1

    _execute $_test_mode \
             "sudo apt update && sudo apt upgrade -y" \
             "===> Updating system software" 

#}}}
}

#---------------------------------------------
# Private routines section
#---------------------------------------------

function _print_header_banner {
#{{{1

    # clock start time
    # print installation start message banner
    #
    # $1 test mode indicator, 't' for test mode
    # $2... ($@ after shift 1) header banner messages
    #
    # Note: messages with space in between should be
    #       passed in with surround quotes, eg. ""\"$msg\""
    #       else every space will be printed on a new line
    #
    # usage: 
    #   _print_header_banner $_test_mode \
    #                        "\"$_message_with_space\"" \
    #                        "$_message_with_no_space"

    local _test_mode=$1
    shift 1

    SECONDS=0

    echo -e ""
    echo -e "$READ ============================================$NORM"

    for _msg in "$@"; do
        echo -e "$INFO $(_strip_quotes "$_msg") $NORM"
    done

    if [[ "$_test_mode" == "t" ]]; then
        echo -e "$DEBUG Currently in TEST MODE $NORM"
        echo -e "$DEBUG No Actual Installation $NORM"
    fi

    echo -e "$READ ============================================$NORM"
    echo -e ""

#}}}
}


function _print_footer_banner {
#{{{1

    # calculate elapsed time
    # print installation end message banner with elapsed time
    #
    # $@ footer banner messages
    #
    # Note: messages with space in between should be
    #       passed in with surround quotes, eg. ""\"$msg\""
    #       else every space will be printed on a new line
    #
    # usage: 
    #   _print_footer_message "\"$_message_with_space\"" \
    #                         "$_message_with_no_space"

    local _duration=$SECONDS
    local _elapsed=""
    if [[ "$_duration" -gt "60" ]]; then
        _elapsed="$(( _duration / 60 )) minutes and "
    fi 
    _elapsed="$_elapsed$(( _duration % 60 )) seconds"

    echo -e "$READ ============================================$NORM"

    for _msg in "$@"; do
        echo -e "$INFO $(_strip_quotes "$_msg") $NORM"
    done

    echo -e "$READ Elapsed Time: $_elapsed.                    $NORM"
    echo -e "$READ ============================================$NORM"
    echo -e ""

#}}}
}


function _execute {
#{{{1

    # print message and execute the command to install
    # only echo the command if in test mode
    # $1 - test mode indicator, 't' for test mode
    # $2 - command to execute
    # $3 - optional message to be printed as $INFO

    local _test_mode=$1

    # only print non empty message line
    if [ ! -z "$3" ]; then
        local _msg=$(_strip_quotes "$3")
        echo -e "$INFO $_msg $NORM"
    fi

    # only print command if test mode, else execute it
    local _command=$(_strip_quotes "$2")
    if [[ "$_test_mode" == "t" ]]; then
        echo -e "$DEBUG Command to execute is:"
        echo -e "$DEBUG $_command $NORM"
    else
        eval "$_command"
    fi

    # empty line at end of execution
    echo -e ""

#}}}
}


function _strip_quotes {
#{{{1

    # Remove leading and trailing double quotes
    # of the passed in string $1 if any and
    # return the result as an echoed string
    local _str="${1#\"}"
    echo "${_str%\"}"

#}}}    
}


function _check_items {
#{{{1

    local _pass="f"

    # perform check on item if required
    case $1 in
        1)
            [ -f $2 ] && _pass="t" ;;

        2)
            [ -d $2 ] && _pass="t" ;;

        3)
            [ -L $2 ] && _pass="t" ;;

        4)
            [ -e $2 ] && _pass="t" ;;

        9)
            [ ! -e $2 ] && _pass="t" ;;

        *)
            _pass="f" ;;
    esac

    [ "$1" = "" ] && _pass="t"

    echo "$_pass"

#}}}
}


function _execute_thru_files_pairs {
#{{{1

    # $1 - test mode indicator, 't' for test mode
    # $2 - command to execute on every pair of from..to
    # $3 - optional message to be printed as $INFO
    #      "" to skip
    # $4... ($@ after shift 3) combo of $_from $_to arrays
    #
    # usage: 
    # _execute_thru_files_pairs $_test_mode \
    #                           "ln -svf" \
    #                           "Creating Symlink" \
    #                           "${_from[@]}" \
    #                           "${_to[@]}"
    #
    # IMPORTANT:
    # ASSUME the passed in array $4 ... can be split into two equal arrays

    local _test_mode=$1
    local _cmd=$2
    local _msg=$3
    shift 3

    # split into 2 equal size array 
    local _input=("$@")
    local _len=$(( ${#_input[@]} / 2 ))
    local _from=("${_input[@]:0:$_len}")
    local _to=("${_input[@]:$_len}")

    # print verbose messages
    if [ ! -z "$_msg" ]; then
        echo -e "$INFO $_msg $NORM"
    fi

    if [[ "$_test_mode" == "t" ]]; then
        # echo -e "$DEBUG Command to execute is: $NORM"
        local _debug_msg="$DEBUG Command to execute is: $NORM\n"
    fi

    # loop thru arrays, construct the full command 
    # line and execute/print it
    local _full_command_line
    for i in "${!_to[@]}"; do

        # construct full command line
        _full_command_line="$_cmd ${_from[$i]} ${_to[$i]}"

        if [[ "$_test_mode" == "t" ]]; then
            echo -e "$_debug_msg$DEBUG $_full_command_line $NORM"
            # clear the string so no more one time msg
            _debug_msg="" 
        fi

        # check file node exist before executing the command
        if [ -e ${_from[$i]} ]; then  
            if [[ "$_test_mode" != "t" ]]; then
                eval "$_full_command_line"
            fi
        else
            echo -e "$WARN ${_from[$i]} does not exist $NORM"
        fi
    done

    # spacing line at end of execution
    echo -e ""

#}}}
}


function _execute_thru_files_list {
#{{{1

    # $1 - test mode indicator, 't' for test mode
    # $2 - command to execute on every element of array
    # $3 - optional message to be printed as $INFO
    #      "" to skip
    # $4 - optional check on array elements
    #      "" no check
    #      "1" check if file exist
    #      "2" check if directory exist
    #      "3" check if symlink exist
    #      "4" check if filenode exist (directory/file/link)
    #      "9" check if filenode does not exist (directory/file/link)
    # $5 - optional error message to be appended after item name
    #      "" to disable
    # $6... ($@ after shift 4) array to be acted on
    #
    # usage: 
    # _execute_thru_files_list \
    #   $_test_mode \
    #   "rm -rfv" \
    #   "Removing Directories" \
    #   "2" \
    #   "${_dirs[@]}" 
    #
    # IMPORTANT:
    # There would be no test on the items array,
    # as such it is up to the calling function
    # to perform the checks, and display/surpress
    # any error messages
    
    local _test_mode=$1
    local _cmd=$2
    local _msg=$3
    local _chk=$4
    local _err_msg=$5
    shift 5
    local _items=("$@")

    # print verbose messages
    if [ ! -z "$_msg" ]; then
        echo -e "$INFO $_msg $NORM"
    fi

    # Using a variable to ensure this line 
    # will be onl printed once, IF there
    # is any action to be executed.
    if [[ "$_test_mode" == "t" ]]; then
        local _debug_msg="$DEBUG Command to execute is: $NORM\n"
    fi

    # loop thru arrays, construct the full command 
    # line and execute/print it
    local _full_command_line
    for i in "${!_items[@]}"; do

        # construct command and execute on item
        _full_command_line="$_cmd ${_items[$i]}"

        if [[ "$_test_mode" == "t" ]]; then
            echo -e "$_debug_msg$DEBUG $_full_command_line $NORM"
            # clear the string so no more one time msg
            _debug_msg="" 
        fi

        # perform a check on the item before executing command
        if [ "$(_check_items "$_chk" "${_items[$i]}")" = "t" ]; then
            if [[ "$_test_mode" != "t" ]]; then
                eval "$_full_command_line"
            fi
        else
            if [[ ! -z $_err_msg ]]; then
                echo -e "$WARN ${_items[$i]} $_err_msg $NORM"
            fi
        fi

    done

    # spacing line at end of execution
    echo -e ""

#}}}
}


function _execute_commands_list {
#{{{1

    # $1 - test mode indicator, 't' for test mode
    # $2 - optional message to be printed as $INFO
    #      "" to skip
    # $3... ($@ after shift 2) array to be acted on
    #
    # usage: 
    # _execute_commands_list \
    #   $_test_mode \
    #   "Setting up git" \
    #   "${_commands[@]}" 
    #
    
    local _test_mode=$1
    local _msg=$2
    shift 2
    local _commands=("$@")

    # print verbose messages if not blank
    if [ ! -z "$_msg" ]; then
        echo -e "$INFO $_msg $NORM"
    fi

    # Using a variable to ensure this line 
    # will be onl printed once, IF there
    # is any action to be executed.
    if [[ "$_test_mode" == "t" ]]; then
        local _debug_msg="$DEBUG Command to execute is: $NORM\n"
    fi

    # loop thru commands list, print if test mode
    # else execute
    for i in "${!_commands[@]}"; do
        if [[ "$_test_mode" == "t" ]]; then
            echo -e "$_debug_msg$DEBUG ${_commands[$i]} $NORM"
            # clear the string so no more one time msg
            _debug_msg="" 
        else
            eval "${_commands[$i]}"
        fi
    done

    # spacing line at end of execution
    echo -e ""

#}}}
}


function _check_argument { 
#{{{1

    # check if any of the element of  __test_factors 
    # array is in __arguments array.
    # return "t" if found, "f" if none

    # $1 - test factors array, passed in by nameref
    # $2 - arguments array, passed in by nameref
    # return "t" if found, "f" if none

    # usage result=$(_check_argument _test_factor _arguments)
    # note: _test_factor and _arguments would be name of 
    #       variables in calling function, passed in by nameref
    #       but non of them would be altered in this function
 

    local -n __test_factors=$1
    local -n __arguments=$2
    local _found="f"

    for i in "${!__arguments[@]}"; do
        for j in "${!__test_factors[@]}"; do
            if [[ ${__test_factors[$j]} == ${__arguments[$i]} ]]; then
                _found="t"
                break
            fi
        done
        [ $_found == "t" ] && break
    done

    echo "$_found"

#}}}
} 


