/*
 * balenaOS specific configuration
 *
 * This should migrate to common layer as soon as all the supported yocto layers provides
 * a dropbear version which uses localoptions.h
 */

/* No need to run X over ssh. */
#define DROPBEAR_X11FWD 0

/* As reported by OpenVAS, CBC mode can allow an attacker to obtain plaintext from a block
of cyphertext. */
#define DROPBEAR_ENABLE_CBC_MODE 0

/* HMAC 96 is known to be a weak algorithm. It is reported by OpenVAS as a low severity
security issue. */
#define DROPBEAR_SHA1_96_HMAC 0

/* This is documented as "less secure" while in newer versions mentioned as "too small for
security". See:
https://github.com/mkj/dropbear/blob/d740dc548924f2faf0934e5f9a4b83d2b5d6902d/default_options.h#L141 */
#define DROPBEAR_DH_GROUP1 0
