#!/bin/bash
get_user() {
    echo -n "$(whoami)"
}

get_cpu_usage() {
    cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo -n "%{F#0077ff}CPU: $cpu%{F-}%{F#0077ff}%%%{F-}"
}

get_ram_usage() {
    ram=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    echo -n "%{F#3399ff}RAM: ${ram%.*}%{F-}%{F#3399ff}%%%{F-}"
}

get_volume() {
    volume=$(pactl list sinks | grep -oP 'Volume:.*?(\d+%)' | head -n 1 | awk '{print $5}')
    echo -n "%{F#ffffff}VOL: $volume{F-}%%%{F-}"
}

get_battery() {
    battery=$(acpi | grep -o '[0-9]*%' | head -n 1)
    if [ ${battery%?} -lt 20 ]; then
        echo -n "%{F#ff0000}BATTERY: $battery{F-}%{F#ff0000}%%%{F-}"
    elif [ ${battery%?} -lt 50 ]; then
        echo -n "%{F#ffff00}BATTERY: $battery{F-}%{F#ffff00}%%%{F-}"
    else
        echo -n "%{F#00ff00}BATTERY: $battery{F-}%{F#00ff00}%%%{F-}"
    fi
}

get_date() {
    echo -n "%{F#ffffff}$(date '+%d-%m-%Y')%{F-}"
}

get_time() {
    echo -n "%{F#ffffff}$(date '+%H:%M:%S')%{F-}"
}

update_bar() {
    //user="$(get_user)"
    date_time="$(get_time)"
    volume="$(get_volume)"
    
    cpu="$(get_cpu_usage)"
    ram="$(get_ram_usage)"
    
    battery="$(get_battery)"
    current_date="$(get_date)"
    
    lemonbar_output="  $current_date | %{r} | $cpu | $ram | $volume | $battery | $date_time  "
    
    echo "$lemonbar_output"
}
while true; do
    update_bar

    # calculating remainder to next whole second (syncronizing for clock)
    current_millis=$(date +%s%3N)
    current_seconds=$(date +%s)       
    remainder_ms=$((1000 - (current_millis % 1000)))

    # Überprüfen, ob remainder_ms eine gültige Zahl ist
    if [ -n "$remainder_ms" ] && [ "$remainder_ms" -gt 0 ]; then
        # Umwandeln in Sekunden und schlafen
        sleep_time=$(echo "scale=3; $remainder_ms / 1000" | bc)
        sleep "$sleep_time"
    else
        # Falls keine gültige Zeit zum Schlafen, einfach kurz schlafen
        sleep 0.1
    fi
done
