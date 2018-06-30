(function() {
  'use strict';
  var dc, desktopCapturer, opts, quickconnect;

  ({desktopCapturer} = require('electron'));

  quickconnect = require('rtc-quickconnect');

  opts = {
    room: 'buddy',
    signaller: 'http://192.168.0.2:3000'
  };

  dc = null;

  window.sendMessage = function() {
    var message;
    message = document.querySelector('input[type=text]').value;
    messages.innerHTML += 'me: ' + message + '\n';
    return dc != null ? dc.send(message) : void 0;
  };

  desktopCapturer.getSources({
    types: ['screen', 'window']
  }, function(err, sources) {
    var handleEvents;
    console.log(sources);
    handleEvents = function(id, _dc) {
      dc = _dc;
      return dc.onMessage = function(event) {
        var messages;
        messages = document.querySelector('.messages');
        return messages.innerHTML += 'you: ' + event.data + '\n';
      };
    };
    return navigator.mediaDevices.getUserMedia({
      audio: false,
      video: true
    }).then(function(stream) {
      var video;
      console.log('stream', stream);
      video = document.querySelector('video');
      return quickconnect(opts.signaller, {
        room: opts.room,
        plugins: []
      }).createDataChannel('events').addStream(stream).on('call:started', function(id, pc, data) {
        video.srcObject = pc.getRemoteStreams()[0];
        return video.onloadedmetadata = function(e) {
          return video.play();
        };
      }).on('channel:opened:events');
    }, function(err) {
      var video;
      video = document.querySelector('video');
      return desktopCapturer.getSources({
        types: ['screen', 'window']
      }, function(err, sources) {
        return navigator.mediaDevices.getUserMedia({
          audio: false,
          video: {
            mandatory: {
              chromeMediaSource: 'desktop',
              chromeMediaSourceId: sources[4].id
            }
          }
        }).then(function(stream) {
          return quickconnect(opts.signaller, {
            room: opts.room,
            plugins: []
          }).createDataChannel('events').addStream(stream).on('call:started', function(id, pc, data) {
            video.srcObject = pc.getRemoteStreams()[0];
            return video.onloadedmetadata = function(e) {
              return video.play();
            };
          });
        });
      });
    });
  });

}).call(this);

//# sourceMappingURL=renderer.js.map
