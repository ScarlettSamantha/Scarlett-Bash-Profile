function disable_ipv6() {
  echo "Disabling IPv6"
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
  sysctl -p
}

function enable_ipv6() {
  echo "Enabling IPv6"
  echo "net.ipv6.conf.all.disable_ipv6 = 0" >> /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 0" >> /etc/sysctl.conf
  echo "net.ipv6.conf.lo.disable_ipv6 = 0" >> /etc/sysctl.conf
  sysctl -p
}