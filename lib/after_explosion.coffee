Template.swAfterExplosion.events
  'click .sw-reset': (e, t) ->
    location.reload()

Template.swAfterExplosion.onRendered ->
  SEO.set
    title: 'Destroy this website! @JSSolution'
    meta: 
      description: 'Destroy the web-site with a bunch of weapons from the Star Wars movie.'
    og: 
      title: 'Destroy this website! @JSSolution',
      description: 'Destroy the web-site with a bunch of weapons from the Star Wars movie.'

