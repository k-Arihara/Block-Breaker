#!/bin/sh

FIELD="
#################################
#                               #
#                               #
#                               #
#    *                          #
#     *                         #
#      @                        #
#  @@@  @                       #
#################################\033[9A\r"

FIELD_WIDTH=33
FIELD_HEIGHT=9
X=3
Y=2
VX=1
VY=1

getch() {
  old=$(stty -g)
  stty raw -echo min 0 time 1
  printf '%s' $(dd bs=1 count=1 2>/dev/null)
  stty $old
}

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

  NEXT_X_C=$(echo "$FIELD" | sed -e ':loop' -e 'N; $!b loop' -e 's/\n//g' | cut -c $((((Y-1)*FIELD_WIDTH)+X+VX)))
  NEXT_Y_C=$(echo "$FIELD" | sed -e ':loop' -e 'N; $!b loop' -e 's/\n//g' | cut -c $(((Y+VY-1)*FIELD_WIDTH+X)))
  NEXT_XY_C=$(echo "$FIELD" | sed -e ':loop' -e 'N; $!b loop' -e 's/\n//g' | cut -c $(((Y+VY-1)*FIELD_WIDTH+X+VX)))
  printf '%s %s' "$NEXT_X_C" "$NEXT_Y_C"
  # printf "XY:$((Y*FIELD_WIDTH+X)), X+VX:$(((Y*FIELD_WIDTH)+X+VX))), Y+VY:$(((Y+VY)*FIELD_WIDTH+X)))"

  if [ "$NEXT_X_C" = '#' ] || [ "$NEXT_X_C" = '@' ] || [ "$NEXT_Y_C" = '#' ] || [ "$NEXT_Y_C" = '@' ]; then
    if [ "$NEXT_X_C" = '#' ] || [ "$NEXT_X_C" = '@' ]; then
      VX=$((VX*-1))
    fi
    if [ "$NEXT_Y_C" = '#' ] || [ "$NEXT_Y_C" = '@' ]; then
      VY=$((VY*-1))
    fi
  elif [ "$NEXT_XY_C" = '#' ] || [ "$NEXT_XY_C" = '@' ];then
    VX=$((VX*-1))
    VY=$((VY*-1))
  fi

  printf "$FIELD"
  printf "\033[$((${FIELD_HEIGHT}-2))B\033[${pos}C-\033[$((${FIELD_HEIGHT}-2))A\r"
  printf "\033[$((Y))B\033[$((X-1))Co\033[$((Y))A\r"

  X=$((X+VX))
  Y=$((Y+VY))

  # for i in $(seq $((FIELD_WIDTH-2)));do
  #   if [ $i = $pos ];then
  #     printf "-"
  #   else
  #     printf " "
  #   fi
  # done
  # sleep 0.25
done
