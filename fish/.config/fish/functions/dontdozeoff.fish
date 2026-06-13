function dontdozeoff
    set -l days 180
    set -l seconds (math "$days * 24 * 60 * 60")
    set -l start_time (date)
    set -l end_time (date -d "+$days days")

    echo "Keeping this machine awake from $start_time until $end_time — blocking sleep and lid-close suspend for $days days."
    systemd-inhibit --what=sleep:handle-lid-switch --why="server mode" sleep $seconds
end
