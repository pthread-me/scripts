#!/usr/bin/bash

#-----------------------------------------------------------------------------
# Contsants
#-----------------------------------------------------------------------------
GREEN="\e[0;32m"
BLACK="\e[0;30m"
RED="\e[0;31m"
WHITE="\e[0;37m"
CLEAN_LINE="\033[2K"
RESET_CURSOR="\r"

##-----------------------------------------------------------------------------
## Funcs
##-----------------------------------------------------------------------------
function notify_cleanup () {
  if [[ "$*" =~ -S ]]; then
    printf "$%bSafe mode is ON.\n" ${RED};
    printf "%bENV setup failed will begin deleting created file\n" ${RED}; 
    printf "%bIf you dont want to accidentaly lose shit, you have 10 second to stop this\n" $RED;
    i=10;
    while [[ $i -ge 0 ]]; do
      (( i-- ));
      sleep 1
      printf "%b%b" $CLEAN_LINE $RESET_CURSOR
    done;
  fi;
};

function fail_cleanup () {
	rm -r src include CMakeLists.txt 2>/dev/null
}


##-----------------------------------------------------------------------------
## Default vals
##-----------------------------------------------------------------------------

# create files
debug_mode=false
main="main.cpp"

##-----------------------------------------------------------------------------
##      SCRIPT START
##-----------------------------------------------------------------------------

if [[ $* =~ -h ]]; then
  printf "%b" $WHITE
  printf " -d to enable Debug mode\n"
  printf " -D to delete created files\n"
  printf " -S enable safe cleanup (gives you buffer before any deletion to cancel)\n"
  printf " -n Custom main.cpp name, must end in .cpp/.cxx\n"
  exit 0
fi;

# env prep
if [[ $# < 1 ]]; then
  echo "%bMUST provide a project name" $RED
  exit 1
fi;


if [[ $* =~ -n ]]; then
  main=$(echo $* | grep -Po "\-n \K[a-z0-9A-Z_]+\.(cpp|cxx)")
  if [[ ${#main} = 0 ]]; then
    printf "%bBad file name format, must be [a-zA-Z0-9_] .cpp or cxx\n" $RED
    exit 1
  fi;
fi;


printf "%bCreating structure:\n"
touch CMakeLists.txt;
mkdir -p include;
mkdir -p src;
touch src/${main};

if [[ $* =~ -D ]]; then
  notify_cleanup
  fail_cleanup
  printf "%bDeleted\n" $GREEN
  exit 0
fi

if [[ ! -d "src" ]] || [[ ! -d "include" ]]; then
  echo "could not create src/ and include/"
	notify_cleanup $*
	fail_cleanup
fi;


if [[ $* =~ "-d" ]]; then
  debug_mode=true
fi;




echo "cmake_minimum_required(VERSION 4.0)
project($1)

set(CMAKE_EXPORT_COMPILE_COMMANDS on)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED on)
set(CMAKE_BUILD_TYPE Debug)

add_executable(main src/$main)
target_include_directories(main PRIVATE \${CMAKE_SOURCE_DIR}/lib/include)
" > CMakeLists.txt;


echo "#include <ranges>

using ll =  long long;
using ull =  unsigned long long;

namespace srv = std::ranges::views;
namespace sr = std::ranges;
namespace sv = std::views;

int main(){

}
" > src/$main;

printf "%bCreated\n" ${GREEN}
printf "%bRunning Cmake once\n" ${WHITE}

echo 

cmake -Bbuild
cmake --build build


printf "%bDone\n" ${GREEN}

exit 0
