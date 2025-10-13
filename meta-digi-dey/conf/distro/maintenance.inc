# Use new NXP package mirror
FSL_MIRROR = "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/"

# Use GNU mirror instead of main server for GNU packages
GNU_MIRROR = "https://ftpmirror.gnu.org/gnu"

SRC_URI_prepend_pn-hostapd = "https://w1.fi/releases/hostapd-2.4.tar.gz "
SRC_URI_remove_pn-hostapd = "http://hostap.epitest.fi/releases/hostapd-2.4.tar.gz"
SRC_URI_prepend_pn-python-m2crypto = "https://pypi.python.org/packages/source/M/M2Crypto/M2Crypto-0.21.1.tar.gz "
SRC_URI_remove_pn-python-m2crypto = "http://pypi.python.org/packages/source/M/M2Crypto/M2Crypto-0.21.1.tar.gz"
SRC_URI_prepend_pn-python-m2crypto-native = "https://pypi.python.org/packages/source/M/M2Crypto/M2Crypto-0.21.1.tar.gz "
SRC_URI_remove_pn-python-m2crypto-native = "http://pypi.python.org/packages/source/M/M2Crypto/M2Crypto-0.21.1.tar.gz"
SRC_URI_prepend_pn-rng-tools = "https://downloads.sourceforge.net/project/gkernel/rng-tools/4/rng-tools-4.tar.gz "
SRC_URI_remove_pn-rng-tools = "http://heanet.dl.sourceforge.net/sourceforge/gkernel/rng-tools-4.tar.gz"
SRC_URI_prepend_pn-swig = "https://downloads.sourceforge.net/project/swig/swig/swig-2.0.12/swig-2.0.12.tar.gz "
SRC_URI_remove_pn-swig = "http://downloads.sourceforge.net/swig/swig-2.0.12.tar.gz"
SRC_URI_prepend_pn-swig-native = "https://downloads.sourceforge.net/project/swig/swig/swig-2.0.12/swig-2.0.12.tar.gz "
SRC_URI_remove_pn-swig-native = "http://downloads.sourceforge.net/swig/swig-2.0.12.tar.gz"
