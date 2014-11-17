// Generated by CoffeeScript 1.6.3
/*
  This is the main script file. It can attach to the terminal
*/


(function() {
  var COMPLETE_URL, EVENT_TYPES, buildfunction, current_question, currentquestion, drawStatusMarker, err, f, logEvent, next, previous, progressIndicator, q, question, questionNumber, questions, results, staticDockerPs, statusMarker, _i, _len;

  COMPLETE_URL = "/whats-next/";

  /*
    Array of question objects
  */


  staticDockerPs = "ID                  IMAGE               COMMAND               CREATED             STATUS              PORTS";

  q = [];

  q.push({
    html: "<h3>Getting started Krane Users</h3>\n<p>There are actually two programs: The Krane daemon, which is a server process and which manages all the\nthe ships which have docker server installed on them, and the Krane client, which acts as a remote control on the daemon. On most systems, like in this\nemulator, both execute on the same host.</p>",
    assignment: "<h3>Assignment</h3>\n<p>Check which Krane versions are running</p>\n<p>This will help you verify the daemon is running and you can connect to it. If you see which version is running\nyou know you are all set.</p>",
    tip: "<p>Try typing <code>krane</code> to see the full list of accepted arguments</p>      <p>This emulator provides only a limited set of shell and Krane commands, so some commands may not work as expected</p>",
    command_expected: ['krane', 'version'],
    result: "<p>Well done! Let's move to the next assignment.</p>"
  });

  q.push({
    html: "<h3>Listing Available Clouds</h3>\n<p>The easiest way to get started is to use krane is by beeing able to see the availabe cloud providers \nyour Krane server can comission ships.",
    assignment: "<h3>Assignment</h3>\n<p>Use the commandline to discover for a cloud provider server plan called tutorial-europe-2gb</p>",
    command_expected: ['krane', 'plans', 'tutorial-europe-2gb'],
    result: "<p>You found it!</p>",
    tip: "the format is <code>krane plans &lt;string&gt;</code>"
  });

  q.push({
    html: "<h3>Create a Docker ship</h3>\n<p>Now that we have found a our server plan. Lets use krane to commission a ship with the followind data:</p>\n<ul>\n  <li>Full Qualify Domain Name: <b>ship01.example.com</b></li>\n  <li>Name: <b>ship01</b></li>\n  <li>Server Plan Id: <b>53f0f0ecd8a5975a1c0001bd</b></li>\n</ul>\n<p>As you can see the server plan id is the same one we have found with our previous search.</p>",
    assignment: "<h3>Assignment</h3>\n<p>Please comission a ship with the followin data</p>",
    command_expected: ["krane", "commission", "-f", "\"ship01.example.com\"", "-n", "\"ship01\"", "-p", "\"53f0f0ecd8a5975a1c0001bd\""],
    result: "<p>Cool. You have just created your first ship in our test cloud provider. You seen that an id has been retouned stating that the ships has been correctly created.</p>",
    tip: "<p>Look into <code>krane commision</code> to see which parameters you need to create the ship</p>"
  });

  q.push({
    html: "<h3>Starting a Docker container within a Krane ship</h3>\n<p>You can start a Docker container within a Krane ship in much the same way as you would start a container within Docker normally, but you need to add an extra parameter of <code>--ship SHIPNAME<code>.</p>",
    assignment: "<h3>Assignment</h3>\n<p>In this case, you should start an Ubuntu container with <code>--detach=true --tty=false ubuntu /bin/bash</code></p>\n<p>Just as in Docker, the <code>--detach=true --tty=false</code> flag will make the container run in the background.</p>",
    command_expected: ["krane", "run", "--ship=ship01.example.com", "--detach=true", "--tty=false", "ubuntu", "/bin/bash"],
    result: "<p>Great! you have started your first multicloud container</p>",
    tip: "<p>The command <code>krane run</code> must be provided with a <code>--ship SHIPNAME</code> argument; use the ID of the previous ship you created in the last step.</p>\nwithin that image.</p>\n<p>Check the expected command below if it does not work as expected</p>"
  });

  q.push({
    html: "<h3>List all your Krane ships</h3>\n<p>Next we are going to list all your Krane ships, and the containers that are running within them.</p>",
    assignment: "<h3>Assignment</h3>\n<p>List your Krane ships - you get to guess how.</p>",
    command_expected: ["krane", "ships"],
    result: "<p>That worked! You have listed all your krane ships</p>",
    tip: "<p>The second word in the command is <code>ships</code></p>"
  });

  q.push({
    html: "<h3>List all your containers</h3>\n<p>Next we are going to list all your containers deployed in ships.</p>",
    assignment: "<h3>Assignment</h3>\n<p>List your containers deployed in ships.</p>",
    command_expected: ["krane", "ps"],
    result: "<p>That worked! You have listed all your containers</p>",
    tip: "<p>In docker is done with <code>ps</code> maybe in krane is done the same</p>"
  });

  q.push({
    html: "<h3>Stopping a Docker container within a Krane ship</h3>\n<p>The next step is to stop a Docker container that's running within the Krane ship. Krane already knows what ship each Docker container is using so you don't need to specify a ship here.</p>",
    assignment: "<h3>Assignment</h3>\n<p>Stop the container that you started a couple of steps before.</p>",
    command_expected: ["krane", "stop", "af3b2bb5e1"],
    result: "<p>That worked! Please take note that Krane has returned the ID of the container it has stopped</p>",
    tip: "<p>Krane commands are just like Docker commands</p>"
  });

  q.push({
    html: "<h3>Decommissioning a ship</h3>\n<p>Now it's time to tidy things up and decommission the ship you commissioned earlier.</p>",
    assignment: "<h3>Assignment</h3>\n<p> Use the Krane command line to decommission the ship <code>ship01.example.com</code></p>",
    command_expected: ["krane", "decomission", 'ff2b1f65cb'],
    result: "<p>That worked! You have all the basic knowledge to use krane</p>",
    tip: "<ul>\n<li>Make sure you specify the ship id <code>ff2b1f65cb</code></li>\n</ul>",
    finishedCallback: function() {
      webterm.clear();
      return webterm.echo(myTerminal());
    }
  });

  questions = [];

  /*
    Register the terminal
  */


  this.webterm = $('#terminal').terminal(interpreter, basesettings);

  EVENT_TYPES = {
    none: "none",
    start: "start",
    command: "command",
    next: "next",
    peek: "peek",
    feedback: "feedback",
    complete: "complete"
  };

  /*
    Sending events to the server
  */


  logEvent = function(data, feedback) {};

  /*
    Event handlers
  */


  $('#buttonNext').click(function(e) {
    this.setAttribute('disabled', 'disabled');
    console.log(e);
    return next();
  });

  $('#buttonFinish').click(function() {
    return window.open(COMPLETE_URL);
  });

  $('#buttonPrevious').click(function() {
    previous();
    return $('#results').hide();
  });

  $('#leftside').bind('mousewheel', function(event, delta, deltaX, deltaY) {
    this.scrollTop += deltaY * -30;
    return event.preventDefault();
  });

  $('#feedbackSubmit').click(function() {
    var data, feedback;
    feedback = $('#feedbackInput').val();
    data = {
      type: EVENT_TYPES.feedback,
      feedback: feedback
    };
    return logEvent(data, feedback = true);
  });

  $('#fullSizeOpen').click(function() {
    return goFullScreen();
  });

  this.goFullScreen = function() {
    console.debug("going to fullsize mode");
    $('.togglesize').removeClass('startsize').addClass('fullsize');
    $('.hide-when-small').css({
      display: 'inherit'
    });
    $('.hide-when-full').css({
      display: 'none'
    });
    next(0);
    webterm.resize();
    return setTimeout(function() {
      return logEvent({
        type: EVENT_TYPES.start
      });
    }, 3000);
  };

  $('#fullSizeClose').click(function() {
    return leaveFullSizeMode();
  });

  this.leaveFullSizeMode = function() {
    console.debug("leaving full-size mode");
    $('.togglesize').removeClass('fullsize').addClass('startsize');
    $('.hide-when-small').css({
      display: 'none'
    });
    $('.hide-when-full').css({
      display: 'inherit'
    });
    return webterm.resize();
  };

  $('#command').click(function() {
    var data;
    if (!$('#commandHiddenText').hasClass('hidden')) {
      $('#commandHiddenText').addClass("hidden").hide();
      $('#commandShownText').hide().removeClass("hidden").fadeIn();
    }
    data = {
      type: EVENT_TYPES.peek
    };
    return logEvent(data);
  });

  /*
    Navigation amongst the questions
  */


  current_question = 0;

  next = function(which) {
    var data;
    $('#marker-' + current_question).addClass("complete").removeClass("active");
    if (!which && which !== 0) {
      current_question++;
    } else {
      current_question = which;
    }
    questions[current_question]();
    results.clear();
    this.webterm.focus();
    if (!$('#commandShownText').hasClass('hidden')) {
      $('#commandShownText').addClass("hidden");
      $('#commandHiddenText').removeClass("hidden").show();
    }
    history.pushState({}, "", "#" + current_question);
    data = {
      'type': EVENT_TYPES.next
    };
    logEvent(data);
    $('#marker-' + current_question).removeClass("complete").addClass("active");
    $('#question-number').find('text').get(0).textContent = current_question;
    $('#instructions .assignment').show();
    $('#tips, #command').show();
  };

  previous = function() {
    current_question--;
    questions[current_question]();
    results.clear();
    this.webterm.focus();
  };

  results = {
    set: function(htmlText, intermediate) {
      if (intermediate) {
        console.debug("intermediate text received");
        $('#results').addClass('intermediate');
        $('#buttonNext').hide();
      } else {
        $('#buttonNext').show();
      }
      return window.setTimeout((function() {
        $('#resulttext').html(htmlText);
        $('#results').fadeIn();
        return $('#buttonNext').removeAttr('disabled');
      }), 300);
    },
    clear: function() {
      $('#resulttext').html("");
      return $('#results').fadeOut('slow');
    }
  };

  /*
    Transform question objects into functions
  */


  buildfunction = function(q) {
    var _q;
    _q = q;
    return function() {
      console.debug("function called");
      $('#instructions').hide().fadeIn();
      $('#instructions .text').html(_q.html);
      $('#instructions .assignment').html(_q.assignment);
      $('#tipShownText').html(_q.tip);
      if (_q.command_show) {
        $('#commandShownText').html(_q.command_show.join(' '));
      } else {
        $('#commandShownText').html(_q.command_expected.join(' '));
      }
      if (_q.currentDockerPs != null) {
        window.currentDockerPs = _q.currentDockerPs;
      } else {
        window.currentDockerPs = staticDockerPs;
      }
      if (_q.finishedCallback != null) {
        window.finishedCallback = q.finishedCallback;
      } else {
        window.finishedCallback = function() {
          return "";
        };
      }
      window.immediateCallback = function(input, stop) {
        var data, doNotExecute;
        if (stop === true) {
          doNotExecute = true;
        } else {
          doNotExecute = false;
        }
        if (doNotExecute !== true) {
          console.log(input);
          data = {
            'type': EVENT_TYPES.command,
            'command': input.join(' '),
            'result': 'fail'
          };
          if (input.containsAllOfTheseParts(_q.command_expected)) {
            data.result = 'success';
            setTimeout((function() {
              this.webterm.disable();
              return $('#buttonNext').focus();
            }), 1000);
            results.set(_q.result);
            console.debug("contains match");
          } else {
            console.debug("wrong command received");
          }
          logEvent(data);
        }
      };
      window.intermediateResults = function(input) {
        var intermediate;
        if (_q.intermediateresults) {
          return results.set(_q.intermediateresults[input](), intermediate = true);
        }
      };
    };
  };

  statusMarker = $('#progress-marker-0');

  progressIndicator = $('#progress-indicator');

  drawStatusMarker = function(i) {
    var marker;
    if (i === 0) {
      marker = statusMarker;
    } else {
      marker = statusMarker.clone();
      marker.appendTo(progressIndicator);
    }
    marker.attr("id", "marker-" + i);
    marker.find('text').get(0).textContent = i;
    return marker.click(function() {
      return next(i);
    });
  };

  questionNumber = 0;

  for (_i = 0, _len = q.length; _i < _len; _i++) {
    question = q[_i];
    f = buildfunction(question);
    questions.push(f);
    drawStatusMarker(questionNumber);
    questionNumber++;
  }

  /*
    Initialization of program
  */


  if (window.location.hash) {
    try {
      currentquestion = window.location.hash.split('#')[1].toNumber();
      next(currentquestion);
    } catch (_error) {
      err = _error;
      questions[0]();
    }
  } else {
    questions[0]();
  }

  $('#results').hide();

}).call(this);
