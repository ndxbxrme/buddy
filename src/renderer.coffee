'use strict'
{desktopCapturer} = require 'electron'
quickconnect = require 'rtc-quickconnect'
opts =
  room: 'buddy'
  signaller: 'http://192.168.0.2:3000'
dcs = []
window.sendMessage = ->
  message = document.querySelector 'input[type=text]'
  .value
  messages = document.querySelector '.messages'
  messages.innerHTML += 'me: ' + message + '\n'
  dcs.forEach (dc) ->
    dc.send message
desktopCapturer.getSources
  types: ['screen', 'window']
, (err, sources) ->
  console.log sources
  handleEvents = (id, _dc) ->
    console.log 'channel opened', id
    dcs.push _dc
    _dc.onmessage = (event) ->
      messages = document.querySelector '.messages'
      messages.innerHTML += 'you: ' + event.data + '\n'
  navigator.mediaDevices.getUserMedia
    audio: false
    video: true
  .then (stream) ->
    console.log 'stream', stream
    quickconnect opts.signaller,
      room: opts.room
      plugins: []
    .createDataChannel 'events'
    .addStream stream
    .on 'call:started', (id, pc, data) ->
      video = document.createElement 'video'
      document.querySelector '.videos'
      .appendChild video
      video.srcObject = pc.getRemoteStreams()[0]
      video.onloadedmetadata = (e) ->
        video.play()
    .on 'channel:opened:events', handleEvents
  , (err) ->
    desktopCapturer.getSources 
      types: ['screen', 'window']
    , (err, sources) ->
      navigator.mediaDevices.getUserMedia
        audio: false
        video:
          mandatory:
            chromeMediaSource: 'desktop'
            chromeMediaSourceId: sources[4].id
      .then (stream) ->
        quickconnect opts.signaller,
          room: opts.room
          plugins: []
        .createDataChannel 'events'
        .addStream stream
        .on 'call:started', (id, pc, data) ->
          video = document.createElement 'video'
          document.querySelector '.videos'
          .appendChild video
          video.srcObject = pc.getRemoteStreams()[0]
          video.onloadedmetadata = (e) ->
            video.play()
        .on 'channel:opened:events', handleEvents