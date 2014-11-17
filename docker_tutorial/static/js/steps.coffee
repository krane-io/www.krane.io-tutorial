###
  This is the main script file. It can attach to the terminal
###

COMPLETE_URL = "/whats-next/"


###
  Array of question objects
###

staticDockerPs = """
    ID                  IMAGE               COMMAND               CREATED             STATUS              PORTS
    """


q = []
q.push ({
html: """
      <h3>Getting started Krane Users</h3>
      <p>There are actually two programs: The Krane daemon, which is a server process and which manages all the
      the ships which have docker server installed on them, and the Krane client, which acts as a remote control on the daemon. On most systems, like in this
      emulator, both execute on the same host.</p>
      """
assignment: """
      <h3>Assignment</h3>
      <p>Check which Krane versions are running</p>
      <p>This will help you verify the daemon is running and you can connect to it. If you see which version is running
      you know you are all set.</p>
      """
tip: "<p>Try typing <code>krane</code> to see the full list of accepted arguments</p>
      <p>This emulator provides only a limited set of shell and Krane commands, so some commands may not work as expected</p>"
command_expected: ['krane', 'version']
result: """<p>Well done! Let's move to the next assignment.</p>"""
})

q.push ({
html: """
      <h3>Listing Available Clouds</h3>
      <p>The easiest way to get started is to use krane is by beeing able to see the availabe cloud providers 
      your Krane server can comission ships.
      """
assignment: """
      <h3>Assignment</h3>
      <p>Use the commandline to discover for a cloud provider server plan called tutorial-europe-2gb</p>
      """
command_expected: ['krane', 'plans', 'tutorial-europe-2gb']
result: """<p>You found it!</p>"""
tip: "the format is <code>krane plans &lt;string&gt;</code>"
})

q.push ({
html: """
      <h3>Create a Docker ship</h3>
      <p>Now that we have found a our server plan. Lets use krane to commission a ship with the followind data:</p>
      <ul>
        <li>Full Qualify Domain Name: <b>ship01.example.com</b></li>
        <li>Name: <b>ship01</b></li>
        <li>Server Plan Id: <b>53f0f0ecd8a5975a1c0001bd</b></li>
      </ul>
      <p>As you can see the server plan id is the same one we have found with our previous search.</p>
      """
assignment:
      """
      <h3>Assignment</h3>
      <p>Please comission a ship with the followin data</p>
      """

command_expected: ["krane", "commission", "-f", "\"ship01.example.com\"", "-n", "\"ship01\"", "-p", "\"53f0f0ecd8a5975a1c0001bd\""]
result: """<p>Cool. You have just created your first ship in our test cloud provider. You seen that an id has been retouned stating that the ships has been correctly created.</p>"""
tip: """<p>Look into <code>krane commision</code> to see which parameters you need to create the ship</p>
     """
})

q.push ({
html: """
      <h3>Starting a Docker container within a Krane ship</h3>
      <p>You can start a Docker container within a Krane ship in much the same way as you would start a container within Docker normally, but you need to add an extra parameter of <code>--ship SHIPNAME<code>.</p>
      """
assignment: """
      <h3>Assignment</h3>
      <p>In this case, you should start an Ubuntu container with <code>--detach=true --tty=false ubuntu /bin/bash</code></p>
      <p>Just as in Docker, the <code>--detach=true --tty=false</code> flag will make the container run in the background.</p>
      """
command_expected: ["krane", "run", "--ship=ship01.example.com", "--detach=true", "--tty=false", "ubuntu", "/bin/bash"]

result: """<p>Great! you have started your first multicloud container</p>"""

tip: """
     <p>The command <code>krane run</code> must be provided with a <code>--ship SHIPNAME</code> argument; use the ID of the previous ship you created in the last step.</p>
     within that image.</p>
     <p>Check the expected command below if it does not work as expected</p>
    """
})

q.push ({
html: """
      <h3>List all your Krane ships</h3>
      <p>Next we are going to list all your Krane ships, and the containers that are running within them.</p>
      """
assignment: """
      <h3>Assignment</h3>
      <p>List your Krane ships - you get to guess how.</p>
      """
command_expected: ["krane", "ships"]
result: """<p>That worked! You have listed all your krane ships</p>"""
tip: """
     <p>The second word in the command is <code>ships</code></p>
     """
})

q.push ({
html: """
      <h3>List all your containers</h3>
      <p>Next we are going to list all your containers deployed in ships.</p>
      """
assignment: """
      <h3>Assignment</h3>
      <p>List your containers deployed in ships.</p>
      """
command_expected: ["krane", "ps"]
result: """<p>That worked! You have listed all your containers</p>"""
tip: """
     <p>In docker is done with <code>ps</code> maybe in krane is done the same</p>
     """
})


q.push ({
html: """
      <h3>Stopping a Docker container within a Krane ship</h3>
      <p>The next step is to stop a Docker container that's running within the Krane ship. Krane already knows what ship each Docker container is using so you don't need to specify a ship here.</p>
      """
assignment: """
      <h3>Assignment</h3>
      <p>Stop the container that you started a couple of steps before.</p>
      """
command_expected: ["krane", "stop", "af3b2bb5e1"]
result: """<p>That worked! Please take note that Krane has returned the ID of the container it has stopped</p>"""
tip: """
     <p>Krane commands are just like Docker commands</p>
     """
})


q.push ({
html: """
      <h3>Decommissioning a ship</h3>
      <p>Now it's time to tidy things up and decommission the ship you commissioned earlier.</p>
      """
assignment: """
      <h3>Assignment</h3>
      <p> Use the Krane command line to decommission the ship <code>ship01.example.com</code></p>
      """
command_expected: ["krane", "decomission", 'ff2b1f65cb']
result: """<p>That worked! You have all the basic knowledge to use krane</p>"""
tip: """<ul>
     <li>Make sure you specify the ship id <code>ff2b1f65cb</code></li>
     </ul>"""
finishedCallback: () ->
  webterm.clear()
  webterm.echo( myTerminal() )

})


# the index arr
questions = []




###
  Register the terminal
###

@webterm = $('#terminal').terminal(interpreter, basesettings)




EVENT_TYPES =
  none: "none"
  start: "start"
  command: "command"
  next: "next"
  peek: "peek"
  feedback: "feedback"
  complete: "complete"



###
  Sending events to the server
###

logEvent = (data, feedback) ->
    # console.log data
    # ajax_load = "loading......";
    # loadUrl = "/tutorial/api/";
    # if not feedback
    #   callback = (responseText) -> $("#ajax").html(responseText)
    # else
    #   callback = (responseText) ->
    #     results.set("Thank you for your feedback! We appreciate it!", true)
    #     $('#feedbackInput').val("")
    #     $("#ajax").html(responseText)

    # if not data then data = {type: EVENT_TYPES.none}
    # data.question = current_question


    # $("#ajax").html(ajax_load);
    # $.post(loadUrl, data, callback, "html")



###
  Event handlers
###


## next
$('#buttonNext').click (e) ->

  # disable the button to prevent spacebar to hit it when typing in the terminal
  this.setAttribute('disabled','disabled')
  console.log(e)
  next()

$('#buttonFinish').click ->
  window.open(COMPLETE_URL)

## previous
$('#buttonPrevious').click ->
  previous()
  $('#results').hide()

## Stop mousewheel on left side, and manually move it.
$('#leftside').bind('mousewheel',
  (event, delta, deltaX, deltaY) ->
    this.scrollTop += deltaY * -30
    event.preventDefault()
  )

## submit feedback
$('#feedbackSubmit').click ->
  feedback = $('#feedbackInput').val()
  data = { type: EVENT_TYPES.feedback, feedback: feedback}
  logEvent(data, feedback=true)

## fullsize
$('#fullSizeOpen').click ->
  goFullScreen()

@goFullScreen = () ->
  console.debug("going to fullsize mode")
  $('.togglesize').removeClass('startsize').addClass('fullsize')

  $('.hide-when-small').css({ display: 'inherit' })
  $('.hide-when-full').css({ display: 'none' })

  next(0)

  webterm.resize()

  # send the next event after a short timeout, so it doesn't come at the same time as the next() event
  # in the beginning. Othewise two sessions will appear to have been started.
  # This will make the order to appear wrong, but that's not much of an issue.

  setTimeout( () ->
    logEvent( { type: EVENT_TYPES.start } )
  , 3000)


## leave fullsize
$('#fullSizeClose').click ->
  leaveFullSizeMode()

@leaveFullSizeMode = () ->
  console.debug "leaving full-size mode"

  $('.togglesize').removeClass('fullsize').addClass('startsize')

  $('.hide-when-small').css({ display: 'none' })
  $('.hide-when-full').css({ display: 'inherit' })

  webterm.resize()

## click on tips
$('#command').click () ->
  if not $('#commandHiddenText').hasClass('hidden')
    $('#commandHiddenText').addClass("hidden").hide()
    $('#commandShownText').hide().removeClass("hidden").fadeIn()

  data = { type: EVENT_TYPES.peek }
  logEvent(data)



###
  Navigation amongst the questions
###


current_question = 0
next = (which) ->
  # before increment clear style from previous question progress indicator
  $('#marker-' + current_question).addClass("complete").removeClass("active")

  if not which and which != 0
    current_question++
  else
    current_question = which

  questions[current_question]()
  results.clear()
  @webterm.focus()

  if not $('#commandShownText').hasClass('hidden')
    $('#commandShownText').addClass("hidden")
    $('#commandHiddenText').removeClass("hidden").show()

  # enable history navigation
  history.pushState({}, "", "#" + current_question);
  data = { 'type': EVENT_TYPES.next }
  logEvent(data)

  # change the progress indicator
  $('#marker-' + current_question).removeClass("complete").addClass("active")

  $('#question-number').find('text').get(0).textContent = current_question

  # show in the case they were hidden by the complete step.
  $('#instructions .assignment').show()
  $('#tips, #command').show()


  return

previous = () ->
  current_question--
  questions[current_question]()
  results.clear()
  @webterm.focus()
  return



results = {
  set: (htmlText, intermediate) ->
    if intermediate
      console.debug "intermediate text received"
      $('#results').addClass('intermediate')
      $('#buttonNext').hide()
    else
      $('#buttonNext').show()

    window.setTimeout ( () ->
      $('#resulttext').html(htmlText)
      $('#results').fadeIn()
      $('#buttonNext').removeAttr('disabled')
    ), 300

  clear: ->
    $('#resulttext').html("")
    $('#results').fadeOut('slow')
#    $('#buttonNext').addAttr('disabled')
}



###
  Transform question objects into functions
###

buildfunction = (q) ->
  _q = q
  return ->
    console.debug("function called")

    $('#instructions').hide().fadeIn()
    $('#instructions .text').html(_q.html)
    $('#instructions .assignment').html(_q.assignment)
    $('#tipShownText').html(_q.tip)
    if _q.command_show
      $('#commandShownText').html(_q.command_show.join(' '))
    else
      $('#commandShownText').html(_q.command_expected.join(' '))

    if _q.currentDockerPs?
      window.currentDockerPs = _q.currentDockerPs
    else
      window.currentDockerPs = staticDockerPs

    if _q.finishedCallback?
      window.finishedCallback = q.finishedCallback
    else
      window.finishedCallback = () -> return ""

    window.immediateCallback = (input, stop) ->
      if stop == true # prevent the next event from happening
        doNotExecute = true
      else
        doNotExecute = false

      if doNotExecute != true
        console.log (input)

        data = { 'type': EVENT_TYPES.command, 'command': input.join(' '), 'result': 'fail' }

        # Was like this:  if not input.switches.containsAllOfThese(_q.arguments)
        if input.containsAllOfTheseParts(_q.command_expected)
          data.result = 'success'

          setTimeout( ( ->
            @webterm.disable()
            $('#buttonNext').focus()
          ), 1000)

          results.set(_q.result)
          console.debug "contains match"
        else
          console.debug("wrong command received")

        # call function to submit data
        logEvent(data)
      return

    window.intermediateResults = (input) ->
      if _q.intermediateresults
        results.set(_q.intermediateresults[input](), intermediate=true)
    return


statusMarker = $('#progress-marker-0')
progressIndicator = $('#progress-indicator')#

drawStatusMarker = (i) ->
  if i == 0
    marker = statusMarker
  else
    marker = statusMarker.clone()
    marker.appendTo(progressIndicator)

  marker.attr("id", "marker-" + i)
  marker.find('text').get(0).textContent = i
  marker.click( -> next(i) )


questionNumber = 0
for question in q
  f = buildfunction(question)
  questions.push(f)
  drawStatusMarker(questionNumber)
  questionNumber++


###
  Initialization of program
###

#load the first question, or if the url hash is set, use that
if (window.location.hash)
  try
    currentquestion = window.location.hash.split('#')[1].toNumber()
#    questions[currentquestion]()
#    current_question = currentquestion
    next(currentquestion)

  catch err
    questions[0]()
else
  questions[0]()

$('#results').hide()

