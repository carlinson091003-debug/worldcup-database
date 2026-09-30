#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# clear old data so the script can be re-run
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skip the header line
  if [[ $YEAR != "year" ]]
  then
    # add both teams (duplicates are ignored)
    $PSQL "INSERT INTO teams(name) VALUES('$WINNER'), ('$OPPONENT') ON CONFLICT (name) DO NOTHING" > /dev/null

    # add the game, looking up the team IDs inside the same query
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
           VALUES($YEAR, '$ROUND',
                  (SELECT team_id FROM teams WHERE name='$WINNER'),
                  (SELECT team_id FROM teams WHERE name='$OPPONENT'),
                  $WINNER_GOALS, $OPPONENT_GOALS)" > /dev/null
  fi
done