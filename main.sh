#!/bin/bash

# Environment Value
FIELD="
#################################
#                               #
#                               #
#                               #
#    *                          #
#     *                         #
#      @                        #
#  @@@  @                       #
#################################"

FIELD_WIDTH=33
FIELD_HEIGHT=9
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
  # echo $ELEM
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

  NEXT_X_C=${FIELD_ARR[$(((Y * FIELD_WIDTH) + X + VX))]}
  NEXT_Y_C=${FIELD_ARR[$(((Y + VY) * FIELD_WIDTH + X))]}
  NEXT_XY_C=${FIELD_ARR[$(((Y + VY) * FIELD_WIDTH + X + VX))]}
  # printf '%s %s\n' "$NEXT_X_C" "$NEXT_Y_C"

  if [[ '#@-' =~ "$NEXT_X_C" ]] || [[ '#@-' =~ "$NEXT_Y_C" ]]; then
    if [[ '#@-' =~ "$NEXT_X_C" ]]; then
      VX=$((VX * -1))
    fi
    if [[ '#@-' =~ "$NEXT_Y_C" ]]; then
      VY=$((VY * -1))
    fi
  elif [[ '#@-' =~ "$NEXT_XY_C" ]]; then
    VX=$((VX * -1))
    VY=$((VY * -1))
  fi

  ball_xy=$((Y*FIELD_WIDTH+X)) || true
  FIELD_TMP=""
  for i in $(seq 0 "${#FIELD_WITHOUT_CRLF}"); do
    if [ $(("$i" % FIELD_WIDTH)) = 0 ]; then
      FIELD_TMP="$FIELD_TMP\n"
    fi
    if [ $((6 * FIELD_WIDTH + pos)) = "$i" ]; then
      FIELD_TMP="${FIELD_TMP}-"
    elif [ $ball_xy = "$i" ];then
      FIELD_TMP="${FIELD_TMP}o"
    else
      FIELD_TMP="${FIELD_TMP}${FIELD_ARR[$i]}"
    fi
  done
  printf "$FIELD_TMP\033[10A\r"

  X=$((X + VX))
  Y=$((Y + VY))

  # sleep 0.25
done
