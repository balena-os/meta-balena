#
# Add quotes around values not matching [A-Za-z0-9]*
# Failing to do so will confuse docker info
#
python do_fix_quotes () {
    import re
    lines = open(d.expand('${B}/os-release'), 'r').readlines()
    with open(d.expand('${B}/os-release'), 'w') as f:
        for line in lines:
            field = line.split('=')[0].strip()
            value = line.split('=')[1].strip()
            match = re.match(r"^[A-Za-z0-9]*$", value)
            if not match:
                value = '"' + value + '"'
            f.write('{0}={1}\n'.format(field, value))
}
addtask fix_quotes after do_compile before do_install
