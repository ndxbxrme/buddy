'use strict'
{desktopCapturer} = require 'electron'

desktopCapturer.getSources
  types: ['screen', 'window']
, (err, sources) ->
  console.log sources
  navigator.mediaDevices.getUserMedia
    audio: false
    video:
      mandatory:
        chromeMediaSource: 'desktop'
        chromeMediaSourceId: sources[3].id
  .then (stream) ->
    video = document.querySelector 'video'
    video.srcObject = stream
    video.onloadedmetadata = (e) ->
      console.log e
      video.play()