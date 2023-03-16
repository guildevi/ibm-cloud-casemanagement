#!/bin/sh

#LOG_LEVEL=5

export stdout=/tmp/stdout
export stderr=/tmp/stderr

log() {
  level=$1
  shift
  [ -f $1 ] && cat $1
  echo $(date "+%Y-%m-%d %H:%M:%S") $level $*
}

error() {
  if test ${LOG_LEVEL=5} -ge 0
  then
    log $(tput setaf 1)$(tput bold)ERROR $* $(tput sgr0)
  fi
}

warn() {
  [ ${LOG_LEVEL=5} -ge 2 ] && log $(tput setaf 3)WARNING $* $(tput sgr0) 
}

info() {
  [ ${LOG_LEVEL=5} -ge 5 ] && log INFO $*
}

debug() {
  [ ${LOG_LEVEL=5} -ge 10 ] && log DEBUG $* 
}

isdebug() {
    #info SAMPLE INFO MESSAGE 
    #warn SAMPLE WARNING MESSAGE
    #error SAMPLE ERROR MESSAGE
    #debug SAMPLE DEBUG MESSAGE
    while test $# -gt 0
    do
        parameter=$1
        shift
        case $parameter in
        -d|--debug)
            export LOG_LEVEL=10
            debug DEBUG ENABLED
            break
            ;;
        *)
            debug IGNORE PARAMETER ${parameter}
        esac
    done
}

setenvfromfile() {
    file=$1
    prefix=$2
    shell=/tmp/setenvfromfile.sh
    info SET ${prefix} ENVIRONMENT VARIABLES FROM ${file} 
    if test -f ${file}
    then
        debug FILE ${file} EXISTS
        echo "#!/bin/sh" >${shell}
        echo "# SET ENVIRONMENT VARIABLES FROM ${file}" >>${shell}
        while read line 
        do
            if [ ! "${line}" = "" ] 
            then
              info "-" ${prefix}${line}
              echo "export ${prefix}${line}" >>${shell}
            fi
        done <${file}
        cat ${shell}
        chmod +x ${shell}
        . ${shell}
        debug ${shell} SET ${prefix} ENVIRONMENT VARIABLES FROM ${file} COMPLETED
        rm ${shell}
    else
        warn FILE ${file} DOES NOT EXIST
    fi
}

createupdate()
{
  component=$1
  name=$2
  parameters=$3
  
  debug ibmcloud ${component} ACTION --name ${name} ${parameters}
  ibmcloudce ${component} get --name ${name}
  if [ $? -eq 0 ]
  then
    debug ${component} ${name} EXISTS
    ibmcloudce ${component} update --name ${name} ${parameters}
    if [ $? -eq 0 ]
    then
      info UPDATED ${component} ${name}
    else
      error ${stdout} FAILED TO UPDATE ${component} ${name} 
      exit 1
    fi
  else
    debug ${component} ${name} DOES NOT EXIST
    ibmcloudce ${component} create --name ${name} ${parameters}
    if [ $? -eq 0 ]
    then
      info CREATED ${component} ${name}
    else
      error ${stdout} FAILED TO CREATE ${component} ${name} 
      exit 1
    fi
  fi
  #bx ce ${component} get --name ${name}
}

submit()
{
    component=$1
    name=$2
    parameters=$3
    instance=${name}$(date "+-%Y%m%d-%H%M%S")
    ibmcloudce ${component}run submit --name ${instance} --${component} ${name} ${parameters}
    if [ $? -eq 0 ]
    then
        info SUCCESSFULLY SUBMITTED ${component} ${instance}
    else
        ibmcloudce ${component}run logs --name ${instance} 
        error ${stdout} FAILED SUBMITTING ${component}run ${name}
        exit 1
    fi
}

ibmcloudce () {
  command="ibmcloud ce $*"
  debug ${command}
  ${command} 1>${stdout} 2>&1
  if [ $? -eq 0 ]
  then
    debug SUCCESSFULLY EXECUTED ${command}
    return 0
  else
    error ${stdout} FAILED TO EXECUTE ${command}
    return 1
  fi
}

debug EXECUTE $0
isdebug $*
