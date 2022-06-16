module.exports = [
{
	deviceType: process.env.DEVICE_TYPE,
	suite: `${__dirname}/../suites/hup`,
	config: {
		networkWired: false,
		networkWireless: process.env.WORKER_TYPE === 'qemu' ? false : true,
		downloadVersion: 'latest',
		balenaApiKey: process.env.BALENACLOUD_API_KEY,
		balenaApiUrl: 'balena-cloud.com',
		organization: process.env.BALENACLOUD_ORG
	},
	image: `${__dirname}/balena-image.docker`,
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
		networkWireless: process.env.WORKER_TYPE === 'qemu' ? false : true,
		balenaApiKey: process.env.BALENACLOUD_API_KEY,
		balenaApiUrl: 'balena-cloud.com',
		organization: process.env.BALENACLOUD_ORG
	},
	image: `${__dirname}/balena.img.gz`,
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
		networkWireless: process.env.WORKER_TYPE === 'qemu' ? false : true,
		balenaApiKey: process.env.BALENACLOUD_API_KEY,
		balenaApiUrl: 'balena-cloud.com',
		organization: process.env.BALENACLOUD_ORG
	},
	image: `${__dirname}/balena.img.gz`,
	workers: process.env.WORKER_TYPE === 'qemu' ? ['http://worker'] : {
		balenaApplication: process.env.BALENACLOUD_APP_NAME,
		apiKey: process.env.BALENACLOUD_API_KEY,
	},
}
];
