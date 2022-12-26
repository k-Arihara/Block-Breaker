#!/bin/bash

# Environment Value
FIELD="
#####################################
#                                   #
#                                   #
#    @@@@@@@@@@@@@@@@@@@@@@@@@@@    #
#    @@@@@@@@@@@@@@@@@@@@@@@@@@@    #
#    @@@@@@@@@@@@@@@@@@@@@@@@@@@    #
#    @@@@@@@@@@@@@@@@@@@@@@@@@@@    #
#    @@@@@@@@@@@@@@@@@@@@@@@@@@@    #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#####################################"

FIELD_WIDTH=37
FIELD_HEIGHT=16
X=3
Y=2
VX=1
VY=1

# Define Function
getch() {
  old=$(stty -g)
  stty raw -echo min 0 time 1
  printf '%s' $(dd bs=1 count=1 2>/dev/null)
  stty $old
}

# Main Function
FIELD_WITHOUT_CRLF=$(echo "$FIELD" | sed -e ':loop' -e 'N; $!b loop' -e 's/\n//g')
for i in $(seq "${#FIELD_WITHOUT_CRLF}"); do
  elem=$(printf "$FIELD_WITHOUT_CRLF" | cut -c "$i")
  FIELD_ARR+=("$elem")
done

pos=1
while :; do
  c=$(getch)
  case ${c} in
  "q")
    break
    ;;
  "h")
    [ "${pos}" -gt 1 ] && pos=$((pos - 1))
    ;;
  "l")
    [ "${pos}" -lt $((FIELD_WIDTH - 2)) ] && pos=$((pos + 1))
    ;;
  *) ;;
  esac
  printf "$c\r"
  
  if [ "$1" = "cheat" ];then
    FIELD_ARR[$(((FIELD_HEIGHT-4) * FIELD_WIDTH + $X))]="-"
  else
    FIELD_ARR[$(((FIELD_HEIGHT-4) * FIELD_WIDTH + pos))]="-"
  fi

  NEXT_X_C=${FIELD_ARR[$(((Y * FIELD_WIDTH) + X + VX))]}
  NEXT_Y_C=${FIELD_ARR[$(((Y + VY) * FIELD_WIDTH + X))]}
  NEXT_XY_C=${FIELD_ARR[$(((Y + VY) * FIELD_WIDTH + X + VX))]}

  if [[ '#@-' =~ "$NEXT_X_C" ]] || [[ '#@-' =~ "$NEXT_Y_C" ]]; then
    if [[ '#@-' =~ "$NEXT_X_C" ]]; then
      if [[ "@" = "$NEXT_X_C" ]]; then
        FIELD_ARR[$(((Y * FIELD_WIDTH) + X + VX))]=" "
      fi
      VX=$((VX * -1))
    fi
    if [[ '#@-' =~ "$NEXT_Y_C" ]]; then
      if [[ "@" = "$NEXT_Y_C" ]]; then
        FIELD_ARR[$(((Y + VY) * FIELD_WIDTH + X))]=" "
      fi
      VY=$((VY * -1))
    fi
  elif [[ '#@-' =~ "$NEXT_XY_C" ]]; then
    if [[ "@" = "$NEXT_XY_C" ]]; then
      FIELD_ARR[$(((Y + VY) * FIELD_WIDTH + X + VX))]=" "
    fi
    VX=$((VX * -1))
    VY=$((VY * -1))
  fi

  ball_xy=$((Y*FIELD_WIDTH+X)) || true
  FIELD_TMP=""
  atmark_count=0
  for i in $(seq 0 "${#FIELD_WITHOUT_CRLF}"); do
    if [ $(("$i" % FIELD_WIDTH)) = 0 ]; then
      FIELD_TMP="$FIELD_TMP\n"
    fi
    if [ $ball_xy = "$i" ];then
      FIELD_TMP="${FIELD_TMP}o"
    else
      FIELD_TMP="${FIELD_TMP}${FIELD_ARR[$i]}"
      if [ "${FIELD_ARR[$i]}" = "@" ];then
        ((atmark_count++))
      fi
    fi
  done
  printf "$FIELD_TMP\033[${FIELD_HEIGHT}A\r"

  if [ $atmark_count = 0 ];then
    CLEAR_FLAG=1
    break
  fi

  if [ "$1" = "cheat" ];then
    FIELD_ARR[$(((FIELD_HEIGHT-4) * FIELD_WIDTH + $X))]=" "
  else
    FIELD_ARR[$(((FIELD_HEIGHT-4) * FIELD_WIDTH + pos))]=" "
  fi

  if [ $Y -gt $((FIELD_HEIGHT - 4)) ];then
    break
  fi

  X=$((X + VX))
  Y=$((Y + VY))
  # sleep 0.1
done

flash_display() {
  FLASH=""
  for i in $(seq 0 "${#FIELD_WITHOUT_CRLF}"); do
    if [ $(("$i" % FIELD_WIDTH)) = 0 ]; then
      FLASH="$FLASH\n"
    fi
    FLASH="$FLASH "
  done
  printf "$FLASH\033[${FIELD_HEIGHT}A\r"
}

GAME_OVER="
              ■                       
   ■■■■■     ■■    ■■     ■■■  ■■■■■■ 
  ■■   ■     ■■    ■■■    ■■■  ■      
 ■■         ■■ ■   ■■■    ■■■  ■      
 ■          ■  ■   ■ ■   ■■■■  ■      
 ■    ■■■   ■  ■■  ■  ■  ■ ■■  ■■■■■■ 
 ■      ■  ■■■■■■  ■  ■  ■ ■■  ■      
 ■■     ■  ■    ■  ■  ■■■  ■■  ■      
  ■■   ■■ ■■    ■■ ■   ■■  ■■  ■      
   ■■■■■  ■      ■ ■   ■   ■■  ■■■■■■ 
                                      
                                      
   ■■■■   ■■     ■ ■■■■■■  ■■■■■      
  ■■   ■■  ■    ■■ ■       ■    ■     
 ■■     ■  ■    ■  ■       ■    ■■    
 ■      ■■ ■■   ■  ■       ■    ■     
 ■      ■■  ■  ■■  ■■■■■■  ■■■■■      
 ■      ■■  ■  ■   ■       ■   ■      
 ■■     ■   ■■ ■   ■       ■    ■     
  ■■   ■■    ■■    ■       ■    ■■    
   ■■■■      ■■    ■■■■■■  ■     ■
  "

GAME_CLEAR="
              ■                          
   ■■■■■     ■■    ■■     ■■■  ■■■■■■    
  ■■   ■     ■■    ■■■    ■■■  ■         
 ■■         ■■ ■   ■■■    ■■■  ■         
 ■          ■  ■   ■ ■   ■■■■  ■         
 ■    ■■■   ■  ■■  ■  ■  ■ ■■  ■■■■■■    
 ■      ■  ■■■■■■  ■  ■  ■ ■■  ■         
 ■■     ■  ■    ■  ■  ■■■  ■■  ■         
  ■■   ■■ ■■    ■■ ■   ■■  ■■  ■         
   ■■■■■  ■      ■ ■   ■   ■■  ■■■■■■    
                                         
                                         
                            ■            
   ■■■■■  ■      ■■■■■■    ■■    ■■■■■   
  ■■   ■  ■      ■         ■■    ■    ■  
 ■■       ■      ■        ■■ ■   ■    ■■ 
 ■        ■      ■        ■  ■   ■    ■  
 ■        ■      ■■■■■■   ■  ■■  ■■■■■   
 ■        ■      ■       ■■■■■■  ■   ■   
 ■■       ■      ■       ■    ■  ■    ■  
  ■■   ■  ■      ■      ■■    ■■ ■    ■■ 
   ■■■■   ■■■■■■ ■■■■■■ ■      ■ ■     ■
"

flash_display
if [ -v CLEAR_FLAG ];then
  printf "$GAME_CLEAR"
else
  printf "$GAME_OVER"
fi