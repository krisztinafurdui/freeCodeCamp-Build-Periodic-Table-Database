#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Check if no argument is provided
if [[ -z $1 ]]; then
    echo "Please provide an element as an argument."
    exit 0  # Exit the script here to prevent further execution
fi

# Check if $1 is a number (atomic number)
if [[ $1 =~ ^[0-9]+$ ]]; then
    FIND_ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number = $1")
# Check if $1 is a symbol (1-2 uppercase letters)
elif [[ $1 =~ ^[A-Z][a-z]?$ ]]; then
    FIND_ELEMENT=$($PSQL "SELECT * FROM elements WHERE symbol = '$1'")
# Otherwise, assume $1 is a name (letters only)
else
    FIND_ELEMENT=$($PSQL "SELECT * FROM elements WHERE name = '$1'")
fi

# Output the result or a message if no result was found
if [[ -z $FIND_ELEMENT ]]; then
    echo "I could not find that element in the database."
else
    echo "$FIND_ELEMENT" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME; do
        # Find more details about the element from properties and types tables
        FIND_DETAILS=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types ON properties.type_id = types.type_id WHERE atomic_number = $ATOMIC_NUMBER")
        echo "$FIND_DETAILS" | while read ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE; do
            # Format the output here as per your requirement
            echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
        done
    done
fi
