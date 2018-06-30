'use strict'
{desktopCapturer} = require 'electron'
quickconnect = require 'rtc-quickconnect'
opts =
  room: 'buddy'
  signaller: 'http://192.168.0.2:3000'
dc = null
window.sendMessage = ->
  message = document.querySelector 'input[type=text]'
  .value
  messages = document.querySelector '.messages'
  messages.innerHTML += 'me: ' + message + '\n'
  dc?.send message
desktopCapturer.getSources
  types: ['screen', 'window']
, (err, sources) ->
  console.log sources
  handleEvents = (id, _dc) ->
    dc = _dc
    dc.onMessage = (event) ->
      messages = document.querySelector '.messages'
      messages.innerHTML += 'you: ' + event.data + '\n'
  navigator.mediaDevices.getUserMedia
    audio: false
    video: true
  .then (stream) ->
    console.log 'stream', stream
    video = document.querySelector 'video'
    quickconnect opts.signaller,
      room: opts.room
      plugins: []
    .createDataChannel 'events'
    .addStream stream
    .on 'call:started', (id, pc, data) ->
      video.srcObject = pc.getRemoteStreams()[0]
      video.onloadedmetadata = (e) ->
        video.play()
    .on 'channel:opened:events', handleEvents
  , (err) ->
    video = document.querySelector 'video'
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
          video.srcObject = pc.getRemoteStreams()[0]
          video.onloadedmetadata = (e) ->
            video.play()
        .on 'channel:opened:events', handleEvents