# DX7 Datamoshing

While experimenting with the DX7 II•D for a performance at HfM Karlsruhe called STEM, we tried to upload patches through a faulty MIDI connection (at least that's our current guess) by sending SysEx data through Dexed's upload feature, we got some gnarly sounding patches that perfectly fit into our Drum & Bass aesthetic. That's how we stumbled upon the possibility of "DX7 Datamoshing", as we like to call it.

Through the standardised SysEx message format and the thorough implementation of the SysEx communication to and from the DX7 it is easy to send randomly generated bytes, as long as the header, checksum, endbyte and length of the actual patch data are correct.

As we can easily generate the checksum for our generated data, the only real pitfall was realising that all SysEx message bytes (= the actual patch data) are bound to being in the range of 0-127 (uint8 representation of hex data), as everything else are MIDI messages (as are the start (0xF0 = 240 uint8) and end (0xF7 = 247 uint8) bytes).