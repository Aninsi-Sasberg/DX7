/*
INIT
*/
(
~inFile = "rom2a.syx";
~dataSize = 4096;
)

(
~header = [];
~data = [];
~checksum = [];
~end = [];
~message = [];
)

/*
FUNCTIONS
*/
(
~readSysex = {
  var sysexFile, sysexFileAsIntFull;

  sysexFile = File.new(~inFile, "rb");
  sysexFileAsIntFull = Array.new(sysexFile.length);

  sysexFile.length.do({
    sysexFileAsIntFull.add(sysexFile.getInt8);
  });

  ~message = sysexFileAsIntFull;
}
)
~readSysex.();

(
~deconstructSysex = {
  ~header = ~message.copyRange(0, 5);
  // data = ~message.copyRange(6, 6 + 4096 - 1); // trimming version
  ~data = ~message.copyRange(6, ~message.size - ~message.reverse.indexOf(-9) - 3); // reverse because data bytes maybe have MIDI Data (> 127)
  // ~checksum = [~message[~message.size - ~message.reverse.indexOf(-9) - 2]]; // value, not array
  ~checksum = ~message.copyRange(~message.size - ~message.reverse.indexOf(-9) - 2, ~message.size - ~message.reverse.indexOf(-9) - 2);
  ~end = ~message.copyRange(~message.size - ~message.reverse.indexOf(-9) - 1, ~message.size);

  ("Sysex Header:\n" + ~header + "\nSysexEnd:\n" + ~end).postln;
  ("Checksum:\n" + ~checksum).postln;

  ~data;
};
)
~deconstructSysex.();

(
~generateChecksum = {
  ~checksum = 0;

  ~data.do({ |byte, i|
    ~checksum = ~checksum + byte;
    if((~checksum > 127), { ~checksum = ~checksum - 128; }, {})
  });
  ~checksum = 128 - ~checksum;

  ~checksum = [~checksum];
}
)
~generateChecksum.();

(
~buildSysexMessage = {
  ~message = ~header ++ ~data ++ ~checksum ++ ~end;
}
)
~buildSysexMessage.();

// tools
(
~removeMIDIData = {
  ~data = ~data % 128;
	~buildSysexMessage.()
}
)
~removeMIDIData.();

(
~trimEndData = {
  ~data = ~data.copyRange(0, ~sizeData - 1);
	~buildSysexMessage.()
}
)
~trimEndData.();

(
~trimStartData = {
  ~data = ~data.reverse.copyRange(0, ~sizeData - 1).reverse;
	~buildSysexMessage.()
}
)
~trimStartData.();

// modification
(
~scrambleData = {
  ~data = ~data.scramble;
	~buildSysexMessage.()
}
)
~scrambleData.();

(
~rotateData = {
  arg n;
  ~data = ~data.rotate(n);
	~buildSysexMessage.()
}
)
~rotateData.(1);

(
~generateRandomData = {
  ~data = {128.rand} ! ~data.size;
	~buildSysexMessage.()
}
)
~generateRandomData.();
