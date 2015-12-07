# README_TO_BE!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!
# Define DIRECT_HEADER_FILE_NAME with the name of the header file specific to your board.
#
# NOTE: This is only needed if the class cannot determine the filename automatically
# For example in the case of an Raspberrypi B:
# NOTE: This file should be present in ${B}/include/configs
# DIRECT_HEADER_FILE_NAME ?= "rpi_b"
#
# Define APPEND_ENV_FILE with the name of the file that contains the
# environmnet append
# NOTE: This is file should be present in SRC_URI
#
# Define DEFINE_CONFIGS with the new #define for the config
# NOTE: This cannot overrwrite already present #defines
# TODO: Add possibility for #defines with value
inherit u-boot-header-mod

DEFINE_CONFIGS ?= " \
  CONFIG_ENV_IS_NOWHERE \
  "

DEFINE_OVERWRITE ?= "CONFIG_BOOTCOMMAND"
DEFINE_APPEND ?= "CONFIG_EXTRA_ENV_SETTINGS"

#########################################################################################
# Auxiliary functions
def createDics(d, defs_app, defs_ow):
  return ({x: d.getVarFlag("DEFINE_APPEND", x, True) for x in defs_app}, {x: d.getVarFlag("DEFINE_OVERWRITE", x, True) for x in defs_ow})

def constructAppList(lines):
  return ['\t"' + line + '\\0" \\ \n' for line in lines.split("\n") if line is not '']

def constructOwList(lines):
  return ['\t"' + line + '\\0" \n' for line in lines.split("\n") if line is not '']

def parseRawDef(line):
  return line.split()[1]

def constructDefine(defs):
  return ['#define ' + d + '\n' for d in defs]

#############
# DEALING WITH INPUT
def determineHeaderName (d):
  import os.path

  # Aux function, handle error
  def directDef(t):
    if t is None or len(t) == 0:
      bb.fatal("Error: No header file found. Consider manually defining it here: DIRECT_HEADER_FILE_NAME")
    else:
      return direct_target + '.h'

  fn = d.getVar('B', True) + "/boards.cfg"
  direct_target = d.getVar('DIRECT_HEADER_FILE_NAME', True)
  machine  = d.getVar('UBOOT_MACHINE', True).rsplit('_',1)[0]

  if os.path.isfile(fn):
    l = filter ((lambda s: machine in s.split()), [line for line in open(fn)])

    if len(l) != 1:
      bb.warn("We found multiple header definitions for: %s. Trying direct definition." %machine)
      return directDef(direct_target)

    l = l[0].split()
  else:
    bb.warn("We were unable to determine the name of the header file. Trying direct definition.")
    return directDef(direct_target)

  return l[l.index(machine) + 1].split(':', 1)[0] + '.h'

def parseEnvAppend (src):
  import os.path

  if os.path.isfile(src):
    with open(src) as f:
      return f.read()

  bb.warn("Environment append %s not found. Skipping..." %src)
  return ""
###########################
# ENGINE FOR SEARCH AND EDIT
def wrapWrite(src, b, c):
  f = open(src, 'r+')
  f.seek(c, 0)
  f.truncate()
  f.writelines(b)
  f.close()

def initBuffer(buffer, flags):
  found  = set()
  cursor = 0

  for line in buffer:
    cursor += len(line)

    if "#define" in line:
      found.add(parseRawDef(line))

      if parseRawDef(line) in flags:
        return (buffer[buffer.index(line):], found, cursor)

  return ([], found, 0)

def runBuffer(buffer, defs, defs_app, defs_ow):
  # Re-factor function
  def findNext(b):
    i = 0
    while not '#define' in b[i]:
      if i < len(b) - 1:
        i += 1
      else:
        return i
    return i

  if not buffer:
    return []

  i = findNext(buffer)
  conf = parseRawDef(buffer[i])

  if conf in defs:
    defs.remove(conf)
    return (buffer[:i + 1] + runBuffer(buffer[i + 1:], defs, defs_app, defs_ow))
  if conf in defs_app:
    return (buffer[:i + 1] + constructAppList(defs_app[conf]) + runBuffer(buffer[i + 1:], defs, defs_app, defs_ow))
  if conf in defs_ow:
    return (buffer[:i + 1] + constructOwList(defs_ow[conf]) + runBuffer(buffer[i + findNext(buffer[i+1:]) :], defs, defs_app, defs_ow))
  else:
    return (buffer[:i + 1] + runBuffer(buffer[i + 1:], defs, defs_app, defs_ow))

def compute_header(src, defs, defs_app, defs_ow):
  import os.path

  cursor  = 0
  buf     = []

  if os.path.isfile(src):
    f = open(src, 'r')
    buf = f.readlines()
    f.close()
  else:
    bb.fatal("File not found: %s" %src)

  (buf, found, cursor) = initBuffer(buf, defs_app.keys() + defs_ow.keys())

  defs -= set(found)
  buf = runBuffer(buf, defs, defs_app, defs_ow)[1:]
  wrapWrite(src, constructDefine(defs) + buf, cursor)
#########################################################################################
# Bitbake task
#
python do_resin_inject_header() {
    defs = set(d.getVar("DEFINE_CONFIGS", True).split())

    header_path = d.getVar("B", True) + '/include/configs/' + determineHeaderName(d)

    defs_app = d.getVar("DEFINE_APPEND", True).split()
    defs_ow = d.getVar("DEFINE_OVERWRITE", True).split()

    #Treat the env append like any othe value
    if "CONFIG_EXTRA_ENV_SETTINGS" in defs_app + defs_ow:
      env = ""
      for file in d.getVar("APPEND_ENV_FILE", True).split():
        env += parseEnvAppend(d.getVar("WORKDIR", True) + "/" + file)
      d.setVarFlag("DEFINE_APPEND",  "CONFIG_EXTRA_ENV_SETTINGS", env)

    (defs_app, defs_ow) = createDics(d, defs_app, defs_ow)

    compute_header(header_path, defs, defs_app, defs_ow)
}

addtask do_resin_inject_header after do_patch before do_compile
do_resin_inject_header[vardeps] += "DEFINE_CONFIGS APPEND_ENV_FILE UBOOT_MACHINE"
do_resin_inject_header[deptask] += "do_unpack"
do_resin_inject_header[dirs] += "${WORKDIR} ${B}"

do_compile[deptask] += "do_resin_inject_header"
