'use strict'
{desktopCapturer} = require 'electron'
quickconnect = require 'rtc-quickconnect'
opts =
  room: 'buddy'
  signaller: 'http://192.168.0.2:3000'

desktopCapturer.getSources
  types: ['screen', 'window']
, (err, sources) ->
  console.log sources
  navigator.mediaDevices.getUserMedia
    audio: false
    video: true
  .then (stream) ->
    console.log 'stream', stream
    video = document.querySelector 'video'
    quickconnect opts.signaller,
      room: opts.room
      plugins: []
    .addStream stream
    .on 'call:started', (id, pc, data) ->
      video.srcObject = pc.getRemoteStreams()[0]
      video.onloadedmetadata = (e) ->
        video.play()
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
        .on 'call:started', (id, pc, data) ->
          video.srcObject = pc.getRemoteStreams()[0]
          video.onloadedmetadata = (e) ->
            video.play()