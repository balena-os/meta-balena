module.exports = [{
	deviceType: `genericx86-64-ext`,
	suite: `${__dirname}/../suites/os`,
	config: {
		networkWired: false,
		networkWireless: false,
		interactiveTests: false, // redundant
		balenaApiKey: process.env.BALENA_CLOUD_API_KEY,
		balenaApiUrl: 'balena-cloud.com',
		organization: process.env.BALENA_CLOUD_ORG
	},
	image: `${__dirname}/balena.img.gz`,
	workers: ['http://localhost'],
},
{
	deviceType: `genericx86-64-ext`,
	suite: `${__dirname}/../suites/hup`,
	config: {
		networkWired: false,
		networkWireless: false,
		downloadVersion: 'latest',
		interactiveTests: false, // redundant
		balenaApiKey: process.env.BALENA_CLOUD_API_KEY,
		balenaApiUrl: 'balena-cloud.com',
		organization: process.env.BALENA_CLOUD_ORG
	},
	image: `${__dirname}/balena-image.docker`,
	workers: ['http://localhost'],
}];
