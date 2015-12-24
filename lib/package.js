Package.describe({
  name: 'jss:star-wars',
  version: '1.0.0',
  summary: 'Destroy the web-site with a bunch of weapons from the Star Wars movie',
  git: 'https://github.com/JSSolutions/meteor-star-wars',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('meteor-platform');
  api.use('coffeescript');

  // Files
  api.addFiles([
    'lib/star_wars.css',
    'lib/star_wars.html',
    'lib/star_wars.coffee',
    'lib/after_explosion.html',
    'lib/after_explosion.coffee',
    'lib/footer.html',
    'lib/jquery.jrumble.1.3.min.js'
  ], 'client');

  // Images
  api.addAssets([
    'assets/img/blast-mark.png',
    'assets/img/sight.png',
    'assets/img/skull.png',
    'assets/img/target.png',
    'assets/img/weapons/blaster.png',
    'assets/img/weapons/cannon.jpg',
    'assets/img/weapons/death-star.jpg',
    'assets/img/weapons/Ship.jpeg',
    'assets/img/DeathStar.png',
    'assets/img/VaderFail.gif',
    'assets/img/Logo.jpg',
    'assets/img/ion2.png',
     'assets/img/starwars-logo.png'
  ], 'client');

  // Audio
  api.addAssets([
    'assets/audio/cannon1.wav',
    'assets/audio/cannon2.wav',
    'assets/audio/imperial.wav',
    'assets/audio/trprsht1.wav',
    'assets/audio/trprsht2.wav'
  ], 'client');

});
