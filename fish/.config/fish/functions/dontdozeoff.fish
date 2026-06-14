function dontdozeoff
    set -l start_time (date)
    echo "Keeping this machine awake — started at $start_time"
    kde-inhibit --power --screenSaver sleep infinity
end
