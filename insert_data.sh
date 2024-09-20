#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$PSQL "TRUNCATE TABLE games, teams;"

# Insert unique teams into the teams table
echo "Inserting unique teams..."
cat games.csv | tail -n +2 | cut -d',' -f3,4 | tr ',' '\n' | sort | uniq | while read team; do
  # Insert team into the teams table if not already present
  $PSQL "INSERT INTO teams(name) VALUES('$team') ON CONFLICT (name) DO NOTHING;"
done

echo "Teams insertion completed."

# Insert game data into the games table
echo "Inserting game data..."
cat games.csv | tail -n +2 | while IFS=',' read year round winner opponent winner_goals opponent_goals; do
  # Get the winner_id
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")

  # Get the opponent_id
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

  # Insert game data into the games table
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
done

echo "Games insertion completed."
