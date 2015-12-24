Template.body.events
  'click .weapon-item': (e, t) ->
    e.stopImmediatePropagation()

    if $(e.currentTarget).hasClass 'selected'
      $(e.currentTarget).removeClass 'selected'
      t.selectedWeapon.set(null)
      return

    weaponType = $(e.currentTarget).data('weapon-type')
    if weaponType == 'blaster'
      weaponItem =
        type: weaponType
        size: 20
        forceСoefficient: 0.01,
        countDown: 0,
        mark: '/packages/jss_star-wars/assets/img/blast-mark.png'
    else if weaponType == 'cannon'
      weaponItem =
        type: weaponType
        size: 60
        forceСoefficient: 0.4
        countDown: 0
        mark: '/packages/jss_star-wars/assets/img/blast-mark.png'
    else if weaponType == 'death-star'
      weaponItem =
        type: weaponType
        size: 200
        forceСoefficient: 1
        countDown: 38
        mark: '/packages/jss_star-wars/assets/img/DeathStar.png'
    else
      weaponItem = null

    t.selectedWeapon.set(weaponItem)
    t.$('.weapon-item').removeClass 'selected'
    $(e.currentTarget).addClass 'selected'
    new Explosion

Template.body.helpers
  selectedWeapon: ->
    Template.instance().selectedWeapon.get()

Template.body.onCreated ->
  @selectedWeapon = new ReactiveVar(null)

Template.body.onRendered ->
  self = this

  i = 0
  $(document).on('click', =>
    if @selectedWeapon.get()
      if @selectedWeapon.get().type == 'death-star'
        @$('audio.sw-' + @selectedWeapon.get().type)[0].play()
      else
        @$('audio.sw-' + @selectedWeapon.get().type)[i].play()
        i && i-- || i++
  )

  $(document).on('click', 'a:not(.disabled)', =>
    $('.explosion-mark').remove()
  )

  $(document).on('keyup', (e) => 
    if e.keyCode is 27
      @selectedWeapon.set(null)
      @$('.weapon-item').removeClass 'selected'
  )


  @autorun =>
    body = $('body')
    if @selectedWeapon.get()
      body.addClass 'sight-cursor'
      $('a').addClass 'disabled'
    else
      body.removeClass 'sight-cursor'
      $('a').removeClass 'disabled'


  w = window
  for vendor in ['ms', 'moz', 'webkit', 'o']
    break if w.requestAnimationFrame
    w.requestAnimationFrame = w["#vendorRequestAnimationFrame"]
    w.cancelAnimationFrame = (w["#vendorCancelAnimationFrame"] or
      w["#vendorCancelRequestAnimationFrame"])

  targetTime = 0
  w.requestAnimationFrame or= (callback) ->
    targetTime = Math.max targetTime + 16, currentTime = +new Date
    w.setTimeout (-> callback +new Date), targetTime - currentTime

  w.cancelAnimationFrame or= (id) -> clearTimeout id

  w.findClickPos = (e) ->
    posx = 0
    posy = 0
    if (!e) then e = window.event
    if (e.pageX || e.pageY)
      posx = e.pageX
      posy = e.pageY
    else if (e.clientX || e.clientY)
      posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
      posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
    x:posx,y:posy

  w.getOffset = (el) ->
    body = document.getElementsByTagName("body")[0]
    _x = 0
    _y = 0
    while el and !isNaN(el.offsetLeft) and !isNaN(el.offsetTop)
      _x += el.offsetLeft - el.scrollLeft
      _y += el.offsetTop - el.scrollTop
      el = el.offsetParent
    top: _y + body.scrollTop, left: _x + body.scrollLeft

  class Shot
    constructor:(x,y) ->
      @pos =
        x:x
        y:y
      @type = self.selectedWeapon.get().type || 'blaster'
      @size = self.selectedWeapon.get().size || 20
      @body  = document.getElementsByTagName("body")[0]
      @state = 'planted'
      @mark = self.selectedWeapon.get().mark
      @count = self.selectedWeapon.get().countDown || 0
      @drop()

    drop:=>
      @shot = document.createElement("div")
      @shot.innerHTML = @count
      @body.appendChild(@shot)
      @shot.className = "explosion-mark"
      @shot.style['zIndex'] = "9999"
      @shot.style['fontFamily'] = "verdana"
      @shot.style['width'] = "#{@size}px"
      @shot.style['height'] = "#{@size}px"
      @shot.style['display'] = 'block'
      @shot.style['borderRadius'] = "#{@size}px"
      @shot.style['WebkitBorderRadius'] = "#{@size}px"
      @shot.style['MozBorderRadius'] = "#{@size}px"
      @shot.style['fontSize'] = '18px'
      @shot.style['color'] = '#fff'
      @shot.style['lineHeight'] = "#{@size}px"
      @shot.style['background-image'] = "url(#{@mark})"
      @shot.style['background-size'] = 'cover'
      @shot.style['position'] = 'absolute'
      @shot.style['top'] = "#{@pos.y - @size / 2}px"
      @shot.style['left'] = "#{@pos.x - @size / 2}px"
      @shot.style['textAlign'] = "center"
      @shot.style['WebkitUserSelect'] = 'none'
      @shot.style['font-weight'] = 700
      @countDown()

    plantDeathStar:(count) ->
      body = $(@body)
      body.jrumble
        x: 2
        y: 2
        rotation: 1
        opacity: true
        opacityMin: 0.75

      body.trigger 'startRumble'
      demoTimeout = Meteor.setTimeout((->
        body.trigger 'stopRumble'
        Meteor.clearTimeout(demoTimeout);
      ), count * 1000)


    countDown: =>
      @state = 'ticking'
      @count--
      @shot.innerHTML = @count
      if @count == 3 and @type == 'death-star'
        @plantDeathStar(@count)
      if @count > 0 then setTimeout(@countDown,1000) else @explose()

    explose: ->
      @shot.innerHTML = ''
      @state = 'explose'
      if @type == 'death-star'
        $(@body).html('')
        Blaze.render(Template.swAfterExplosion, @body)

    exploded: ->
      @state = 'exploded'
      @shot.innerHTML = ''
      @shot.style['fontSize'] = '12px'
      if @type == 'death-star'
        self.selectedWeapon.set(null)
        $('body').removeClass 'sight-cursor'
        $('a').removeClass 'disabled'

  window.Shot = Shot

  class Particle
    constructor: (elem) ->
      @elem                 = elem
      @style                = elem.style
      @elem.style['zIndex'] = 9999
      @transformX           = 0
      @transformY           = 0
      @transformRotation    = 0
      @offsetTop  = window.getOffset(@elem).top
      @offsetLeft = window.getOffset(@elem).left
      @velocityX  = 0
      @velocityY  = 0

    tick: (blast) ->
      if not self.selectedWeapon.get() then return
      previousStateX = @transformX
      previousStateY = @transformY
      previousRotation = @transformRotation
      if @velocityX > 1.5 then @velocityX -= 1.5 else if @velocityX < -1.5 then @velocityX += 1.5 else @velocityX = 0
      if @velocityY > 1.5 then @velocityY -= 1.5 else if @velocityY < -1.5 then @velocityY += 1.5 else @velocityY = 0
      if blast?
        distX  = @offsetLeft + @transformX - blast.x
        distY  = @offsetTop + @transformY - blast.y
        distXS = distX * distX
        distYS = distY * distY
        distanceWithBlast = distXS + distYS
        force  = 100000 * self.selectedWeapon.get().forceСoefficient/distanceWithBlast
        force  = 50 if force > 50
        rad    = Math.asin distYS/distanceWithBlast
        forceY = Math.sin(rad) * force * if distY < 0 then -1 else 1
        forceX = Math.cos(rad) * force * if distX < 0 then -1 else 1
        @velocityX =+ forceX
        @velocityY =+ forceY
      @transformX = @transformX + @velocityX
      @transformY = @transformY + @velocityY
      @transformRotation = @transformX *- 1

      if (Math.abs(previousStateX - @transformX) > 1 or Math.abs(previousStateY - @transformY) > 1 or Math.abs(previousRotation - @transformRotation) > 1) and ((@transformX > 1 or @transformX < -1) or (@transformY > 1 or @transformY < -1))
        transform = "translate(#{@transformX}px, #{@transformY}px) rotate(#{@transformRotation}deg)"
        @style['MozTransform']    = transform
        @style['OTransform']      = transform
        @style['WebkitTransform'] = transform
        @style['msTransform']     = transform
        @style['transform']       = transform

  window.Particle = Particle

  # setTimeout(->
  class Explosion
    constructor: () ->
      # return if window.SHOOTING_MODE_ACTIVATED
      # window.SHOOTING_MODE_ACTIVATED = true
      @shots = []
      @body          = document.getElementsByTagName("body")[0]
      @body?.onclick = (event)=>
        if self.selectedWeapon.get()
          @shoot(event)
      @body.addEventListener("touchstart", (event)=>
        @touchEvent = event
      )
      @body.addEventListener("touchmove", (event)=>
        @touchMoveCount ||= 0
        @touchMoveCount++
      )
      @body.addEventListener("touchend", (event)=>
        @shoot(@touchEvent) if @touchMoveCount < 2
        @touchMoveCount = 0
      )
      @explosifyNodes  @body.childNodes
      @chars = for char in document.getElementsByTagName('particle')
        new Particle(char,@body)
      @tick()

    explosifyNodes: (nodes) ->
      for node in nodes
        @explosifyNode(node)

    explosifyNode: (node) ->
      for name in ['script','style','iframe','canvas','video','audio','textarea','embed','object','select','area','map','input','word','particle']
        return if node.nodeName.toLowerCase() == name
      switch node.nodeType
        when 1 then @explosifyNodes(node.childNodes)
        when 3
          unless /^\s*$/.test(node.nodeValue)
            if node.parentNode.childNodes.length == 1
              node.parentNode.innerHTML = @explosifyText(node.nodeValue)
            else
              newNode           = document.createElement("particles")
              newNode.innerHTML = @explosifyText(node.nodeValue)
              node.parentNode.replaceChild newNode, node

    explosifyText: (string) ->
      chars = for char, index in string.split ''
        unless /^\s*$/.test(char) then "<particle style='display:inline-block;'>#{char}</particle>" else '&nbsp;'
      chars = chars.join('')
      chars = for char, index in chars.split '&nbsp;'
        unless /^\s*$/.test(char) then "<word style='white-space:nowrap'>#{char}</word>" else char
      chars.join(' ')

    shoot: (event) =>
      pos = window.findClickPos(event)
      @shots.push new Shot(pos.x,pos.y)
      if window.FONTBOMB_PREVENT_DEFAULT
        event.preventDefault()

    tick: =>
      for shot in @shots
        if shot.state == 'explose'
          shot.exploded()
          @blast = shot.pos

      if @blast?
        char.tick(@blast) for char in @chars
        @blast = null
      else
        char.tick() for char in @chars
      requestAnimationFrame @tick

  window.Explosion = Explosion
