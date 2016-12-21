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

# Options:
favs=1000 # Number of favs to consider

# This script will create various files:
# followings -> users you currently follow
# favorites -> users you have faved in the given period
# legacy -> users you follow but haven’t faved in a while
# unfollowed -> users you have unfollowed using altlast.sh

# Protip: Use "comm -12 followings favorites" to see 
# which users you’ve faved but currently don’t follow

t followings -l | tail -n +2 | awk '{print $13'} | sort -u > followings
t favorites -l -n ${favs} | tail -n +2 | awk '{print $5'} | sort -u > favorites

comm -23 followings favorites > legacy

printf "[-] Found %d accounts which you haven’t faved in a while\n" "$(wc -l < legacy)"

for user in $(cat legacy); do
    printf "\n[-] Showing details for user %s\n" "${user}:"
    t whois ${user}
    printf "[?] Do you want to unfollow %s? [yN]: " "${user}"
    
    read answer
    case ${answer} in
        "y")
            t unfollow ${user} > /dev/null
            printf "[x] You’ve unfollowed %s\n" "${user}"
            echo "${user}" >> unfollowed
            ;;
    esac
done
