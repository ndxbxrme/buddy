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
    video.srcObject = stream
    video.onloadedmetadata = (e) ->
      console.log e
      video.play()
    quickconnect opts.signaller,
      room: opts.room
      plugins: []
    .addStream stream
  , (err) ->
    quickconnect opts.signaller,
      room: opts.room
      plugins: []
    .on 'call:started', (id, pc, data) ->
      video.srcObject = pc.getRemoteStreams()[0]