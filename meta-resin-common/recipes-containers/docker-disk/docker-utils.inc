RESIN_CHECK_CONN_URL ?= "http://index.docker.io"
DOCKER_PID_FILE ?= "/var/run/docker.pid"

# Check if host can reach a specific URL
# Used for connectivity check
def connected(d):
    import urllib

    REMOTE_SERVER = d.getVar('RESIN_CHECK_CONN_URL', True)
    ALL_PROXY = d.getVar('ALL_PROXY', True)

    try:
        if ALL_PROXY:
            urllib.urlopen(REMOTE_SERVER, proxies={'http':ALL_PROXY})
        else:
            urllib.urlopen(REMOTE_SERVER)
    except IOError:
        return "no"
    else:
        return "yes"

# Check if docker is running and usable for current user
def usable_docker(d):
    import os, subprocess

    # Check docker is running
    pid_file = d.getVar('DOCKER_PID_FILE', True)
    try:
        f = open(pid_file, 'r')
    except:
        return "no"
    pid = f.read()
    f.close
    if not os.path.exists("/proc/%s" % pid):
        return "no"

    # Test docker execute permission
    cmd = "docker images > /dev/null 2>&1"
    child = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    cmd_output = child.communicate()[0]
    if child.returncode != 0:
        return "no"

    return "yes"

python () {
    # We need docker on host
    if usable_docker(d) != "yes":
        bb.fatal("docker-disk: Docker needs to run on your host and current user must be able to use it.")
}
