#!/usr/bin/env bash

##
## This script will help you build openjdk7 on Centos 6.5
##

BASEDIR=$(cd `dirname $0`; pwd)

. $BASEDIR/build.conf

USER=`whoami`

function prepare_pkgs()
{
    echo "Install some packages..."
    sudo yum -y groupinstall 'base'
    sudo yum -y install make alsa-lib-devel cups-devel libXi-devel gcc gcc-c++ libX*
}

function install_freetype()
{
    echo "Install freetype... "
    sudo mkdir -p /usr/local/include/freetype2/freetype/internal
    sudo tar -zxvf $BASEDIR/resources/freetype-2.3.12.tar.gz -C /tmp
    sudo chown -R $USER /tmp/freetype-2.3.12
    cd /tmp/freetype-2.3.12
    ./configure
    make clean && make
    sudo make install
    rm -rf /tmp/freetype-2.3.12
    cd $BASEDIR
}

function install_ant()
{
    echo "Install ant"
    cd $BASEDIR/resources
    unzip apache-ant-1.7.1-bin.zip
    sudo mv apache-ant-1.7.1 $ANT_INSTALL_PATH
    sudo ln -s $ANT_INSTALL_PATH/bin/ant /usr/bin/ant
}

function install_jdk6()
{
    echo "Install jdk6"
    cd $BASEDIR/resources
    ./jdk-6u41-linux-x64.bin
    sudo mv jdk1.6.0_41 $JDK6_INSTALL_PATH
    cd $BASEDIR
}

function set_env()
{
    echo "Set environment"
    unset CLASSPATH
    unset JAVA_HOME
    export LANG=C
    export ALT_BOOTDIR=$JDK6_INSTALL_PATH
    export ANT_HOME=$ANT_INSTALL_PATH
    export ALT_FREETYPE_LIB_PATH=/usr/local/lib
    export ALT_FREETYPE_HEADERS_PATH=/usr/local/include/freetype2
    export SKIP_DEBUG_BUILD=$SKIP_DEBUG
    export SKIP_FASTDEBUG_BUILD=$SKIP_FASTDEBUG
    export DEBUG_NAME=$DEBUG_VERSION
    export MILESTONE=$MILESTONE
    export BUILD_NUMBER=$BUILD_NUMBER
}

check_make()
{
    make sanity
    if [ ! "$?" == "0" ];then
        exit 1
    fi
}

function go_build()
{
    echo "Start to build..."
    make all ARCH_DATA_MODEL=$ARCH_MODEL ALLOW_DOWNLOADS=true
}

prepare_pkgs
install_freetype
install_ant
install_jdk6
set_env
check_make
go_build

