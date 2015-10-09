window.requestAnimFrame = (function() {
  return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
    return window.setTimeout(callback, 1000 / 60);
  };
})();

$(function() {
  var Point2d, adjust, canvas, canvas_buf, ctx, ctx_buf, drawCanvasDivide, endPoint, getMousePosOnCanvas, imageDirectory, imageObjects, imagesArray, loopAnim, mouseOut, setLoadImages, startPoint;
  canvas = document.querySelector("#image-container");
  ctx = canvas.getContext('2d');
  canvas_buf = document.querySelector("#effect-container");
  ctx_buf = canvas_buf.getContext('2d');
  ctx_buf.strokeStyle = '#f00';
  Point2d = (function() {
    function Point2d(x, y) {
      this.x = x;
      this.y = y;
    }

    return Point2d;

  })();
  imagesArray = ["1.png"];
  imageDirectory = "../img/";
  imageObjects = [];
  setLoadImages = function(imagesArray) {
    var i, imageName, index, len, loadComp, results;
    loadComp = 0;
    results = [];
    for (index = i = 0, len = imagesArray.length; i < len; index = ++i) {
      imageName = imagesArray[index];
      imageObjects.push(new Image());
      imageObjects[index].src = imageDirectory + imageName;
      results.push(imageObjects[index].onload = function() {
        loadComp++;
        if (loadComp === imagesArray.length) {
          console.log("comp!");
          ctx.drawImage(imageObjects[0], canvas.width / 2 - imageObjects[0].width / 4, canvas.height / 2 - imageObjects[0].height / 4, imageObjects[0].width / 2, imageObjects[0].height / 2);
          return ctx.save();
        }
      });
    }
    return results;
  };
  setLoadImages(imagesArray);
  drawCanvasDivide = function(p1, p2, cw, ch, ctx) {
    var a, b, c, x1, x2, y1, y2;
    a = p2.y - p1.y;
    b = p2.x - p1.x;
    c = p2.x * p1.y - p1.x * p2.y;
    x1 = 0;
    y1 = 0;
    x2 = 0;
    y2 = 0;
    if (a === 0 && b === 0) {
      x1 = x2 = p2.x;
      y1 = y2 = p2.y;
    } else if (b === 0) {
      y1 = 0;
      y2 = ch;
      x1 = (y1 * b - c) / a;
      x2 = (y2 * b - c) / a;
    } else {
      x1 = 0;
      x2 = cw;
      y1 = (a * x1 + c) / b;
      y2 = (a * x2 + c) / b;
    }
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    return ctx.stroke();
  };
  startPoint = null;
  endPoint = null;
  mouseOut = false;
  getMousePosOnCanvas = function(e) {
    var canvasX, canvasY, rect;
    rect = e.target.getBoundingClientRect();
    canvasX = e.clientX - rect.left;
    canvasY = e.clientY - rect.top;
    return new Point2d(canvasX, canvasY);
  };
  canvas_buf.addEventListener('mousedown', function(e) {
    mouseOut = false;
    endPoint = null;
    return startPoint = getMousePosOnCanvas(e);
  });
  canvas_buf.addEventListener('mousemove', function(e) {
    if (mouseOut) {
      mouseOut = false;
      endPoint = null;
      return startPoint = getMousePosOnCanvas(e);
    }
  });
  canvas_buf.addEventListener('mouseup', function(e) {
    mouseOut = false;
    return endPoint = getMousePosOnCanvas(e);
  });
  canvas_buf.addEventListener('mouseout', function(e) {
    if (endPoint) {
      return;
    }
    mouseOut = true;
    if (startPoint) {
      return endPoint = getMousePosOnCanvas(e);
    }
  });
  loopAnim = function() {
    requestAnimFrame(loopAnim);
    if (startPoint && endPoint) {
      if (((startPoint.x - endPoint.x) < -100 || (startPoint.x - endPoint.x) > 100) || ((startPoint.y - endPoint.y) < -100 || (startPoint.y - endPoint.y) > 100)) {
        drawCanvasDivide(startPoint, endPoint, 720, 720, ctx_buf);
      }
      startPoint = null;
      return endPoint = null;
    }
  };
  loopAnim();
  adjust = function() {
    var h, w;
    w = $(window).width();
    h = $(window).height();
    $('article').css({
      'height': h,
      'width': w
    });
    ctx_buf.restore();
    ctx.restore();
    return console.log("restore");
  };
  adjust();
  return $(window).on('resize', function() {
    return adjust();
  });
});
