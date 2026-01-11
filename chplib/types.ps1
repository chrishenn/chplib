# we separate types into its own file to dot-source them when importing a module
# note that this breaks private functions
# note that re-importing types does not work
# everything ms touches is just a big bucket o' dogwater, seriously

enum Cpu {
    unknown = -1
    amd = 0
    intel = 1
}

enum Env {
    machine
    user
    local
}

enum Start {
    # boot = 0 # started by the system loader; only valid for device drivers
    # system = 1 # started by IOInitSystem; only valid for device drivers
    automatic = 2
    manual = 3
    disabled = 4
}