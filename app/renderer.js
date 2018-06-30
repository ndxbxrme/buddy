(function() {
  'use strict';
  var desktopCapturer, opts, quickconnect;

  ({desktopCapturer} = require('electron'));

  quickconnect = require('rtc-quickconnect');

  opts = {
    room: 'buddy',
    signaller: 'http://192.168.0.2:3000'
  };

  desktopCapturer.getSources({
    types: ['screen', 'window']
  }, function(err, sources) {
    console.log(sources);
    return navigator.mediaDevices.getUserMedia({
      audio: false,
      video: true
    }).then(function(stream) {
      var video;
      console.log('stream', stream);
      video = document.querySelector('video');
      video.srcObject = stream;
      video.onloadedmetadata = function(e) {
        console.log(e);
        return video.play();
      };
      return quickconnect(opts.signaller, {
        room: opts.room,
        plugins: []
      }).addStream(stream);
    }, function(err) {
      var video;
      video = document.querySelector('video');
      return quickconnect(opts.signaller, {
        room: opts.room,
        plugins: []
      }).on('call:started', function(id, pc, data) {
        video.srcObject = pc.getRemoteStreams()[0];
        return video.onloadedmetadata = function(e) {
          return video.play();
        };
      });
    });
  });

}).call(this);

//# sourceMappingURL=renderer.js.map
