#!/bin/bash
CURRENT_DATE=`date +%Y%m%d`

echo "Checking vacation changes on $CURRENT_DATE"

# iterate over users
for key in `db accounts keys`
do
        if [ `db accounts gettype  $key` == "user" ]
        then
                # check for EmailVacationProperty
                if [ -z `db accounts getprop $key EmailVacation` ]
                then
                        echo "$key never went on vacation before."

                # if both fields are empty or contain the same value, do nothing 
                elif [ `db accounts getprop $key EmailVacationFrom` == `db accounts getprop $key EmailVacationTo` ]
                then
                        echo "Both fields empty or same date, not changing anything for $key"
                        # db accounts setprop $key EmailVacation no

                elif [ `db accounts getprop $key EmailVacationFrom` == $CURRENT_DATE ]
                then
                        echo "Happy holidays, $key"
                        db accounts setprop $key EmailVacation yes
                        /etc/e-smith/events/actions/qmail-update-user event $key

                elif [ `db accounts getprop $key EmailVacationTo` == $CURRENT_DATE ]
                then
                        echo "Back to work, $key"
                        db accounts setprop $key EmailVacation no
                        /etc/e-smith/events/actions/qmail-update-user event $key

                else
                        echo "Nothing to do for $key"

                fi
        fi
done
