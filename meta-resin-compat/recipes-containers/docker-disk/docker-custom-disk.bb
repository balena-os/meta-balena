require docker-disk.inc

# By default no docker image in the data disk
TARGET_REPOSITORY ?= ""
TARGET_TAG ?= ""

ALLOW_EMPTY_${PN} = "1"

python () {
    target_repo = d.getVar("TARGET_REPOSITORY", True)
    target_tag = d.getVar("TARGET_TAG", True)
    if target_repo and not target_tag:
        d.setVar('TARGET_TAG', 'latest')
}
