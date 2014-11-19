# Droidenv Initialization
function _get_target(){
    echo "Pick a target:"

    local i=1
    local e
    for e in "${(@k)DIR_TARGETS}"
    do
        echo "  $i. $e"
        i=$((i + 1))
    done

    echo ""
    read "target?Which target would you like? "
}

function _validate_target(){
    [ -z $target ] && return 1

    if [[ $target =~ '^[0-9]+$' ]]; then
        target=${${(@k)DIR_TARGETS}[$target]}
        [ ! -z $target ] && return 0;
    else
        local e
        for e in "${(@k)DIR_TARGETS}"; do [[ "$e" == "$target" ]] && return 0; done
    fi

    echo "Error: Invalid target"

    return 1
}

function _select_env(){
    target=$1
    [ -z $target ] && _get_target

    _validate_target $target || return 1

    echo "\nLoading environment : $target"

    TARGETDIR=$DIR_TARGETS[$target]
    TARGETLUNCH=$LUNCH_TARGETS[$target]

    [ -z $TARGETDIR ] && echo "Error: No directory provided for '$target'" && return 1
    [ ! -d $TARGETDIR ] && echo "Error: Directory '$TARGETDIR' does not exist" && return 1

    echo "Base directory      : $TARGETDIR"
    echo "Launch target       : $TARGETLUNCH\n"

    return 0
}

# Post-initialization Utility functions
function _compile_usage(){
    echo "Usage: $0 targets"
    echo "Valid targets:"

    for key in ${(k)COMPILE_TARGETS}; do printf "    %-15s - %s\n" $key $COMPILE_TARGETS[$key]; done
}

function _validate_compile_target() {
    [ ! "$#" -eq 1 ] && return 1

    for e in ${(@k)COMPILE_TARGETS}; do [[ "$e" == "$1" ]] && return 0; done

    return 1
}

function _build(){
    [ ! "$#" -eq 1 ] && return 1

    echo -e "\e[92m[+]\033[0m Building: $1"

    mmm -j4 $1
    if [ $? -ne 0 ]; then
        echo -e "\e[31m[-]\033[0m FAILED: $1"
        cd -
        kill -INT $$
    fi
}

function _gen_image(){
    echo -e "\e[92m[+]\033[0m Generating Image"

    make snod

    if [ $? -ne 0 ]; then
        echo -e "\e[31m[-]\033[0m Unable to generate image"
        cd -
        kill -INT $$
    fi

    echo -e "\e[92m[+]\033[0m Done!"
}

function compile(){
    [ "$#" -lt 1 ] && _compile_usage && return 1

    [ -z $ANDROID_BUILD_TOP ] && echo "Run 'droidenv' to initialize the environment" && return 1

    if [[ "$1" == "all" ]]; then
        cd $ANDROID_BUILD_TOP
        make -j4
        cd -
        return 0
    fi

    for arg in "$@"; do _validate_compile_target $arg || (echo "Error: invalid argument - $arg" && return 1); done

    cd $ANDROID_BUILD_TOP

    for arg in $@; do _build $COMPILE_TARGETS[$arg]; done

    _gen_image

    cd -
}

#Emulator Utilities
function _initsd(){
    [ -z $DROIDENV ] && echo "Error: \$DROIDENV not set" && return 1

    echo "Initializing emulator sdcard"
    mksdcard -l droidenv 1024M $DROIDENV/droidenv.img
    echo "done"
}

function emu(){
    [ -z $DROIDENV ] && echo "Error: \$DROIDENV not set" && return 1

    [ "$#" -ne 1 ] && echo "Usage: emu [on/off]" && return 1

    [ ! -f $DROIDENV/droidenv.img ] && _initsd

    if [ "$1" != "off" ]; then
        emulator -verbose -skin WXGA800 -sdcard $DROIDENV/droidenv.img -gpu on
    else
        emulator -verbose -skin WXGA800 -sdcard $DROIDENV/droidenv.img
    fi
}

# Load droidenv
[ -z "$DROIDENV" ] && echo "Error: \$DROIDENV not set" && return 1

[ ! -f $DROIDENV/targets.cfg ] && echo "Error: Missing config file: $DROIDENV/targets.cfg" && return 1

declare -A DIR_TARGETS
declare -A LUNCH_TARGETS
declare -A COMPILE_TARGETS

source $DROIDENV/targets.cfg

autoload bashcompinit; bashcompinit

alias droidenv='_select_env && cd $TARGETDIR && source ./build/envsetup.sh && lunch $TARGETLUNCH && cd -'

#Autocomplete
_compile_complete(){
    reply=( ${(k)COMPILE_TARGETS} )
}
compctl -K _compile_complete compile

_emu_complete(){
    reply=( on off )
}
compctl -K _emu_complete emu
