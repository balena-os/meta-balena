/* filter output of dfu-util and handle tee feature */
var stdin = WScript.StdIn;
var stdout = WScript.StdOut;
var fs = WScript.CreateObject("Scripting.FileSystemObject");
if ( WScript.arguments.length < 2 ) {
	WScript.Quit(3) ;
}

var f = fs.OpenTextFile(WScript.arguments(0), 8,true, 0);
var filterout = false
if ( WScript.arguments(1) == "on") {
	filterout = true;
}

while (!stdin.AtEndOfStream) {
	line = "";
	while (!stdin.AtEndOfLine) {
		carac = stdin.Read(1);
		line += carac;
		if ((carac == '\r')) {
			stdout.Write(line);
			line = ""
		}

	}
	stdin.Read(1);
	if (filterout) {
		if (line.indexOf("Download") >= 0 ) {
			stdout.write(line + '\n');
		}
	}
	else {
		stdout.write(line + '\n')
	}
	f.write(line + '\n');
}

f.Close();
