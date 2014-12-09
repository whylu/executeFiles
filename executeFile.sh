
#the folder path you want to monitor
monitor_path=/opt/workspace/executeFile/executeFile_monitor_path


#-- path config
install_path=$(pwd)
running_path=$install_path/running
finish_path=$install_path/finish
running_pid_path=$install_path/pid_running

#-- log config
log_path=$install_path/log
log_info_file=$log_path/info.log

#-- prepare path

#$1: full path to create
function mkdirIfNotExist() {
  if [ ! -d $1 ]; then
    mkdir -p $1
    echo "mkdir "$1
  fi
}

mkdirIfNotExist $running_path
mkdirIfNotExist $finish_path
mkdirIfNotExist $log_path
mkdirIfNotExist $running_pid_path

#-- prepare log
touch $log_info_file

function logInfo() {
  msg="$@"
  timestamp=$(TZ=Asia/Taipei date "+%Y-%m-%d_%H:%M:%S")
  echo [$timestamp]$msg >> $log_info_file
}


#------------
#jobs=()

#$1: file full path
function executeFile() {
  jobs=()
  trap 'echo kill file thread subprocess ${jobs[@]} && ([ ${#jobs[@]} -eq 0 ] && exit) || kill -TERM ${jobs[@]}; exit' SIGTERM SIGINT SIGHUP
  
  fileBasename=$(basename "$1")
  echo $fileBasename
  #move file to $running
  cp $1 $running_path/$fileBasename
  logInfo exe $1

  #change mode to executable and run
  chmod +x $running_path/$fileBasename  

  #execute file
  touch $running_pid_path/$BASHPID
  $running_path/$fileBasename & jobs+=($!)
  touch $running_pid_path/$!
  wait
 
  #after finish, move file to $finish
  rm -f $running_pid_path/$BASHPID
  rm -f $running_pid_path/$!
  mv $running_path/$fileBasename $finish_path/$fileBasename
  logInfo finish $1
  
}

#-- create threads to execute every file in parallel
if [ "$(ls -A $monitor_path)" ]; then
  jobs=()
  trap 'echo kill file theads ${jobs[@]} && ([ ${#jobs[@]} -eq 0 ] && exit) || kill ${jobs[@]}; exit' SIGTERM SIGINT SIGHUP
  for file in $monitor_path/*;
  do
    echo $file
    executeFile $file & jobs+=($!)
  done
fi

#wait files to finish
wait
