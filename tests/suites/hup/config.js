module.exports = [
  {
    deviceType: process.env.DEVICE_TYPE,
    suite: `${__dirname}/../suites/hup`,
    config: {
      networkWired: false,
      networkWireless: false,
      downloadVersion: 'latest',
      downloadImageType: process.env.DOWNLOAD_IMAGE_TYPE,
      balenaApiKey: process.env.BALENACLOUD_API_KEY,
      balenaApiUrl: process.env.BALENACLOUD_API_URL,
      organization: process.env.BALENACLOUD_ORG,
      sshConfig: {
        host: process.env.BALENACLOUD_SSH_URL,
        port: process.env.BALENACLOUD_SSH_PORT,
      }
    },
    image: `${__dirname}/balena-image.docker`,
    debug: {
      // Exit the ongoing test suite if a test fails
      failFast: true,
      // Exit the ongoing test run if a test fails
      globalFailFast: false,
      // Persist downloadeded artifacts
      preserveDownloads: false,
      // Mark unstable tests to be skipped
      unstable: ['']
    },
    workers: process.env.WORKER_TYPE === 'qemu' ? ['http://worker'] : {
      balenaApplication: process.env.BALENACLOUD_APP_NAME.split(','),
      apiKey: process.env.BALENACLOUD_API_KEY,
    },
  }
]
