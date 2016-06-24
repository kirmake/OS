#!/bin/bash


# Запускается первый с ключом -m
# Второй без аргументов


PORT=6000;
ADDRESS=localhost;
TIMEOUT=10;

MASTER="false";
CONNECTMSG="START";
NETCAT=nc;

FIELD=();
TURN=0;

drawField() {
  clear;
  tput cup 0 0;
  echo " You:┌───┬───┬───┐";
  if [ $cross == 1 ]
  then
    echo "  X  | 1 | 2 | 3 |";
  else
    echo "  0  | 1 | 2 | 3 |";
  fi
  echo " ┌───┼───┼───┼───┤";
  for (( i = 1; i < 4; i++ ))
  do
    echo -n " | $i";
    for (( j = 1; j < 4; j++ ))
    do
      CELL=" ";
      if [[ ${FIELD[3*i+j-4]} -eq 1 ]]
      then
        CELL="X";
      elif [[ ${FIELD[3*i+j-4]} -eq 2 ]]
      then
        CELL="O";
      fi
      echo -n " | $CELL";
    done
    echo " |";
    if [[ $i == "3" ]]
    then 
    echo " └───┴───┴───┴───┘"
    else
    echo " ├───┼───┼───┼───┤";
    fi
  done
}

combinationCheck() {
  if  [[  ${FIELD[0]} -eq 1  &&  ${FIELD[1]} -eq 1  &&  ${FIELD[2]} -eq 1 ||
	  ${FIELD[3]} -eq 1  &&  ${FIELD[4]} -eq 1  &&  ${FIELD[5]} -eq 1 ||
	  ${FIELD[6]} -eq 1  &&  ${FIELD[7]} -eq 1  &&  ${FIELD[8]} -eq 1 ||
	  ${FIELD[0]} -eq 1  &&  ${FIELD[3]} -eq 1  &&  ${FIELD[6]} -eq 1 ||
	  ${FIELD[1]} -eq 1  &&  ${FIELD[4]} -eq 1  &&  ${FIELD[7]} -eq 1 ||
	  ${FIELD[2]} -eq 1  &&  ${FIELD[5]} -eq 1  &&  ${FIELD[8]} -eq 1 ||
	  ${FIELD[0]} -eq 1  &&  ${FIELD[4]} -eq 1  &&  ${FIELD[8]} -eq 1 ||
	  ${FIELD[2]} -eq 1  &&  ${FIELD[4]} -eq 1  &&  ${FIELD[6]} -eq 1 ]]
  then 
  
      if [ $cross == 1 ]
      then
      showResult "You win";
      else
      showResult "You loose";
      fi
      return 0;
  fi
  if  [[  ${FIELD[0]} -eq 2  &&  ${FIELD[1]} -eq 2  &&  ${FIELD[2]} -eq 2 ||
	  ${FIELD[3]} -eq 2  &&  ${FIELD[4]} -eq 2  &&  ${FIELD[5]} -eq 2 ||
	  ${FIELD[6]} -eq 2  &&  ${FIELD[7]} -eq 2  &&  ${FIELD[8]} -eq 2 ||
	  ${FIELD[0]} -eq 2  &&  ${FIELD[3]} -eq 2  &&  ${FIELD[6]} -eq 2 ||
	  ${FIELD[1]} -eq 2  &&  ${FIELD[4]} -eq 2  &&  ${FIELD[7]} -eq 2 ||
	  ${FIELD[2]} -eq 2  &&  ${FIELD[5]} -eq 2  &&  ${FIELD[8]} -eq 2 ||
	  ${FIELD[0]} -eq 2  &&  ${FIELD[4]} -eq 2  &&  ${FIELD[8]} -eq 2 ||
	  ${FIELD[2]} -eq 2  &&  ${FIELD[4]} -eq 2  &&  ${FIELD[6]} -eq 2 ]]
  then 
     if [ $cross == 1 ]
      then
      showResult "You loose";
      else
      showResult "You win";
      fi
      return 0;
  fi
  
  for (( i = 0; i < 3; ++i ))
  do
    for (( j = 0; j < 3; ++j ))
    do
      if [[ ${FIELD[3*i+j]} -eq 0 ]]
      then
        return 1;
      fi
    done
  done 
  showResult "Draw";
  return 0;
}

connectionCheck() {
  if [[ -z "$COPROC_PID" ]]
  then
    echo "Connection lost";
    quit 4;
  fi
}

init() {
  for (( i=0; i<9; i++ ))
  do
    FIELD[i]=0;
  done

  swapTurn;
  drawField;
}


quit() {
  if [[ -n "$COPROC_PID" ]]
  then
    kill $COPROC_PID;
  fi
  exit $1;
}

resultMessage() {
  clear;
  tput cup 0 0;
  echo $1
  tput cup 2 0;
  echo "Play again? (y/n)";
}

showHelp() {
  echo "   -m - run as master";
  echo "   -h - show help";
  quit 0;
}

waitTurn() {
  tput cup 10 0;
  echo -n "Opponent's turn";
  stty -echo;
  read -u "${COPROC[0]}" turn
  stty echo;
  set -- "$turn";
  IFS=" "; declare -a arr=($*);
  x=$(( 3*${arr[0]} + ${arr[1]} - 4));
  if [ $cross == 1 ]
  then
  FIELD[$x]=2;
  else
  FIELD[$x]=1;
  fi
  
  swapTurn;
}

swapTurn() {
  if [[ $TURN -eq 0 ]]
  then
    TURN=1;
  else
    TURN=0;
  fi
}

makeTurn() {
  tput cup 10 0;
  echo -n "Your turn([row] [column]): ";
  while true
  do
    clearInputBuffer;
    read turn;
    
    set -- "$turn";
    IFS=" "; declare -a arr=($*);
    
    x=$(( 3*${arr[0]} + ${arr[1]} - 4));
    if [[ ${FIELD[$x]} -ne 0 ]]
    then
      drawField;
      tput cup 9 0;
      echo -n "Cell ${arr[0]} ${arr[0]} is already used!" 
      tput cup 10 0;
      echo -n "Enter your turn([row] [column]): ";
      continue;
    fi
    if 	[[  ${arr[0]} -lt 1  ||
	    ${arr[0]} -gt 3  ||
	    ${arr[1]} -lt 1  ||
	    ${arr[1]} -gt 3 ]]
    then
      drawField;
      tput cup 9 0;
      echo -n "Wrong position!" 
      tput cup 10 0;
      echo -n "Enter your turn([row] [column]): ";
      continue;
    fi
    if [ $cross == 1 ]
    then
    FIELD[$x]=1;
    else
    FIELD[$x]=2;
    fi
    echo "$turn" >& "${COPROC[1]}";
    break;
  done

  swapTurn;
}

clearInputBuffer() {
  while read -r -t 0
  do 
    read -r; 
  done
}


while [[ $# -ge 1 ]]
do

  if [ $1 == "-h" ]
      then
	showHelp;
  fi
   if [ $1 == "-m" ]
      then
      MASTER="true";
   else
      	echo "Wrong arguments";
	quit 1;
   fi
   
 
  shift
done

if [[ "$MASTER" = "true" ]]
then
  coproc $NETCAT -q "$TIMEOUT" -l -p "$PORT";
  TURN=0;
  cross=1
else
  coproc $NETCAT -q "$TIMEOUT" "$ADDRESS" "$PORT";
  TURN=1;
  cross=0
fi

clear;
echo "Waiting for opponent";
echo "$CONNECTMSG" >& "${COPROC[1]}";
if ! read -t "$TIMEOUT" -u "${COPROC[0]}" MSG
then
  echo "Connection error";
  quit 1;
fi

if [[ "$MSG" != "$CONNECTMSG" ]] 
then
  echo "Connection error";
  quit 1;
fi

while true
do 
  clear;
  echo "Waiting for opponent";
  echo "$CONNECTMSG" >& "${COPROC[1]}";

  if ! read -t "$TIMEOUT" -u "${COPROC[0]}" MSG
  then
    echo "Connection lost";
    quit 1;
  fi
  
  init;
  
  while true
  do
    connectionCheck;
    if [[ $TURN -eq 0 ]]
    then
      waitTurn;
    else
      makeTurn;
    fi
    drawField;
    if combinationCheck
    then
      break;
    fi
  done
    while read -s -n 1 MORE
    do
      connectionCheck;
      if [[ "$MORE" == "y" ]] || [[ "$MORE" == "Y" ]]
      then
	continue 2;
      fi
      if [[ "$MORE" == "n" ]] || [[ "$MORE" == "N" ]]
      then
	break 2;
      fi
    done
  done
  quit 0;

