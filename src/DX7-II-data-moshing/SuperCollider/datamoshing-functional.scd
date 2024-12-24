(
~inFile = "rom2a.syx";
)

(
~readSysex = {
  arg path;
  var sysexFile, sysexFileAsIntFull;

  sysexFile = File.new(path, "rb");
  sysexFileAsIntFull = Array.new(sysexFile.length);

  sysexFile.length.do({
    sysexFileAsIntFull.add(sysexFile.getInt8);
  });

  sysexFileAsIntFull;
}
)

(
~deconstructSysex = {
  arg sysexFileAsIntFull;
  var header, data, checksum, end;

  header = sysexFileAsIntFull.copyRange(0, 5);
  // data = sysexFileAsIntFull.copyRange(6, 6 + 4096 - 1); // trimming version
  data = sysexFileAsIntFull.copyRange(6, sysexFileAsIntFull.size - sysexFileAsIntFull.reverse.indexOf(-9) - 3); // reverse because data bytes maybe have MIDI Data (> 127)
  checksum = sysexFileAsIntFull[sysexFileAsIntFull.size - sysexFileAsIntFull.reverse.indexOf(-9) - 2];
  end = sysexFileAsIntFull.copyRange(sysexFileAsIntFull.size - sysexFileAsIntFull.reverse.indexOf(-9) - 1, sysexFileAsIntFull.size);

  ("Sysex Header:\n" + header + "\nSysexEnd:\n" + end).postln;
  ("Checksum:\n" + checksum).postln;
  [header, data, end];
};
)

(
~generateChecksum = {
  arg data;
  var sum = 0;

  data.do({ |byte, i|
    sum = sum + byte;
    if((sum > 127), { sum = sum - 128; }, {})
  });
  sum = 128 - sum;

  sum;
}
)

~readSysex.(~inFile);
~deconstructSysex.(~readSysex.(~inFile));
~deconstructSysex.(~readSysex.(~inFile))[1].reverse;
~generateChecksum.(~deconstructSysex.(~readSysex.(~inFile))[1]);

(
~removeMIDI = {
  arg deconstructedSysex;

  deconstructedSysex[1] = deconstructedSysex[1] % 128;

  deconstructedSysex;
}
)

(
~removeMIDI = {
  arg data;

  data = data % 128;

  data;
}
)

~removeMIDI.(~generateChecksum.(~deconstructSysex.(~readSysex.(~inFile))[1]))

(
~scrambleData = {
  arg data;

  data = data.scramble;

  data;
}
)

(
~rotateData = {
  arg data, n;

  data = data.rotate(n);

  data;
}
)

~rotateData.([201, 305, 50], 1)

(
~generateRandomData = {
  arg data;

  data = {128.rand} ! data.size;

  data;
}
)

