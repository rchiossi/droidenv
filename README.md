# DroidEnv

Android development utility functions

### Usage

* **droidenv** : Initialize the environment for a given target
* **compile**  : Compile the entire tree (make -j4) or subfolders (mmm <folder> && make snod)
* **emu**      : Run emulator

### Install

Clone the repo
```sh
git clone https://github.com/rchiossi/droidenv ~/.droidenv
```

Define the itens bellow in your .zshrc
```sh
export DROIDENV=~/.droidenv
source $DROIDENV/droidenv.zsh
```

### Config file
Before using droidenv you need to create a config file with your targets and combo.
```sh
touch $DROIDENV/targets.cfg
```

Bellow is an example of a config file for targets for kitkat and lollipop, as well as build targets for framework services and surface flinger
```sh
#Env Dir and Targets
DIR_TARGETS+=( "kitkat" "~/android/kitkat/" )
LUNCH_TARGETS+=( "kitkat" "aosp_arm-eng" )

DIR_TARGETS+=( "lollipop" "~android/lollipop/" )
LUNCH_TARGETS+=( "lollipop" "aosp_x86-eng" )

#Compile Targets
COMPILE_TARGETS+=( "services" "frameworks/base/services/java" )
COMPILE_TARGETS+=( "surfaceflinger" "frameworks/native/services/surfaceflinger" )
```

The above setup will add two entries to **droidenv** command - kitkat and lollipop - and two entries to **compile** command - services and surfaceflinger.
