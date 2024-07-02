module.exports = [
{
	deviceType: process.env.DEVICE_TYPE,
	suite: `${__dirname}/../suites/hup`,
	config: {
		networkWired: false,
		networkWireless: false,
		downloadVersion: 'latest',
		balenaApiKey: process.env.BALENACLOUD_API_KEY,
		balenaApiUrl: process.env.BALENACLOUD_API_URL,
		organization: process.env.BALENACLOUD_ORG,
		sshConfig: {
			host: process.env.BALENACLOUD_SSH_URL,
			port: process.env.BALENACLOUD_SSH_PORT,
		}
	},
	image: `${__dirname}/balena-image.docker`,
	// This is the name of a folder or file containing extra artifacts needed for the test suite
	// E.g for the cm4-io-board provisioning the `secure-boot-msd` folder is required
	// This artifact/artifact must be copied into the `suites` folder before running the test
	artifacts: process.env.ARTIFACTS,
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
},
{
	deviceType: process.env.DEVICE_TYPE,
	suite: `${__dirname}/../suites/cloud`,
	config: {
		networkWired: false,
		networkWireless: false,
		balenaApiKey: process.env.BALENACLOUD_API_KEY,
		balenaApiUrl: process.env.BALENACLOUD_API_URL,
		organization: process.env.BALENACLOUD_ORG,
		sshConfig: {
			host: process.env.BALENACLOUD_SSH_URL,
			port: process.env.BALENACLOUD_SSH_PORT,
		}
	},
	image: `${__dirname}/balena.img.gz`,
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
	// This is the name of a folder or file containing extra artifacts needed for the test suite
	// E.g for the cm4-io-board provisioning the `secure-boot-msd` folder is required
	// This artifact/artifact must be copied into the `suites` folder before running the test
	artifacts: process.env.ARTIFACTS,
	workers: process.env.WORKER_TYPE === 'qemu' ? ['http://worker'] : {
		balenaApplication: process.env.BALENACLOUD_APP_NAME.split(','),
		apiKey: process.env.BALENACLOUD_API_KEY,
	},
},
{
	deviceType: process.env.DEVICE_TYPE,
	suite: `${__dirname}/../suites/os`,
	config: {
		networkWired: false,
		networkWireless: false,
		balenaApiKey: process.env.BALENACLOUD_API_KEY,
		balenaApiUrl: process.env.BALENACLOUD_API_URL,
		organization: process.env.BALENACLOUD_ORG,
		sshConfig: {
			host: process.env.BALENACLOUD_SSH_URL,
			port: process.env.BALENACLOUD_SSH_PORT,
		}
	},
	image: `${__dirname}/balena.img.gz`,
	// This is the name of a folder or file containing extra artifacts needed for the test suite
	// E.g for the cm4-io-board provisioning the `secure-boot-msd` folder is required
	// This artifact/artifact must be copied into the `suites` folder before running the test
	artifacts: process.env.ARTIFACTS,
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
];
