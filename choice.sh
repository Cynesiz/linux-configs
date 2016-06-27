#!/bin/bash

# Reusable bash choice thing
# I should probably be doing this in perl
# But this works for now.

opt1txt="Option1"
opt1cmd="whatever"
opt2txt="Option2"
opt2cmd="whatever"
opt3txt="Option3"
opt3cmd="whatever"
opt4txt="Option4"
opt4cmd="whatever"

function option1 ()
{

}

function option2 ()
{

}
function option3 ()
{

}
function option4 ()
{

}

function dochoice ()
{
    case $1 in
        [${opt1txt}]* ) ${opt1cmd}; break;;
        [${opt2txt}]* ) ${opt2cmd}; break;;
        [${opt3txt}]* ) ${opt3cmd}; break;;
        [${opt4txt}]* ) ${opt4cmd}; break;;
        [quit]* ) exit;;
        * ) echo "Please choose an option or type 'quit'.";;
    esac
}

if [ $# -eq 0 ]
then
while true; do
    read -p "Enter ${choices} :  " choice
    dochoice $choice
done
else
dochoice $1
fi
