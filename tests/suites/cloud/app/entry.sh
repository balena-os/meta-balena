#!/bin/sh
# https://funprojects.blog/2021/04/11/a-web-server-in-1-line-of-bash/
run_server() {
	while true; do { \
		printf "HTTP/1.0 200 OK\r\nContent-Length: %s\r\n\r\n%s" \
			"$(printf "%s" "$1" | wc -c)" "$1"; \
		} | nc -l -p 80; \
	done
}

# https://raw.githubusercontent.com/balena-io-examples/balena-nodejs-hello-world/master/views/index.html
doc=$(cat <<'EOF'
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Welcome to balena!</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" media="screen" href="public/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="public/main.css" />
  </head>
  <body>
    <div class="header">
      <nav class="navbar">
        <div class="container d-flex justify-content-center">
          <a href="http://balena.io/" target="_blank">
            <img style="width: 6rem; height: auto;" src="public/logo.svg">
          </a>
        </div>
      </nav>
    </div>

    <div class="container mt-5 mb-5 p-0 pb-5">

      <div class="row d-flex flex-column align-items-center">
        <h1>Welcome to balena!</h1>
        <p class="text-center pl-5 pr-5 pt-0 pb-0">Now that you've deployed code to your device,<br /> explore the resources below to continue on your journey!</p>
      </div>

      <div class="row d-flex justify-content-center">
        <div class="box">
          <h5 class="title">Read our documentation</h5>
          <ul>
            <li>Learn how balena works behind the scenes</li>
            <li>Run multiple containers in your application</li>
            <li>Fast development with local development mode</li>
            <li>Deploy device configurations across your fleet</li>
            <li>And much more!</li>
          </ul>
          <br />
          <a class="button" href="https://www.balena.io/docs">Explore the balena documentation</a>
        </div>

        <div class="box">
          <h5 class="title">Discover more balena project ideas</h5>

          <p>Find inspiration for what to build next, deploy another cool project,<br /> or join your device to an open fleet!</p>
          <a class="button" href="https://hub.balena.io/">View projects on hub.balena.io</a>
          <br />
          <a href="https://github.com/balena-io-examples">balena example projects</a>
          <span class="separator">|</span>
          <a href="https://github.com/balenalabs">Projects by balena</a>
          <span class="separator">|</span>
          <a href="https://forums.balena.io/c/projects">Projects in our forums</a>
        </div>

        <div class="box">
          <h5 class="title">Get additional help</h5>
          <p>Need to ask a question or get product support?</p>
          <a class="button" href="https://forums.balena.io/">Visit our forums</a>
          <br />
          <a href="https://www.balena.io/contact-sales/">Contact sales</a>
          <span class="separator">|</span>
          <a href="https://www.balena.io/support/">Learn about balena support</a>
        </div>

      </div>

    </div>
    <canvas id="canvas"></canvas>
    <script src="public/confetti.js"></script>
  </body>
</html>
EOF
)

run_server "$doc"
