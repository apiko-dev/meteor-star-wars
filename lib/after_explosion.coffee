Template.swAfterExplosion.events
  'click .sw-reset': (e, t) ->
    location.reload()

Template.swAfterExplosion.onRendered ->
  SEO.set
    title: 'Destroy this website! @JSSolutions_dev'
    meta: 
      description: 'Destroy the web-site with a bunch of weapons from the Star Wars movie.'
    og: 
      title: 'Destroy this website! @JSSolutions_dev',
      description: 'Destroy the web-site with a bunch of weapons from the Star Wars movie.'

