###
  Please note the javascript is being fully generated from coffeescript.
  So make your changes in the .coffee file.
  Thatcher Peskens
         _
      ,_(')<
      \___)

###

do @myTerminal = ->

  # Which terminal emulator version are we
  EMULATOR_VERSION = "1.14"

  ships = []
  containers = []

  @basesettings = {
    prompt: 'you@tutorial:~$ ',
    greetings: """
               Welcome to the interactive Krane tutorial
              """

  }

  ###
    Callback definitions. These can be overridden by functions anywhere else
  ###

  @preventDefaultCallback = false

  @immediateCallback = (command) ->
    console.debug("immediate callback from #{command}")
    return

  @finishedCallback = (command) ->
    console.debug("finished callback from #{command}")
    return

  @intermediateResults = (string) ->
    console.debug("sent #{string}")
    return

  @currentDockerPs = ""

  ###
    Base interpreter
  ###

  @interpreter = (input, term) ->
    inputs = input.split(" ")
    command = inputs[0]

    if command is 'hi'
      term.echo 'hi there! What is your name??'
      term.push (command, term) ->
        term.echo command + ' is a pretty name'

    else if command is 'shell'
      term.push (command, term) ->
        if command is 'cd'
          bash(term, inputs)
      , {prompt: '> $ '}

    else if command is 'r'
      location.reload('forceGet')

    else if command is '#'
      term.echo 'which question?'

    else if command is 'test'
      term.echo 'I have to keep testing myself.'

    else if command is 'cd'
      bash(term, inputs)

    else if command is "krane"
      Docker(term, inputs)

    else if command is "help"
      term.echo help

    else if command is "ls"
      term.echo "This is an emulator, not a shell. Try following the instructions."

    else if command is "colors"
      for DockerCommand, description of DockerCommands
        term.echo ("[[b;#fff;]" + DockerCommand + "] - " + description + "")

    else if command is "pull"
      term.echo '[[b;#fff;]some text]'
      wait(term, 5000, true)
      alert term.get_output()

      return

    ## finally
    else if command
      term.echo "#{inputs[0]}: command not found"

    immediateCallback(inputs)

  ###  =======================================
    Common utils
  =======================================  ###

  String.prototype.beginsWith = (string) ->
    ###
    Check if 'this' string starts with the inputstring.
    ###
    return(this.indexOf(string) is 0)

  Array.prototype.containsAllOfThese = (inputArr) ->
    ###
    This function compares all of the elements in the inputArr
    and checks them one by one if they exist in 'this'. When it
    finds an element to not exist, it returns false.
    ###
    me = this
    valid = false

    if inputArr
      valid = inputArr.every( (value) ->
        if me.indexOf(value) == -1
          return false
        else
          return true
      )
    return valid


  Array.prototype.containsAllOfTheseParts = (inputArr) ->
    ###
    This function is like containsAllofThese, but also matches partial strings.
    ###

    me = this
    if inputArr
      valid = inputArr.every( (value) ->
        for item in me
          if item.match(value)
            return true

        return false
      )
    return valid


  parseInput = (inputs) ->
    command = inputs[1]
    switches = []
    switchArg = false
    switchArgs = []
    imagename = ""
    commands = []
    j = 0

    # parse args
    for input in inputs
      if input.startsWith('-') and imagename == ""
        switches.push(input)
        if switches.length > 0
          if not ['-i', '-t', '-d'].containsAllOfThese([input])
            switchArg = true
      else if switchArg == true
        # reset switchArg
        switchArg = false
        switchArgs.push(input)
      else if j > 1 and imagename == ""
        # match wrong names
        imagename = input
      else if imagename != ""
        commands.push (input)
      else
        # nothing?
      j++

    parsed_input = {
      'switches': switches.sortBy(),
      'switchArgs': switchArgs,
      'imageName': imagename,
      'commands': commands,
    }
    return parsed_input


  util_slow_lines = (term, paragraph, keyword, finishedCallback) ->

    if keyword
      lines = paragraph(keyword).split("\n")
    else
      lines = paragraph.split("\n")

    term.pause()
    i = 0
    # function calls itself after timeout is done, untill
    # all lines are finished
    foo = (lines) ->
      self.setTimeout ( ->
        if lines[i]
          term.echo (lines[i])
          i++
          foo(lines)
        else
          term.resume()
          finishedCallback()
      ), 1000

    foo(lines)


  wait = (term, time, dots) ->
    term.echo "starting to wait"
    interval_id = self.setInterval ( -> dots ? term.insert '.'), 500

    self.setTimeout ( ->
      self.clearInterval(interval_id)
      output = term.get_command()
      term.echo output
      term.echo "done "
    ), time

  ###
    Bash program
  ###

  bash = (term, inputs) ->
    echo = term.echo
    insert = term.insert

    if not inputs[1]
      console.log("none")

    else
      argument = inputs[1]
      if argument.beginsWith('..')
        echo "-bash: cd: #{argument}: Permission denied"
      else
        echo "-bash: cd: #{argument}: No such file or directory"

  ###
    Docker program
  ###

  Docker = (term, inputs) ->

    echo = term.echo
    insert = term.insert
    callback = () -> @finishedCallback(inputs)
    command = inputs[1]

    # no command
    if not inputs[1]
      console.debug "no args"
      echo Docker_cmd
      for DockerCommand, description of DockerCommands
        echo "[[b;#fff;]" + DockerCommand + "]" + description + ""

    # Command commit
    else if inputs[1] is "commit"
      if inputs.containsAllOfTheseParts(['docker', 'commit', '698', 'learn/ping'])
        util_slow_lines(term, commit_containerid, "", callback )
      else if inputs.containsAllOfTheseParts(['docker', 'commit', '698'])
        util_slow_lines(term, commit_containerid, "", callback )
        intermediateResults(0)
      else if inputs.containsAllOfTheseParts(['docker', 'commit']) and inputs[2]
        echo commit_id_does_not_exist(inputs[2])
      else
        echo commit

    else if inputs[1] is "do"
      term.push('do', {prompt: "do $ "})

    else if inputs[1] is "logo"
      echo Docker_logo

    else if inputs[1] is "images"
      echo images

    else if inputs[1] is "inspect"
      if inputs[2] and inputs[2].match('ef')
        echo inspect_ping_container
      else if inputs[2]
        echo inspect_no_such_container(inputs[2])
      else
        echo inspect

    # command ps
    else if command is "ps"
      echo list_containers
      # if inputs.containsAllOfThese(['-l'])
      #   echo ps_l
      # else if inputs.containsAllOfThese(['-a'])
      #   echo ps_a
      # else
      #   echo currentDockerPs
    else if inputs[1] is "push"
      if inputs[2] is "learn/ping"
        util_slow_lines(term, push_container_learn_ping, "", callback )
        intermediateResults(0)
        return
      else if inputs[2]
        echo push_wrong_name
      else
        echo push


    else if inputs[1] is "stop"
      if inputs[2]
        util_slow_lines(term, stop_container(inputs[2]), "", callback )
      else
        echo run_stop
    else if inputs[1] is "decomission"
      if inputs[2]
        util_slow_lines(term, stop_ship(inputs[2]), "", callback )
      else
        echo run_decomission    
    # Command run
    else if inputs[1] is "run"
      # parse all input so we have a json object
      parsed_input = parseInput(inputs)

      if inputs[2] and inputs[3]
        ship = ""
        detach = false
        tty = true

        if inputs[2].indexOf("--ship") >= 0
          ship = inputs[2].split("=")[1]
        else if inputs[3].indexOf("--ship") >= 0
          ship = inputs[3].split("=")[1]
        else if inputs[4].indexOf("--ship") >= 0
          ship = inputs[4].split("=")[1]

        if inputs[2].indexOf("--detach") >= 0
          detach = Boolean(inputs[2].split("=")[1].match(/^true$/i)) 
        else if inputs[3].indexOf("--detach") >= 0
          detach = Boolean(inputs[3].split("=")[1].match(/^true$/i)) 
        else if inputs[4].indexOf("--detach") >= 0
          detach = Boolean(inputs[4].split("=")[1].match(/^true$/i))         

        if inputs[2].indexOf("--tty") >= 0
          tty = Boolean(inputs[2].split("=")[1].match(/^true$/i)) 
        else if inputs[3].indexOf("--tty") >= 0
          tty = Boolean(inputs[3].split("=")[1].match(/^true$/i)) 
        else if inputs[4].indexOf("--tty") >= 0
          tty = Boolean(inputs[4].split("=")[1].match(/^true$/i)) 

        if ship and detach and !tty
          util_slow_lines(term, run_ship(ship,inputs[5],inputs[6]), "", callback )
        else
          echo run_cmd

 
      else
        console.log("run")
        echo run_cmd

    else if inputs[1] is "plans"

      if keyword = inputs[2]
        keyword = keyword.toLowerCase()
        if keyword is "tutorial-usa-1gb" or keyword is "usa" or keyword is "1gb" or keyword is "scarsdale"
          echo search_tutorial_usa_1GB(inputs[2])
        else if keyword is "tutorial-europe-2gb" or keyword is "europe" or keyword is "2gb" or keyword is "seville"
          echo search_tutorial_europe_2GB(inputs[2])
        else if keyword is "tutorial-africa-3GB" or keyword is "africa" or keyword is "3gb" or keyword is "windhoek"
          echo search_tutorial_africa_3GB(inputs[2])
        else if keyword is "tutorial" or keyword is "*"
          echo search_all_results(inputs[2])
        else
          echo search_no_results(inputs[2])
      else echo search

    else if inputs[1] is "ships"
      echo list_ships()

    else if inputs[1] is "commission"
      fqdn_parameter = false
      name_parameter = false
      plan_parameter = false

      if inputs[2] is "-f" or inputs[2] is "--fqdn"
        fqdn_parameter = inputs[3].replace(/"/g, "")  
      else if inputs[4] is "-f" or inputs[4] is "--fqdn"
        fqdn_parameter = inputs[5].replace(/"/g, "")  
      else if inputs[6] is "-f" or inputs[6] is "--fqdn"
        fqdn_parameter = inputs[7].replace(/"/g, "")  


      if inputs[2] is "-n" or inputs[2] is "--name"
        name_parameter = inputs[3].replace(/"/g, "")  
      else if inputs[4] is "-n" or inputs[4] is "--name"
        name_parameter = inputs[5].replace(/"/g, "")  
      else if inputs[6] is "-n" or inputs[6] is "--name"
        name_parameter = inputs[7].replace(/"/g, "")  

      if inputs[2] is "-p" or inputs[2] is "--plan"
        plan_parameter = inputs[3].replace(/"/g, "")  
      else if inputs[4] is "-p" or inputs[4] is "--plan"
        plan_parameter = inputs[5].replace(/"/g, "")  
      else if inputs[6] is "-p" or inputs[6] is "--plan"
        plan_parameter = inputs[7].replace(/"/g, "")  



      if fqdn_parameter and name_parameter and plan_parameter
        if plan_parameter is "53f0f0ecd8a5975a1c000162" or plan_parameter is "53f0f0ecd8a5975a1c0001bd" or plan_parameter is "53f0f0ecd8a5975a1c0001bc"
          pattern = /^(?=.{1,254}$)((?=[a-z0-9-]{1,63}\.)(xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,63}$/i

          if fqdn_parameter.match(pattern)
            result = util_slow_lines(term, commission_ship(fqdn_parameter,name_parameter,plan_parameter), "", callback )
          else
            result = util_slow_lines(term, invalid_fqdn_result(fqdn_parameter), "", callback )
        else
          result = util_slow_lines(term, plan_no_results(fqdn_parameter,plan_parameter), "", callback )
      else
        echo commission

    else if inputs[1] is "version"
#      console.log(version)
      echo docker_version()


    else if DockerCommands[inputs[1]]
      echo "#{inputs[1]} is a valid argument, but not implemented"

    else
      echo Docker_cmd
      for DockerCommand, description of DockerCommands
        echo "[[b;#fff;]" + DockerCommand + "]" + description + ""

    # return empty value because otherwise coffeescript will return last var
    return

  ###
    Some default variables / commands

    All items are sorted by alphabet
  ###

  Docker_cmd = \
    """
      Usage: krane [OPTIONS] COMMAND [arg...]
      -H="127.0.0.1:4243": Host:port to bind/connect to

      A self-sufficient runtime for linux containers.

      Commands:

    """

  DockerCommands =
    "attach": "          Attach to a running container"
    "build": "           Build a container from a Dockerfile"
    "commit": "          Create a new image from a container's changes"
    "diff": "            Inspect changes on a container's filesystem"
    "export": "          Stream the contents of a container as a tar archive"
    "history": "         Show the history of an image"
    "images": "          List images"
    "import": "          Create a new filesystem image from the contents of a tarball"
    "info": "            Display system-wide information"
    "insert": "          Insert a file in an image"
    "inspect": "         Return low-level information on a container"
    "kill": "            Kill a running container"
    "login": "           Register or Login to the Docker registry server"
    "logs": "            Fetch the logs of a container"
    "port": "            Lookup the public-facing port which is NAT-ed to PRIVATE_PORT"
    "ps": "              List containers"
    "pull": "            Pull an image or a repository from the Docker registry server"
    "push": "            Push an image or a repository to the Docker registry server"
    "restart": "         Restart a running container"
    "rm": "              Remove a container"
    "rmi": "             Remove an image"
    "run": "             Run a command in a new container"
    "search": "          Search for an image in the Docker index"
    "start": "           Start a stopped container"
    "stop": "            Stop a running container"
    "tag": "             Tag an image into a repository"
    "version": "         Show the Docker version information"
    "wait": "            Block until a container stops, then print its exit code"
    "plans": "           Displays available cloud plans"
    "ships": "           List the number of ships"
    "commission": "      Commision a ship in cloud provider"
    "decomission": "     Decomission a ship in cloud provider"

  run_switches =
    "-p": ['port']
    "-t": []
    "-i": []
    "-h": ['hostname']

  commit = \
    """
    Usage: Docker commit [OPTIONS] CONTAINER [REPOSITORY [TAG]]

    Create a new image from a container's changes

      -author="": Author (eg. "John Hannibal Smith <hannibal@a-team.com>"
      -m="": Commit message
      -run="": Config automatically applied when the image is run. (ex: {"Cmd": ["cat", "/world"], "PortSpecs": ["22"]}')
    """

  commit_id_does_not_exist = (keyword) ->
    """
    2013/07/08 23:51:21 Error: No such container: #{keyword}
    """

  commit_containerid = \
    """
    effb66b31edb
    """

  help = \
    "
Docker tutorial \n
\n
The Docker tutorial is a Docker emulater intended to help novice users get up to spead with the standard Docker
commands. This terminal contains a limited Docker and a limited shell emulator. Therefore some of the commands
you would expect do not exist.\n
\n
Just follow the steps and questions. If you are stuck, click on the 'expected command' to see what the command
should have been. Leave feedback if you find things confusing.

    "

  images = \
    """
    ubuntu                latest              8dbd9e392a96        4 months ago        131.5 MB (virtual 131.5 MB)
    learn/tutorial        latest              8dbd9e392a96        2 months ago        131.5 MB (virtual 131.5 MB)
    learn/ping            latest              effb66b31edb        10 minutes ago      11.57 MB (virtual 143.1 MB)
    """

  commission = \
    """
    Usage: krane commission [OPTIONS]

    Commision a ship

      -f, --fqdn=""                            Full qualify domain name of Ship
      -n, --name=""                            Name of Ship
      -p, --plan="53f0f10fd8a5975a1c000395"    Cloud Plan to use for the commissioning of the Ship

    """


  run_ship = (fqdn, image, command) ->
    ship_exists = false
    uuid = "af3b2bb5e1"
    if fqdn != "ship01.example.com" and image != "ubuntu" and command != "/bin/bash"
      uuid = "xxxxxxxxxx".replace(/[xy]/g, (c) ->
        r = Math.random() * 16 | 0
        v = (if c is "x" then r else r & 0x3 | 0x8)
        v.toString 16
      ) 
    for ship in ships
      console.log ship
      if ship[2] is fqdn
        ship_exists = true
        containers.push([uuid,fqdn,image,command])

    if ship_exists
      """
      #{uuid}

      """
    else
      """
      2014/11/04 20:05:57 HTTP code: 404 message:  Ship #{fqdn} does not exist create it first
      """



  commission_ship  = (fqdn, name, plan) ->

    ip = "#{Math.round(Math.random()*255)}.#{Math.round(Math.random()*255)}.#{Math.round(Math.random()*255)}.#{Math.round(Math.random()*255)}"
    uuid = "ff2b1f65cb"
    if fqdn != "ship01.example.com"
      uuid = "xxxxxxxxxx".replace(/[xy]/g, (c) ->
        r = Math.random() * 16 | 0
        v = (if c is "x" then r else r & 0x3 | 0x8)
        v.toString 16
      )
    plan_name = ""

    if plan is "53f0f0ecd8a5975a1c000162"
      plan_name = "tutorial-usa-1gb"
    else if plan is "53f0f0ecd8a5975a1c0001bd"
      plan_name = "tutorial-europe-2gb"
    else if plan is "53f0f0ecd8a5975a1c0001bc"
      plan_name = "tutorial-africa-3gb"

    ships.push([uuid,name,fqdn,ip,plan_name])
    """
    #{uuid}
    """

  stop_ship = (uuid) ->
    item = []
    for ship in ships
      if ship[0] is uuid
        item = ship

    ships.splice( ships.indexOf(item), 1 );

    if item.length > 0
      """
      #{uuid}
      """
    else
      """
      2014/11/04 20:05:57 Error: failed to decomission one or more ships
      """


  stop_container = (uuid) ->
    item = []
    for container in containers
      if container[0] is uuid
        item = container

    containers.splice( containers.indexOf(item), 1 );

    if item.length > 0
      """
      #{uuid}
      """
    else
      """
      2014/11/04 20:05:57 Error: failed to stop one or more containers
      """



  list_containers = () ->
    output = "CONTAINER ID   IMAGE      COMMAND       CREATED        STATUS              PORTS   NAMES         SHIP\n"

    for container in containers
      output = output.concat("#{container[0]}     #{container[2]}     #{container[3]}     16 minutes     Up 16 minutes ago           flexiant#{Math.round(Math.random()*10)}     #{container[1]}\n")
    output


  list_ships = () ->
    output = "ID           NAME                FQDN                IP               STATE         OS            PLAN\n"

    for ship in ships
      output = output.concat("#{ship[0]}   #{ship[1]}             #{ship[2]}  #{ship[3]}   operational   Ubuntu 14.04   #{ship[4]}\n")
    output

  inspect = \
    """

    Usage: Docker inspect CONTAINER|IMAGE [CONTAINER|IMAGE...]

    Return low-level information on a container/image

    """

  inspect_no_such_container = (keyword) ->
    """
      Error: No such image: #{keyword}
    """

  inspect_ping_container = \
  """
  [2013/07/30 01:52:26 GET /v1.3/containers/efef/json
  {
    "ID": "efefdc74a1d5900d7d7a74740e5261c09f5f42b6dae58ded6a1fde1cde7f4ac5",
    "Created": "2013-07-30T00:54:12.417119736Z",
    "Path": "ping",
    "Args": [
        "www.google.com"
    ],
    "Config": {
        "Hostname": "efefdc74a1d5",
        "User": "",
        "Memory": 0,
        "MemorySwap": 0,
        "CpuShares": 0,
        "AttachStdin": false,
        "AttachStdout": true,
        "AttachStderr": true,
        "PortSpecs": null,
        "Tty": false,
        "OpenStdin": false,
        "StdinOnce": false,
        "Env": null,
        "Cmd": [
            "ping",
            "www.google.com"
        ],
        "Dns": null,
        "Image": "learn/ping",
        "Volumes": null,
        "VolumesFrom": "",
        "Entrypoint": null
    },
    "State": {
        "Running": true,
        "Pid": 22249,
        "ExitCode": 0,
        "StartedAt": "2013-07-30T00:54:12.424817715Z",
        "Ghost": false
    },
    "Image": "a1dbb48ce764c6651f5af98b46ed052a5f751233d731b645a6c57f91a4cb7158",
    "NetworkSettings": {
        "IPAddress": "172.16.42.6",
        "IPPrefixLen": 24,
        "Gateway": "172.16.42.1",
        "Bridge": "docker0",
        "PortMapping": {
            "Tcp": {},
            "Udp": {}
        }
    },
    "SysInitPath": "/usr/bin/docker",
    "ResolvConfPath": "/etc/resolv.conf",
    "Volumes": {},
    "VolumesRW": {}
  """

  ping = \
    """
    Usage: ping [-LRUbdfnqrvVaAD] [-c count] [-i interval] [-w deadline]
            [-p pattern] [-s packetsize] [-t ttl] [-I interface]
            [-M pmtudisc-hint] [-m mark] [-S sndbuf]
            [-T tstamp-options] [-Q tos] [hop1 ...] destination
    """

  ps = \
    """
    ID                  IMAGE               COMMAND               CREATED             STATUS              PORTS
    efefdc74a1d5        learn/ping:latest   ping www.google.com   37 seconds ago      Up 36 seconds
    """

  ps_a = \
    """
    ID                  IMAGE               COMMAND                CREATED             STATUS              PORTS
    6982a9948422        ubuntu:12.04        apt-get install ping   1 minute ago        Exit 0
    efefdc74a1d5        learn/ping:latest   ping www.google.com   37 seconds ago       Up 36 seconds
    """

  ps_l = \
    """
    ID                  IMAGE               COMMAND                CREATED             STATUS              PORTS
    6982a9948422        ubuntu:12.04        apt-get install ping   1 minute ago        Exit 0
    """

  pull = \
    """
    Usage: Krane comission [OPTIONS]

    Commision a ship in a specific server provider

    -f, --fqdn=""                            Full qualify domain name of Ship
    -n, --name=""                            Name of Ship
    -p, --plan="53f0f10fd8a5975a1c000395"    Cloud Plan to use for the commissioning of the Ship
    """

  pull_no_results = (keyword) ->
    """
    Pulling repository #{keyword}
    2013/06/19 19:27:03 HTTP code: 404
    """

  invalid_fqdn_result = (name) ->
    """
    2013/06/19 19:27:03 HTTP code: 404 message:  Invalid FQDN #{name} for ship creation
    """

  plan_no_results = (name, plan) ->
    """
    2013/06/19 19:27:03 HTTP code: 404 message:  Commissioning Ship #{name} can not be done as #{plan} does not exist
    """

  pull_ubuntu =
    """
    Pulling repository ubuntu from https://index.docker.io/v1
    Pulling image 8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c (precise) from ubuntu
    Pulling image b750fe79269d2ec9a3c593ef05b4332b1d1a02a62b4accb2c21d589ff2f5f2dc (12.10) from ubuntu
    Pulling image 27cf784147099545 () from ubuntu
    """

  pull_tutorial = \
    """
    Pulling repository learn/tutorial from https://index.docker.io/v1
    Pulling image 8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c (precise) from ubuntu
    Pulling image b750fe79269d2ec9a3c593ef05b4332b1d1a02a62b4accb2c21d589ff2f5f2dc (12.10) from ubuntu
    Pulling image 27cf784147099545 () from tutorial
    """

  push = \
    """

    Usage: docker push NAME

    Push an image or a repository to the registry
    """


  push_container_learn_ping = \
    """
    The push refers to a repository [learn/ping] (len: 1)
    Processing checksums
    Sending image list
    Pushing repository learn/ping (1 tags)
    Pushing 8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c
    Image 8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c already pushed, skipping
    Pushing tags for rev [8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c] on {https://registry-1.docker.io/v1/repositories/learn/ping/tags/latest}
    Pushing a1dbb48ce764c6651f5af98b46ed052a5f751233d731b645a6c57f91a4cb7158
    Pushing  11.5 MB/11.5 MB (100%)
    Pushing tags for rev [a1dbb48ce764c6651f5af98b46ed052a5f751233d731b645a6c57f91a4cb7158] on {https://registry-1.docker.io/v1/repositories/learn/ping/tags/latest}
    """

  push_wrong_name = \
  """
  The push refers to a repository [dhrp/fail] (len: 0)
  """

  run_decomission= \
    """

    Usage: krane stop [OPTIONS] SHIP [SHIP...]

    Decommision a ship

      -t, --time=10      Number of seconds to wait for the container to stop before killing it. Default is 10 seconds.

    """

  run_stop = \
    """

    Usage: krane stop [OPTIONS] CONTAINER [CONTAINER...]

    Stop a running container by sending SIGTERM and then SIGKILL after a grace period

      -t, --time=10      Number of seconds to wait for the container to stop before killing it. Default is 10 seconds.

    """

  run_cmd = \
    """
    Usage: krane run [OPTIONS] IMAGE [COMMAND] [ARG...]

    Run a command in a new container

      -a, --attach=[]            Attach to STDIN, STDOUT or STDERR.
      --add-host=[]              Add a custom host-to-IP mapping (host:ip)
      -c, --cpu-shares=0         CPU shares (relative weight)
      --cap-add=[]               Add Linux capabilities
      --cap-drop=[]              Drop Linux capabilities
      --cidfile=""               Write the container ID to the file
      --cpuset=""                CPUs in which to allow execution (0-3, 0,1)
      -d, --detach=false         Detached mode: run the container in the background and print the new container ID
      --device=[]                Add a host device to the container (e.g. --device=/dev/sdc:/dev/xvdc:rwm)
      --dns=[]                   Set custom DNS servers
      --dns-search=[]            Set custom DNS search domains
      -e, --env=[]               Set environment variables
      --entrypoint=""            Overwrite the default ENTRYPOINT of the image
      --env-file=[]              Read in a line delimited file of environment variables
      --expose=[]                Expose a port from the container without publishing it to your host
      -h, --hostname=""          Container host name
      -i, --interactive=false    Keep STDIN open even if not attached
      --link=[]                  Add link to another container in the form of name:alias
      --lxc-conf=[]              (lxc exec-driver only) Add custom lxc options --lxc-conf="lxc.cgroup.cpuset.cpus = 0,1"
      -m, --memory=""            Memory limit (format: <number><optional unit>, where unit = b, k, m or g)
      --name=""                  Assign a name to the container
      --net="bridge"             Set the Network mode for the container
                                   'bridge': creates a new network stack for the container on the docker bridge
                                   'none': no networking for this container
                                   'container:<name|id>': reuses another container network stack
                                   'host': use the host network stack inside the container.  Note: the host mode gives the container full access to local system services such as D-bus and is therefore considered insecure.
      -P, --publish-all=false    Publish all exposed ports to the host interfaces
      -p, --publish=[]           Publish a container's port to the host
                                   format: ip:hostPort:containerPort | ip::containerPort | hostPort:containerPort | containerPort
                                   (use 'docker port' to see the actual mapping)
      --privileged=false         Give extended privileges to this container
      --restart=""               Restart policy to apply when a container exits (no, on-failure[:max-retry], always)
      --rm=false                 Automatically remove the container when it exits (incompatible with -d)
      --security-opt=[]          Security Options
      --sig-proxy=true           Proxy received signals to the process (even in non-TTY mode). SIGCHLD, SIGSTOP, and SIGKILL are not proxied.
      -t, --tty=false            Allocate a pseudo-TTY
      -u, --user=""              Username or UID
      -v, --volume=[]            Bind mount a volume (e.g., from the host: -v /host:/container, from Docker: -v /container)
      --volumes-from=[]          Mount volumes from the specified container(s)
      -s, --ship=""              Ship name 
    """

  run_apt_get = \
    """
    apt 0.8.16~exp12ubuntu10 for amd64 compiled on Apr 20 2012 10:19:39
    Usage: apt-get [options] command
           apt-get [options] install|remove pkg1 [pkg2 ...]
           apt-get [options] source pkg1 [pkg2 ...]

    apt-get is a simple command line interface for downloading and
    installing packages. The most frequently used commands are update
    and install.

    Commands:
       update - Retrieve new lists of packages
       upgrade - Perform an upgrade
       install - Install new packages (pkg is libc6 not libc6.deb)
       remove - Remove packages
       autoremove - Remove automatically all unused packages
       purge - Remove packages and config files
       source - Download source archives
       build-dep - Configure build-dependencies for source packages
       dist-upgrade - Distribution upgrade, see apt-get(8)
       dselect-upgrade - Follow dselect selections
       clean - Erase downloaded archive files
       autoclean - Erase old downloaded archive files
       check - Verify that there are no broken dependencies
       changelog - Download and display the changelog for the given package
       download - Download the binary package into the current directory

    Options:
      -h  This help text.
      -q  Loggable output - no progress indicator
      -qq No output except for errors
      -d  Download only - do NOT install or unpack archives
      -s  No-act. Perform ordering simulation
      -y  Assume Yes to all queries and do not prompt
      -f  Attempt to correct a system with broken dependencies in place
      -m  Attempt to continue if archives are unlocatable
      -u  Show a list of upgraded packages as well
      -b  Build the source package after fetching it
      -V  Show verbose version numbers
      -c=? Read this configuration file
      -o=? Set an arbitrary configuration option, eg -o dir::cache=/tmp
    See the apt-get(8), sources.list(5) and apt.conf(5) manual
    pages for more information and options.
                           This APT has Super Cow Powers.

    """

  run_apt_get_install_iputils_ping = \
    """
      Reading package lists...
      Building dependency tree...
      The following NEW packages will be installed:
        iputils-ping
      0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
      Need to get 56.1 kB of archives.
      After this operation, 143 kB of additional disk space will be used.
      Get:1 http://archive.ubuntu.com/ubuntu/ precise/main iputils-ping amd64 3:20101006-1ubuntu1 [56.1 kB]
      debconf: delaying package configuration, since apt-utils is not installed
      Fetched 56.1 kB in 1s (50.3 kB/s)
      Selecting previously unselected package iputils-ping.
      (Reading database ... 7545 files and directories currently installed.)
      Unpacking iputils-ping (from .../iputils-ping_3%3a20101006-1ubuntu1_amd64.deb) ...
      Setting up iputils-ping (3:20101006-1ubuntu1) ...
    """

  run_apt_get_install_unknown_package = (keyword) ->
    """
      Reading package lists...
      Building dependency tree...
      E: Unable to locate package #{keyword}
    """

  run_flag_defined_not_defined = (keyword) ->
    """
    2013/08/15 22:19:14 flag provided but not defined: #{keyword}
    """

  run_learn_no_command = \
    """
    2013/07/02 02:00:59 Error: No command specified
    """

  run_learn_tutorial_echo_hello_world = (commands) ->
    string = ""
    for command in commands[1..]
      command = command.replace('"','');
      string += ("#{command} ")
    return string


  run_image_wrong_command = (keyword) ->
    """
    2013/07/08 23:13:30 Unable to locate #{keyword}
    """

  run_notfound = (keyword) ->
    """
    Pulling repository #{keyword} from https://index.docker.io/v1
    2013/07/02 02:14:47 Error: No such image: #{keyword}
    """

  run_ping_not_google = (keyword) ->
    """
    ping: unknown host #{keyword}
    """

  run_ping_www_google_com = \
    """
    PING www.google.com (74.125.239.129) 56(84) bytes of data.
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=1 ttl=55 time=2.23 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=2 ttl=55 time=2.30 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=3 ttl=55 time=2.27 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=4 ttl=55 time=2.30 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=5 ttl=55 time=2.25 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=6 ttl=55 time=2.29 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=7 ttl=55 time=2.23 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=8 ttl=55 time=2.30 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=9 ttl=55 time=2.35 ms
    -> This would normally just keep going. However, this emulator does not support Ctrl-C, so we quit here.
    """

  search = \
    """

    Usage: krane plans NAME

    Search the for a specific cloud plan of the availiable 

    """


  search_tutorial_usa_1GB = (keyword) ->
    """
    Found 1 results matching your query ("#{keyword}")
    ID                         PROVIDER            CONTINENT           REGION              PLAN
    53f0f0ecd8a5975a1c000162   Tutorial            USA                 Scarsdale           1GB
    """


  search_tutorial_europe_2GB = (keyword) ->
    """
    Found 1 results matching your query ("#{keyword}")
    ID                         PROVIDER            CONTINENT           REGION              PLAN
    53f0f0ecd8a5975a1c0001bd   Tutorial            Europe              Seville             2GB
    """

  search_tutorial_africa_3GB = (keyword) ->
    """
    Found 1 results matching your query ("#{keyword}")
    ID                         PROVIDER            CONTINENT           REGION              PLAN
    53f0f0ecd8a5975a1c0001bd   Tutorial            Africa              Windhoek            3GB
    """

  search_all_results = (keyword) ->
    """
    Found 3 results matching your query ("#{keyword}")
    ID                         PROVIDER            CONTINENT           REGION              PLAN
    53f0f0ecd8a5975a1c000162   Tutorial            USA                 Scarsdale           1GB
    53f0f0ecd8a5975a1c0001bd   Tutorial            Europe              Seville             2GB
    53f0f0ecd8a5975a1c0001bc   Tutorial            Africa              Windhoek            3GB
    """

  search_no_results = (keyword) ->
    """
    Found 0 results matching your query ("#{keyword}")
    ID                         PROVIDER            CONTINENT           REGION              PLAN
    """

  search_tutorial = \
    """
    Found 1 results matching your query ("tutorial")
    NAME                      DESCRIPTION
    learn/tutorial            An image for the interactive tutorial
    """

  search_ubuntu = \
    """
    Found 22 results matching your query ("ubuntu")
    NAME                DESCRIPTION
    shykes/ubuntu
    base                Another general use Ubuntu base image. Tag...
    ubuntu              General use Ubuntu base image. Tags availa...
    boxcar/raring       Ubuntu Raring 13.04 suitable for testing v...
    dhrp/ubuntu
    creack/ubuntu       Tags:
    12.04-ssh,
    12.10-ssh,
    12.10-ssh-l...
    crohr/ubuntu              Ubuntu base images. Only lucid (10.04) for...
    knewton/ubuntu
    pallet/ubuntu2
    erikh/ubuntu
    samalba/wget              Test container inherited from ubuntu with ...
    creack/ubuntu-12-10-ssh
    knewton/ubuntu-12.04
    tithonium/rvm-ubuntu      The base 'ubuntu' image, with rvm installe...
    dekz/build                13.04 ubuntu with build
    ooyala/test-ubuntu
    ooyala/test-my-ubuntu
    ooyala/test-ubuntu2
    ooyala/test-ubuntu3
    ooyala/test-ubuntu4
    ooyala/test-ubuntu5
    surma/go                  Simple augmentation of the standard Ubuntu...

    """

  testing = \
  """
  Testing leads to failure, and failure leads to understanding. ~Burt Rutan
  """

  docker_version = () ->
    """
    Krane Emulator version #{EMULATOR_VERSION}

    Emulating:
    Client API version: 1.14
    Go version (client): go1.2
    Server version: 1.14
    Go version (server): go1.2
    """


  Docker_logo = \
  '''
                _ _       _                    _
  __      _____| | |   __| | ___  _ __   ___  | |
  \\\ \\\ /\\\ / / _ \\\ | |  / _` |/ _ \\\| '_ \\\ / _ \\\ | |
   \\\ V  V /  __/ | | | (_| | (_) | | | |  __/ |_|
    \\\_/\\\_/ \\\___|_|_|  \\\__,_|\\\___/|_| |_|\\\___| (_)
                                                

  
                                                    `-+shh:    
                                               `-+shhhhhh+    
                                            -/shhhhho/+hh+    
                                        ./shhhhhshh.`ohhh+    
                                    ./shhhhhs/-  yh+hhhyh+    
                                ./ohhhhhs/yh`    yhhhy-:h+    
                            .:ohhhhhhhyo++hho+++ohhh+` :h+    
                        .:oyhhhhs+:sh/----yh:-+hhhy.   :h+    
                    `:oyhhhhhh/`   oh.    yh.ohhh/     :h+    
                 .+yhhhhy+:`+h-    oh.    yhhhhs.      :h+    
                 +hhhhhhyyyyhhyyyyyhhyyyyyhhhh:        :h+    
                  ``````````oh:````oh-`.+hhho`         :h+    
  .+oooooooooooooooooooo/`  +h-    oh.-yhhy:           :h+    
  hhhhhhhhhhhhhhy/::::/hho  +h:````ohohhho`            :h+    
  hhhhhhhhhhhhhh:      ohs  +hysssshhhhy-              :h+    
  hhhhhhhhhhhhhh:      ohs  +h-  `ohhh+                :h+    
  hhhhhhhhhhhhhh:      ohs  +h- /hhhs.                 :h+    
  hhhhhhhhhhhhhhs-....:yhs  +h+shhh/                   :h+    
  hhhhhhhhhhhhhhhhhhhhhhs.  +hhhhs.                   `/ho.   
  hhhhhhhhhhhhhhhhhhhhh:   -yhhh:                   :yhysyhy/ 
  hhhhhhhhhhhhhhhhhhho`  `ohhho`                   :hh-   .yh+
  hhhhhhhhhhhhhhhhhy-   :hhhy-                     oho     /hy
  -oyyyyyyyyyyyyyy/     ohh+`                      oho     /hy
                                                   ohs...../hy
                                                   hyyyssyyyyh
                                                   hyyysssyyyh
                                                   hyyysssyyyh
                                                   hyyysssyyyh
                                                   hhyyyyyyyyh
                                                            

  '''


return this


