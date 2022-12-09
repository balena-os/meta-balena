# Frequently Asked Questions (FAQ's)

## Why Docker containers on embedded devices?

We think that containers are essential to bringing modern development and deployment capabilities to connected devices. Linux containers, particularly Docker, offer, for the first time, a practical path to using virtualization on embedded devices. Virtual machines and hypervisors have lead to huge leaps in productivity and automation for cloud deployments, but their abstraction of hardware as well as their resource overhead and lack of hardware support means that they are out of the question for embedded scenarios. With OS-level virtualization as implemented for Linux Containers, both those objections are lifted for heterogeneous embedded Linux devices in the “Internet of Things.”

## Why Yocto?

Yocto Linux is an incredible toolkit for generating Linux distributions, with a focus on portability. Yocto’s minimal size and low footprint also make it ideal for running on devices. BalenaOS is built using Yocto at its core, and the balenaOS team maintains numerous BSPs for Yocto, among them the Raspberry Pi, Artik, and CHIP layers. Yocto acts as the foundation for many other embedded operating systems including Ostro, Wind River Linux, and Tizen, therefore acting as a mechanism for sharing best practices and code, benefitting all the resulting operating systems, balenaOS included.

Developers sometimes avoid Yocto due to its extremely minimal userspace and lack of a standard package manager. BalenaOS uses containers to run arbitrary base images within which developers can work, so that their interaction with the host userspace is rare. In this way we get the considerable portability benefits of Yocto, without suffering the workflow drawbacks for application developers.

## How is this different from cloud operating systems for containers?

BalenaOS shares a lot with cloud operating systems for containers. We share the focus on minimalism, getting out of the user’s way and letting their container do the heavy lifting, and using Docker, which is the standard way of running containers, and well understood by a large developer community. BalenaOS applies the same principles to a different domain, that of embedded Linux devices, sometimes called “connected devices”, “Internet of Things” or “Industrial Internet”, depending on the use case. While some of the cloud operating systems have been made to run on particular embedded devices, their architecture is geared towards the cloud, where they shine.

By applying the container paradigm to the embedded world, the BalenaOS team has faced and solved a unique set of challenges that are not common in the cloud and datacentre world, such as:

* The extreme heterogeneity of device types found in the wild;
* Severely restricted resource envelopes in terms of storage, CPU, and networking;
* Devices that are difficult to reach or re-provision upon failure, where power is unstable and may be turned off at any time, or with custom hardware attached.

BalenaOS is built for this world from scratch, and our deepest architectural and feature choices have been made exclusively with embedded devices in mind. BalenaOS is built for embedded devices, and this focus continues to drive our architectural objectives.

## How is this different from other embedded operating systems?

BalenaOS uniquely combines the virtues of mature embedded operating systems with the developer-focused sensibilities of cloud operating systems. Where the cloud operating systems don’t address the realities of the embedded world, embedded and IoT-focused Linux distributions don’t focus on containers. When they do, they often choose to reinvent the wheel rather than use Docker, which is the de-facto standard among developers. BalenaOS aims to be a competent embedded operating system and shares architectural principles with many existing systems, but also aims to unify the approach to containers with Docker.

While others have done a fantastic job evangelising the use of containers on embedded devices, balenaOS has the added benefit of focusing on portability, with 20 device types already supported, and production-readiness, with thousands of devices already deployed for business purposes.
