#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
  CSV_FILE="games_test.csv"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
  CSV_FILE="games.csv"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CSV_FILE="$SCRIPT_DIR/$CSV_FILE"

tail -n +2 "$CSV_FILE" | while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
 do
  winner_name=$(printf "%s" "$WINNER" | sed "s/'/''/g")
  opponent_name=$(printf "%s" "$OPPONENT" | sed "s/'/''/g")

  $PSQL "INSERT INTO teams(name) VALUES ('$winner_name'), ('$opponent_name') ON CONFLICT (name) DO NOTHING;"

  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner_name';")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent_name';")

  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $winner_id, $opponent_id, $WINNER_GOALS, $OPPONENT_GOALS);"
done