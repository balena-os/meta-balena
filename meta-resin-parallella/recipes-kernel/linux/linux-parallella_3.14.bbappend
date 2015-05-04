inherit kernel-resin

RESIN_CONFIGS_append = " led"
RESIN_CONFIGS[led] = " \
    CONFIG_NEW_LEDS=y \
    CONFIG_LEDS_CLASS=y \
    CONFIG_LEDS_TRIGGERS=y \
    CONFIG_LEDS_GPIO=y \
    "

RESIN_CONFIGS_DEPS[rce] += " \
    CONFIG_NET=y \
    CONFIG_NET_CORE=y \
    CONIFG_INET=y \
    CONFIG_NETFILTER=y \
    CONFIG_NETFILTER_ADVANCED=y \
    "
