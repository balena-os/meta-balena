RESIN_CHECK_CONN_URL ?= "index.docker.io"
DOCKER_PID_FILE ?= "/var/run/docker.pid"

# Check if host can reach a specific URL
# Used for connectivity check
def connected(d):
    import socket

    REMOTE_SERVER = d.getVar('RESIN_CHECK_CONN_URL', True)
    try:
        host = socket.gethostbyname(REMOTE_SERVER)
        testSocket = socket.create_connection((host, 80), 2)
        testSocket.close()
        return "yes"
    except:
        pass
    return "no"

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
    f.close()
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
