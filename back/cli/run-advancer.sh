[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

echo "\n"

open "http://localhost:3000/"$MATCH_ID

echo "\n"

sleep 5

a=0

while [ $a -lt $GAME_MOVE_COUNT ]
do

  if [ $MODE -eq 3 ] 
  then
    ./_simulation/update-data.sh
  fi

  # Commitment stage - async call
  ./_stages/request-commitments.sh

  # ...fullfiled promise...

  sleep $WAIT_SECONDS_AFTER_STAGE_CALL

  # Commitment stage part 2 - async call
  ./_stages/copy-commitments.sh

  # ...fullfiled promise...

  sleep $WAIT_SECONDS_AFTER_STAGE_CALL

  # Reveal stage - async call
  ./_stages/request-reveals.sh

  # ...fullfiled promise...

  sleep $WAIT_SECONDS_AFTER_STAGE_CALL

    # Reveal stage part 2 - async call
  ./_stages/copy-reveals.sh

  # ...fullfiled promise...

  sleep $WAIT_SECONDS_AFTER_STAGE_CALL

  # State update stage - async call
  ./_stages/request-state-update.sh

  # ...fullfiled promise...

  sleep $WAIT_SECONDS_AFTER_STAGE_CALL

    # State update stage part 2 - async call
  ./_stages/copy-state-update.sh

  # ...fullfiled promise...

  sleep $WAIT_SECONDS_AFTER_STAGE_CALL


  # increment the counter
  a=`expr $a + 1`

done
