#!/bin/sh
# lte_modem_exporter.sh uses pipeserial to get modem info and signal strength

# output lte_modem_rssi
echo "# HELP lte_modem_rssi The current signal strength of the modem as returned by AT+CSQ."
echo "# TYPE lte_modem_rssi gauge"

# loop over modems and output rssi for each
for modem in "$@"; do
    # run ATI
    ATI=$(echo "ATI" | /usr/local/pipeserial_venv/bin/pipeserial "$modem" | tail +2)
    manu=$(echo "$ATI" | head -1 |  sed "s/^Manufacturer: //")
    model=$(echo "$ATI" | head -2 | tail -1 | sed "s/^Model: //")
    rev=$(echo "$ATI" | head -3 | tail -1 | sed "s/^Revision: //")

    # run AT+GSN
    serial=$(echo "AT+GSN" | /usr/local/pipeserial_venv/bin/pipeserial "$modem" | tail +2 | head -1)

    # run AT+CSQ
    CSQ=$(echo "AT+CSQ" | /usr/local/pipeserial_venv/bin/pipeserial "$modem" | grep "^+CSQ")
    rssi=$(echo "$CSQ" | cut -d " " -f 2 | cut -d "," -f 1)

    /bin/echo "lte_modem_rssi{device=\"$modem\", manufacturer=\"$manu\", model=\"$model\", revision=\"$rev\", serial=\"$serial\"} $rssi"
done
