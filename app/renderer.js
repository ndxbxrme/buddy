(function() {
  'use strict';
  var desktopCapturer;

  ({desktopCapturer} = require('electron'));

  desktopCapturer.getSources({
    types: ['screen', 'window']
  }, function(err, sources) {
    console.log(sources);
    return navigator.mediaDevices.getUserMedia({
      audio: false,
      video: {
        mandatory: {
          chromeMediaSource: 'desktop',
          chromeMediaSourceId: sources[3].id
        }
      }
    }).then(function(stream) {
      var video;
      video = document.querySelector('video');
      video.srcObject = stream;
      return video.onloadedmetadata = function(e) {
        console.log(e);
        return video.play();
      };
    });
  });

}).call(this);

//# sourceMappingURL=renderer.js.map
