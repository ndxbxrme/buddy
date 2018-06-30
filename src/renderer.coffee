'use strict'
{desktopCapturer} = require 'electron'
quickconnect = require 'rtc-quickconnect'
opts =
  room: 'buddy'
  signaller: 'http://192.168.0.2:3000'
dcs = {}

document.querySelector 'input[type=text]'
.focus()
window.sendMessage = ->
  messageElm = document.querySelector 'input[type=text]'
  message = messageElm.value
  messageElm.value = ''
  messages = document.querySelector '.messages'
  messages.innerHTML += 'me: ' + message + '\n'
  for id, dc of dcs
    dc.send message
desktopCapturer.getSources
  types: ['screen', 'window']
, (err, sources) ->
  console.log sources
  handleEvents = (id, _dc) ->
    console.log 'channel opened', id
    dcs[id] = _dc
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
    .on 'call:ended', (id) ->
      document.querySelector 'video[data-peer=' + id + ']'
      .remove()
    .on 'channel:opened:events', handleEvents
    .on 'channel:closed:events', (id) ->
      delete dcs[id]
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
          video.dataset.peer = id
          document.querySelector '.videos'
          .appendChild video
          video.srcObject = pc.getRemoteStreams()[0]
          video.onloadedmetadata = (e) ->
            video.play()
        .on 'call:ended', (id) ->
          document.querySelector 'video[data-peer=' + id + ']'
          .remove()
        .on 'channel:opened:events', handleEvents
        .on 'channel:closed:events', (id) ->
          delete dcs[id]