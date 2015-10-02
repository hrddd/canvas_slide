window.requestAnimFrame = (function() {
  return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
    return window.setTimeout(callback, 1000 / 60);
  };
})();

$(function() {
  var Particle, canvas, ctx, density, i, j, loopAnim, particles, ref;
  canvas = document.querySelector('#slide-container');
  ctx = canvas.getContext('2d');
  Particle = (function() {
    function Particle(scale, color, speed, position) {
      this.scale = scale;
      this.color = color;
      this.speed = speed;
      this.position = position != null ? position : {
        x: 100,
        y: 100
      };
    }

    Particle.prototype.draw = function(_ctx) {
      _ctx.beginPath();
      _ctx.arc(this.position.x, this.position.y, this.scale, 0, 2 * Math.PI, false);
      _ctx.fillStyle = this.color;
      return _ctx.fill();
    };

    return Particle;

  })();
  density = 100;
  particles = [];
  for (i = j = 0, ref = density; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
    particles[i] = new Particle(6, '#D0A000', Math.random() * (4 - 2) + 2);
    particles[i].position.x = Math.random() * canvas.width;
    particles[i].position.y = Math.random() * canvas.height;
    particles[i].draw(ctx);
  }
  loopAnim = function() {
    var k, len, particle, results;
    requestAnimFrame(loopAnim);
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    results = [];
    for (k = 0, len = particles.length; k < len; k++) {
      particle = particles[k];
      particle.position.y += particle.speed;
      particle.draw(ctx);
      if (particle.position.y > canvas.height) {
        results.push(particle.position.y = -30);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };
  return loopAnim();
});
