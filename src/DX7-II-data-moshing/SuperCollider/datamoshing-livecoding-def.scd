(
/*
INIT
*/
(
~inFile = "../../../res/SysEx-Patches/Yamaha/rom2a.syx"; // based on repo as base dir
~dataSize = 4096;
);

(
~header = [];
~data = [];
~checksum = [];
~end = [];
~message = [];
);

(
~currentVoice = Array.new(128);
~currentVoiceNumber = 1; // 1 - 32
);

(
~dataUndoBuffer = Array.new();
);

// (
// ~voice_1 = Array.new(128);
// ~voice_2 = Array.new(128);
// ~voice_3 = Array.new(128);
// ~voice_4 = Array.new(128);
// ~voice_5 = Array.new(128);
// ~voice_6 = Array.new(128);
// ~voice_7 = Array.new(128);
// ~voice_8 = Array.new(128);
// ~voice_9 = Array.new(128);
// ~voice_10 = Array.new(128);
// ~voice_11 = Array.new(128);
// ~voice_12 = Array.new(128);
// ~voice_13 = Array.new(128);
// ~voice_14 = Array.new(128);
// ~voice_15 = Array.new(128);
// ~voice_16 = Array.new(128);
// ~voice_17 = Array.new(128);
// ~voice_18 = Array.new(128);
// ~voice_19 = Array.new(128);
// ~voice_20 = Array.new(128);
// ~voice_21 = Array.new(128);
// ~voice_22 = Array.new(128);
// ~voice_23 = Array.new(128);
// ~voice_24 = Array.new(128);
// ~voice_25 = Array.new(128);
// ~voice_26 = Array.new(128);
// ~voice_27 = Array.new(128);
// ~voice_28 = Array.new(128);
// ~voice_29 = Array.new(128);
// ~voice_30 = Array.new(128);
// ~voice_31 = Array.new(128);
// ~voice_32 = Array.new(128);
// );

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
};
);

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

  ~buildSysexMessage.();
};
);

// (
// ~getVoices = {
//   ~voice_1 = ~data[0..127];
//   ~voice_2 = ~data[128..255];
//   ~voice_3 = ~data[256..383];
//   ~voice_4 = ~data[384..511];
//   ~voice_5 = ~data[512..639];
//   ~voice_6 = ~data[640..767];
//   ~voice_7 = ~data[768..895];
//   ~voice_8 = ~data[896..1023];
//   ~voice_9 = ~data[1024..1151];
//   ~voice_10 = ~data[1152..1279];
//   ~voice_11 = ~data[1280..1407];
//   ~voice_12 = ~data[1408..1535];
//   ~voice_13 = ~data[1536..1663];
//   ~voice_14 = ~data[1664..1791];
//   ~voice_15 = ~data[1792..1919];
//   ~voice_16 = ~data[1920..2047];
//   ~voice_17 = ~data[2048..2175];
//   ~voice_18 = ~data[2176..2303];
//   ~voice_19 = ~data[2304..2431];
//   ~voice_20 = ~data[2432..2559];
//   ~voice_21 = ~data[2560..2687];
//   ~voice_22 = ~data[2688..2815];
//   ~voice_23 = ~data[2816..2943];
//   ~voice_24 = ~data[2944..3071];
//   ~voice_25 = ~data[3072..3199];
//   ~voice_26 = ~data[3200..3327];
//   ~voice_27 = ~data[3328..3455];
//   ~voice_28 = ~data[3456..3583];
//   ~voice_29 = ~data[3584..3711];
//   ~voice_30 = ~data[3712..3839];
//   ~voice_31 = ~data[3840..3967];
//   ~voice_32 = ~data[3968..4095];
// };
// );

// (
// ~dataFromVoices = {
//   ~data = ~voice_1 ++ ~voice_2 ++ ~voice_3 ++ ~voice_4 ++ ~voice_5 ++ ~voice_6 ++ ~voice_7 ++ ~voice_8 ++ ~voice_9 ++ ~voice_10 ++ ~voice_11 ++ ~voice_12 ++ ~voice_13 ++ ~voice_14 ++ ~voice_15 ++ ~voice_16 ++ ~voice_17 ++ ~voice_18 ++ ~voice_19 ++ ~voice_20 ++ ~voice_21 ++ ~voice_22 ++ ~voice_23 ++ ~voice_24 ++ ~voice_25 ++ ~voice_26 ++ ~voice_27 ++ ~voice_28 ++ ~voice_29 ++ ~voice_30 ++ ~voice_31 ++ ~voice_32;
// };
// );

(
~generateChecksum = {
  ~checksum = 0;

  ~data.do({ |byte, i|
    ~checksum = ~checksum + byte;
    if((~checksum > 127), { ~checksum = ~checksum - 128; }, {})
  });
  ~checksum = 128 - ~checksum;

  ~checksum = [~checksum];
};
);

(
~buildSysexMessage = {
  ~addToUndoBuffer.();
  ~message = ~header ++ ~data ++ ~checksum ++ ~end;
};
);

// tools
(
~addToUndoBuffer = {
  ~dataUndoBuffer = ~dataUndoBuffer.add(~data);
};
);

(
// destructive (deletes steps after the one you are currently on) for now.
~undo = {
  arg steps; // 0 Steps does nothing, 1 step undoes one action performed on ~data
  var undoIndex = ~dataUndoBuffer.size - 1 - steps;

  if(undoIndex >= 0,
    {
      ~data = ~dataUndoBuffer[undoIndex];
      ~dataUndoBuffer = ~dataUndoBuffer.extend(~dataUndoBuffer.size - steps,nil);
    },
    {
      if(undoIndex < 0,
        { ~data = ~dataUndoBuffer[0]; },
        { "Please initialize SysEx data first. You can do this by executing the ~buildSysexMessage.() function.".postln; }
      );
    }
  );
  // ~buildSysexMessage.()
  ~message = ~header ++ ~data ++ ~checksum ++ ~end;
};
);

(
~setCurrentVoiceNumber = {
  arg num;
  ~currentVoiceNumber = num.clip(1,32);
};
);

(
~getCurrentVoiceNumber = {
  ~currentVoiceNumber = ~currentVoiceNumber.clip(1,32);
};
);

(
~removeMIDIData = {
  ~data = ~data % 128;
  ~buildSysexMessage.()
};
);

(
~trimEndData = {
  ~data = ~data.copyRange(0, ~dataSize - 1);
  ~buildSysexMessage.()
};
);

(
~trimStartData = {
  ~data = ~data.reverse.copyRange(0, ~dataSize - 1).reverse;
  ~buildSysexMessage.()
};
);

// modification
// // data
(
~scrambleData = {
  ~data = ~data.scramble;
  ~buildSysexMessage.()
};
);

(
~rotateData = {
  arg n;
  ~data = ~data.rotate(n);
  ~buildSysexMessage.()
};
);

(
~generateRandomData = {
  ~data = {128.rand} ! ~data.size;
  ~buildSysexMessage.()
};
);

// // voice
(
~getCurrentVoice = {
  var startIndex = ~getCurrentVoiceNumber.() - 1 * 128, endIndex = ~getCurrentVoiceNumber.() * 128 - 1;

  ~currentVoice = ~data[startIndex..endIndex];

  ~currentVoice;
};
);

(
~setVoice = {
  var left = ~data.copyRange(0, (~getCurrentVoiceNumber.() - 1 * 128 - 1)), right = ~data.copyRange((~getCurrentVoiceNumber.() * 128), 4096);

  ~data = left ++ ~currentVoice ++ right;
  ~buildSysexMessage.();
};
);

(
~scrambleVoice = {
  ~currentVoice = ~getCurrentVoice.().scramble;
  ~setVoice.();
};
);

(
~rotateVoice = {
  arg n;
  ~currentVoice = ~getCurrentVoice.().rotate(n);
  ~setVoice.();
};
);

(
~generateRandomVoice = {
  ~currentVoice = {128.rand} ! ~getCurrentVoice.().size;
  ~setVoice.();
};
);
)
