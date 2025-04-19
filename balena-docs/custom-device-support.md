---
title: Balena Custom Device Support (CDS)
description: Balena's CDS ensures seamless integration of your preferred hardware with balenaCloud. From evaluation to ongoing maintenance, get custom balenaOS versions, automated testing, upgrades, and dedicated support when you work with us. Explore the CDS process, pricing, and minimum specs needed for flexible hardware use.
keywords: [CDS, balena, device, support, pricing, hardware]
---


# Balena Custom Device Support (CDS)

## Overview

For a device to be compatible with the balenaCloud platform, it needs to run balenaOS, our minimal Linux distribution built with Yocto and designed to run containers.

Balena supports a wide range of Linux SBCs and SOMs, but occasionally our list of supported devices will not include the device you would like to use. In order to allow our customers to have the freedom to use their preferred hardware with balena, we offer our Custom Device Support service (CDS).

Our device support team will build a custom version of balenaOS specifically for your device type, making sure we meet all of your hardware requirements. We will periodically build, test, and release upgrades to the device OS in order to keep it up to date with [meta-balena](https://github.com/balena-os/meta-balena). Your custom device type and its associated custom device OS will be available to download in the balenaCloud dashboard. The outcome of CDS is a production-grade custom version of balenaOS built for your Linux device of choice, with ongoing support including test-and-release for upgraded OS versions.

## Included With Custom Device Support

- **Initial development:** Build and test a custom balenaOS image for your device type, including automated testing.
- **Ongoing upgrades:** We will periodically upgrade your device type’s host OS to incorporate new features, security patches, bug fixes, kernel upgrades, vendor-provided BSP updates, etc.
- **Ongoing tests:** We will test every new version of the host OS on your exact device in our testing rig.
- **Ongoing releases:** We will release every new version of the host OS so that it’s available for download via the balenaCloud dashboard.
- **Troubleshooting:** Our device support team will assist you with questions, issues, or feature requests you have for your device’s OS.

**Note on testing:** Once we have the patches for the board we will add your hardware to the testing rig in order to have the automated tests run with each PR. In the future, we intend to ship testing rigs to CDS customers for faster turnaround time on new release testing. The tests balena runs are documented here: [https://github.com/balena-os/meta-balena/tree/master/tests](https://github.com/balena-os/meta-balena/tree/master/tests). There are three categories of tests: cloud tests, OS tests, and host OS updates tests. However, not *all* the boards can be tested on the test rig and might require a different process.

## Description of Work

### Step 1: Evaluation

Evaluation of your custom hardware is the first step in balena’s Custom Device Support process. It allows balena engineers to estimate the scope of the work required to develop the balenaOS image. After scoping is complete, balena will provide a quote covering the initial development (one time) and ongoing maintenance fees to get your hardware onto balenaCloud. Assuming the device bring up requires a custom host OS and base images, our standard pricing will apply: [https://www.balena.io/pricing/#custom-device-support](https://www.balena.io/pricing/#custom-device-support)

In order to complete this work, balena will require submission of the following form to ensure all relevant documentation and software components are shared with our engineers to prevent delays in starting the evaluation process. [https://balena.typeform.com/to/OXJXXb](https://balena.typeform.com/to/OXJXXb)

Additionally, please review the information below and, if you are not already including these details in the documentation you share with us via the above link, please share it with your Customer Success representative via email.

### Step 2: Development

Upon acceptance of the quote produced in the evaluation, balena will develop a production-grade, custom version of balenaOS, built specifically for your chosen hardware. Our devices team will use the information gathered in the CDS questionnaire and from liaising with your technical point of contact. We will need you to send our team a board (and any peripherals) for the evaluation. More information on the technical process can be viewed here: [https://github.com/balena-os/meta-balena/blob/master/contributing-device-support.md](https://github.com/balena-os/meta-balena/blob/master/contributing-device-support.md)

### Step 3: Ongoing Maintenance

Once an OS for a custom device type is available in the production dashboard, balena will be providing ongoing support as part of the maintenance phase. This includes updates to the custom device type in the case of hardware changes, support for device type specific questions in our support queue, as well as test-and-release of upgraded balenaOS versions.

## Pricing

Based on the information gathered in the Evaluation (Step 1), we will evaluate and provide a quote for your specific board. Upon receiving the devices, balena reserves the right to reissue the quote in the event that the information previously gathered isn't accurate or there is more complexity involved in the bring-up (EX: it requires Yocto BSP support).

To learn more about pricing and ongoing costs, see the [CDS section on balena's pricing page](https://www.balena.io/pricing/#custom-device-support).

## FAQ

How long does the development process take?

- It depends on the workload of the balena Devices team, but a general guide is 4-6 weeks from the date the hardware is received.

I don’t want my device type to be visible to the balena community, can it be private to my org?

- If you require that your custom device is confidential/private to your team (i.e. not available for all users to download via the balenaCloud dashboard), talk to us about private device type options.

What happens if I make a major hardware revision?

- Additional hardware revisions that, for example, involve modifying the DTB, may be subject to additional charges to cover any relevant modification and testing.

I have a custom LTE modem I want to use with my board, is that covered?

- Peripherals (e.g. modems) may require additional custom support and testing from the balena team, and may increase the cost of providing custom device support.

My hardware does not currently have Yocto support, can I still use Custom Device Support to onboard it to balena?

- Any hardware that does not have Yocto support will have a different cost structure than the listed standard pricing.

Will my custom device type be able to get balena ESR releases?

- Yes, we are continuing to add more devices to our testing rig that will allow them to get ESR releases as well as the balena rolling release.

Can I request custom changes at the hostOS level using this service?

- CDS is intended to support new device types in balenaOS, it is not intended as a means to customize balenaOS at the meta-balena layer. Yocto layers specific to the device type can be modified as necessary in order to support the functionality of the device.

## CDS Requirements

### Minimum Device Specs

- 1GB RAM or greater
- 4GB Storage or greater
- Block-based storage (eMMC, SDcard, SSDs, HDDS, NAND/NOR flash not supported)
- Currently supported Linux kernel, preferable LTS (Long Term Support); e.g. v4.14 (LTS end of life in Jan 2024)

### Documentation

- Basic Hardware Specs: We'll want to know all pertinent information including processor, available RAM, storage etc and all associated details.
- Vendor Documentation: Any documentation you are aware of, particularly documentation which provides a detailed description of your device's boot process.
- Datasheet: Preferably one that discusses your device's boot process in as much detail as possible
- Logo - A logo that would appear in the balenaCloud UI for your device type.

### Software

- BSP Layer: This is preferably a vendor-supported distribution of a Yocto BSP. Please also include components versions, location of sources, and license details where applicable. BSP support (including but not limited to bootloader, kernel, and firmware) must be provided by the customer and/or OEM. Balena is not responsible for maintaining or providing these components.
- If Yocto support does not exist, we will communicate in more detail with the assigned Technical Point of Contact throughout the process about exact needs for your specific board, but at a minimum we will require the following:
  - Bootloader sources
  - Kernel sources
  - Bootloader and Kernel configs required for this hardware
  - Documentation for provisioning an OS image
  - Documentation on booting options, including:
    - How the hardware boots from microSD, USB, eMMC, etc.
    - If any dip switches or jumpers need to be set to configure where the boot firmware loads the bootloader from, etc.
  - Firmware for connectivity, such as Bluetooth or Wi-Fi
- Existing Linux Support: If this is not already included in the documentation above, let us know if there are any known linux distributions which both your application stack and this board run on (eg Ubuntu 20.04). Provide details and/or links to repos where applicable.

### Additional

- Technical Point of Contact: Name and email address of the primary technical point of contact on your team. We will interface with this person to ask specific questions along the way and to help with testing and validating early versions of the OS images we will produce.
- Minimum Peripherals Requirements: Let us know if the custom image needs to support certain connectivity methods, cellular modems, or other peripherals.
- Timeline: Let us know when you intend to have a working version of the balenaOS image and when you expect to have devices running balenaOS in production.
- Legal: Let us know if there are any export control regulations that might apply to the board. Also, we will need to know if there are any other licensing or legal considerations that might require special handling.
- Confidentiality: Let us know if you have any requirements about the confidentiality of the balenaOS repos, base images, and any other public mentions of your device. In particular:
  - The GitHub repository for this device type will be public, unless you let us know you prefer to keep it private Note: balena will charge for the costs associated with a private GitHub repository should you require this.
  - Let us know if you want this device type to be **Public** in balenaCloud and thus available for any balena customer or if you wish it be **Private** and only available to people in your Organization.

**Note:** A CDS customer will also confirm these aspects when going through our information gathering form when initiating evaluation: [https://balena.typeform.com/to/OXJXXb](https://balena.typeform.com/to/OXJXXb)

## Sending Equipment and Devices to Balena

- Two boards sent to our team in Galati for development and testing, to be replaced with new hardware revisions as needed. In addition to the boards, you should also send power supplies and any serial console cables. Balena has the cables necessary to connect a serial debug console for your board as long as it is accessible through USB, TTL pins, or RS232.
- Please complete [this form](https://forms.gle/xzGfC9SksrYcmGja6) to schedule a DHL pickup for the required equipment.

- Alternatively, you can ship the equipment to our team in Athens, and they will forward it to our Galati, Romania office. To ship the equipment follow the steps below:

1. You can ship the equipment to the following address:

``` 
Attn: Stefanos Sakellariou
Company Name: Balenaio Ltd
Address: Epaminonda 4, 1st Floor, 121 34, Peristeri Greece
Email: distribution@balena.io
```

2. After sending the shipment, please follow the following steps:
   
  - Please send the tracking details and a description of the package to `distribution@balena.io` with the subject line: `Tracking Details from (YOUR COMPANY NAME)`.

  - If you are sending the device from a non-EU country, please attach the invoice to `distribution@balena.io` with the following note:

```
For customs use only. 
This device is not for sale - No payment is needed for this invoice.
The device is intended for software support to BalenaCloud only.
```

  - In order to get devices past customs, please send a CE (“Conformite Europeenne”) if any.

Let us know on `distribution@balena.io` if you have any questions on the shipping process.

**Note 1:** These devices must be the same hardware version you are taking into production.

**Note 2:** Due to our devices being routed to our hardware team in Romania, the shipping and customs review process can take several weeks. However, we will provide a tracking number for your reference once the pickup process has been completed.

## Maintainership Agreement: Terms and Conditions

As part of balena’s maintenance of the new device type, the following is required from a CDS customer:

- Notification of any hardware changes, including new hardware shipped to balena for ongoing OS testing when necessary.
- Notification of any changes to bootloader sources, kernel versions, firmware versions, etc. as well as access to those files for inclusion with future versions of the device type.
- BSP support (including but not limited to bootloader, kernel, and firmware) must be provided by the customer and/or OEM. Balena is not responsible for maintaining or providing these components.

Future contact with balena can be made in the following ways:

- Submitting tickets through balena’s Support chat system (in the balenaCloud dashboard)
- Emailing your Customer Success contact at balena

If balena reaches out to the customer for questions about upcoming OS releases which require the customer's input, and balena does not receive response from the customer within 6 months, balena reserves the right to remove this device type from our dashboard and halt all actions related to its maintenance, or to make it a publicly available device type.

After discontinuance of support for this hardware by the manufacturer, or end of support for the Yocto version required by this hardware, balena commits to keeping the device type on the platform for up to two years, but with no further updates outside of critical security fixes if possible.
