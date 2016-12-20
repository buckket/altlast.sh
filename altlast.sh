#!/bin/sh

# altlast.sh – remove uninteresting twitter followings
# Copyright © 2016 buckket

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# For this script to work you need a running copy of:
# https://github.com/sferik/t

favs=1000 # Number of favs to consider

# This script will create various files:
# followings.txt -> users you currently follow
# favorites.txt -> users you have faved in the given period
# legacy.txt -> users you follow but haven’t faved in a while
# unfollowed.txt -> users you have unfollowed using altlast.sh

# Protip: Use "comm -12 followings.txt favorites.txt" to see 
# which users you’ve faved but currently don’t follow

t followings -l | tail -n +2 | awk '{print $13'} | sort -u > followings.txt
t favorites -l -n ${favs} | tail -n +2 | awk '{print $5'} | sort -u > favorites.txt

legacy=$(comm -23 followings.txt favorites.txt)
echo "${legacy}" > legacy.txt

echo "[-] Found $(wc -l <<< ${legacy}) accounts which you haven’t faved in a while"

for user in ${legacy}; do
    echo -e "\n[-] Showing details for user ${user}:"
    t whois ${user}
    echo -n "[?] Do you want to unfollow ${user}? [yN]: "
    
    read answer
    case ${answer} in
        "y")
            t unfollow ${user} > /dev/null
            echo "[x] You’ve unfollowed ${user}"
            echo "${user}" >> unfollowed.txt
            ;;
    esac
done
