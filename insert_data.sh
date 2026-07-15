#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# truncate tables
echo $($PSQL "TRUNCATE games, teams;")

# read csv file in correct columns
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
# Insert teams to the teams table
  if [[ $YEAR != "year" ]]
  then
    # get team id for winner
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # check if team id is empty
    if [[ -z $WINNER_TEAM_ID ]]
    then
      # insert winner into teams table
      INSERT_INTO_TEAMS=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_INTO_TEAMS == "INSERT 0 1" ]]
      then
      # WINNER_ID=$TEAM_ID
      echo -e "\n$WINNER, $WINNER_TEAM_ID is added to the teams table."
      fi
    fi

    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      # insert opponent into teams table
      INSERT_INTO_TEAMS=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $INSERT_INTO_TEAMS == "INSERT 0 1" ]]
      then
        #OPPONENT_ID=$TEAM_ID
        echo -e "\n$OPPONENT, $OPPONENT_TEAM_ID is added to the teams table."
      fi
    fi
  fi
done

# Insert data into games table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Neglect column line
  if [[ ! $YEAR = 'year' ]]
  then
    # get winner_id and opponent_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    # Insert data into games table
    INSERT_INTO_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_INTO_GAMES == "INSERT 0 1" ]]
    then
      echo -e "\n$YEAR $ROUND match is inserted into games table."
    fi
  fi
done