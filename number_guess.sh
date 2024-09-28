#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number
SECRET=$(( ($RANDOM % 1000 ) + 1 ))

# Ask for username
echo "Enter your username:"
read USERNAME

# Determine if username is in database
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
if [[ -z $USERNAME_RESULT ]]
then
  #if not found
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  #if found
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Ask for guess
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
COUNT=1

# Compare Guess against Secret
GUESS_AGAIN() {

  # if not a number or integer
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read USER_GUESS
    GUESS_AGAIN
    return
  fi

  if [[ $USER_GUESS -gt $SECRET ]]
  then
    echo "It's lower than that, guess again:"
    ((COUNT++))
    read USER_GUESS
    GUESS_AGAIN
  elif [[ $USER_GUESS -lt $SECRET ]]
  then
    echo "It's higher than that, guess again:"
    ((COUNT++))
    read USER_GUESS
    GUESS_AGAIN
  else
    echo "You guessed it in $COUNT tries. The secret number was $SECRET. Nice job!"
  fi
}

GUESS_AGAIN

# update games played
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
((GAMES_PLAYED++))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username='$USERNAME'")

# update best game if applicable
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
if [[ -z $BEST_GAME || $COUNT -lt $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $COUNT WHERE username='$USERNAME'")
fi
