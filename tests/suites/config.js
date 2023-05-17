module.exports = [
{
	deviceType: process.env.DEVICE_TYPE,
	suite: `${__dirname}/../suites/hup`,
	config: {
		networkWired: false,
		networkWireless: false,
		downloadVersion: 'latest',
		balenaApiKey: process.env.BALENACLOUD_API_KEY,
		balenaApiUrl: 'balena-cloud.com',
		organization: process.env.BALENACLOUD_ORG,
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
		balenaApplication: process.env.BALENACLOUD_APP_NAME,
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
		balenaApiUrl: 'balena-cloud.com',
		organization: process.env.BALENACLOUD_ORG,
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
	workers: process.env.WORKER_TYPE === 'qemu' ? ['http://worker'] : {
		balenaApplication: process.env.BALENACLOUD_APP_NAME,
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
		balenaApiUrl: 'balena-cloud.com',
		organization: process.env.BALENACLOUD_ORG,
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
	workers: process.env.WORKER_TYPE === 'qemu' ? ['http://worker'] : {
		balenaApplication: process.env.BALENACLOUD_APP_NAME,
		apiKey: process.env.BALENACLOUD_API_KEY,
	},
}
];
