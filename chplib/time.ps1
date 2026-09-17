function time_sync {
    start-service w32time
    w32tm /resync /force
}