(function() {
  'use strict';
  var dcs, desktopCapturer, opts, quickconnect;

  ({desktopCapturer} = require('electron'));

  quickconnect = require('rtc-quickconnect');

  opts = {
    room: 'buddy',
    signaller: 'http://192.168.0.2:3000'
  };

  dcs = [];

  window.sendMessage = function() {
    var message, messageElm, messages;
    messageElm = document.querySelector('input[type=text]');
    message = messageElm.value;
    messageElm.value = '';
    messages = document.querySelector('.messages');
    messages.innerHTML += 'me: ' + message + '\n';
    return dcs.forEach(function(dc) {
      return dc.send(message);
    });
  };

  desktopCapturer.getSources({
    types: ['screen', 'window']
  }, function(err, sources) {
    var handleEvents;
    console.log(sources);
    handleEvents = function(id, _dc) {
      console.log('channel opened', id);
      dcs.push(_dc);
      return _dc.onmessage = function(event) {
        var messages;
        messages = document.querySelector('.messages');
        return messages.innerHTML += 'you: ' + event.data + '\n';
      };
    };
    return navigator.mediaDevices.getUserMedia({
      audio: false,
      video: true
    }).then(function(stream) {
      console.log('stream', stream);
      return quickconnect(opts.signaller, {
        room: opts.room,
        plugins: []
      }).createDataChannel('events').addStream(stream).on('call:started', function(id, pc, data) {
        var video;
        video = document.createElement('video');
        document.querySelector('.videos').appendChild(video);
        video.srcObject = pc.getRemoteStreams()[0];
        return video.onloadedmetadata = function(e) {
          return video.play();
        };
      }).on('channel:opened:events', handleEvents);
    }, function(err) {
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
            var video;
            video = document.createElement('video');
            document.querySelector('.videos').appendChild(video);
            video.srcObject = pc.getRemoteStreams()[0];
            return video.onloadedmetadata = function(e) {
              return video.play();
            };
          }).on('channel:opened:events', handleEvents);
        });
      });
    });
  });

}).call(this);

//# sourceMappingURL=renderer.js.map
