window.requestAnimFrame = (function() {
  return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
    return window.setTimeout(callback, 1000 / 60);
  };
})();

$(function() {
  var Particle, adjust, canvas, canvas_buf, ctx, ctx_buf, density, i, imageDirectory, imageObjects, imagesArray, j, loopAnim, particles, ref, setLoadImages;
  canvas = document.querySelector('#image-container');
  ctx = canvas.getContext('2d');
  canvas_buf = document.querySelector('#effect-container');
  ctx_buf = canvas_buf.getContext('2d');
  imagesArray = ['1.png'];
  imageDirectory = '../img/';
  imageObjects = [];
  setLoadImages = function(imagesArray) {
    var imageName, index, j, len, loadComp, results;
    loadComp = 0;
    results = [];
    for (index = j = 0, len = imagesArray.length; j < len; index = ++j) {
      imageName = imagesArray[index];
      imageObjects.push(new Image());
      imageObjects[index].src = imageDirectory + imageName;
      results.push(imageObjects[index].onload = function() {
        loadComp++;
        if (loadComp === imagesArray.length) {
          console.log('comp!');
          return ctx.drawImage(imageObjects[0], 0, 0);
        }
      });
    }
    return results;
  };
  setLoadImages(imagesArray);
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
    particles[i].draw(ctx_buf);
  }
  loopAnim = function() {
    var k, len, particle, results;
    requestAnimFrame(loopAnim);
    ctx_buf.clearRect(0, 0, canvas.width, canvas.height);
    results = [];
    for (k = 0, len = particles.length; k < len; k++) {
      particle = particles[k];
      particle.position.y += particle.speed;
      particle.draw(ctx_buf);
      if (particle.position.y > canvas.height) {
        results.push(particle.position.y = -30);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };
  adjust = function() {
    var h;
    h = $(window).width() / 2;
    return $('#slide-image').css('height', h);
  };
  adjust();
  $(window).on('resize', function() {
    return adjust();
  });
  return $('#start-button').on('click', function() {
    loopAnim();
    return console.log('aaa');
  });
});
