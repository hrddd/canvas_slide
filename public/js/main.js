window.requestAnimFrame = (function() {
  return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
    return window.setTimeout(callback, 1000 / 60);
  };
})();

$(function() {
  var Point2d, adjust, bottomLeftPt, bottomRightPt, canvas, canvas_buf, canvas_buf2, ctx, ctx_buf, ctx_buf2, endPoint, getCanvasDividePoint, getMousePosOnCanvas, getSlashStroke, imageDirectory, imageObjects, imagesArray, loopAnim, mouseOut, setLoadImages, setSubPath, slashImage, startPoint, topLeftPt, topRightPt;
  canvas = document.querySelector("#image-base-container");
  ctx = canvas.getContext('2d');
  ctx.strokeStyle = '#f00';
  ctx.fillStyle = 'rgba(0,255,0,0.2)';
  canvas_buf = document.querySelector("#image-buf-container");
  ctx_buf = canvas_buf.getContext('2d');
  ctx_buf.strokeStyle = '#f00';
  ctx_buf.fillStyle = 'rgba(255,0,0,0.2)';
  canvas_buf2 = document.querySelector("#image-buf2-container");
  ctx_buf2 = canvas_buf2.getContext('2d');
  ctx_buf2.strokeStyle = '#f00';
  ctx_buf2.fillStyle = 'rgba(0,0,255,0.2)';
  Point2d = (function() {
    function Point2d(x3, y3) {
      this.x = x3;
      this.y = y3;
    }

    return Point2d;

  })();
  topLeftPt = new Point2d(0, 0);
  topRightPt = new Point2d(720, 0);
  bottomLeftPt = new Point2d(0, 720);
  bottomRightPt = new Point2d(720, 720);
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
          return ctx.drawImage(imageObjects[0], canvas.width / 2 - imageObjects[0].width / 4, canvas.height / 2 - imageObjects[0].height / 4, imageObjects[0].width / 2, imageObjects[0].height / 2);
        }
      });
    }
    return results;
  };
  setLoadImages(imagesArray);
  getCanvasDividePoint = function(p1, p2, cw, ch) {
    var a, b, c, devidePoint, x1, x2, y1, y2;
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
    devidePoint = [];
    devidePoint.push(new Point2d(x1, y1));
    devidePoint.push(new Point2d(x2, y2));
    return devidePoint;
  };
  setSubPath = function(p1, p2, p3, p4, ctx) {
    ctx.beginPath();
    ctx.moveTo(p1.x, p1.y);
    ctx.lineTo(p2.x, p2.y);
    ctx.lineTo(p3.x, p3.y);
    ctx.lineTo(p4.x, p4.y);
    return ctx.closePath();
  };
  slashImage = function(devidePoint, scale, ctx, image) {
    var angle, slope, x, y;
    if ((devidePoint[1].x - devidePoint[0].x) === 0) {
      slope = null;
      angle = 90;
    } else {
      slope = (devidePoint[1].y - devidePoint[0].y) / (devidePoint[1].x - devidePoint[0].x);
      angle = Math.atan(slope);
    }
    x = Math.floor(scale * Math.cos(angle));
    y = Math.floor(scale * Math.sin(angle));
    return ctx.drawImage(image, x, y);
  };
  getSlashStroke = function(startPoint, endPoint) {
    var distanceX, distanceY;
    distanceX = endPoint.x - startPoint.x;
    distanceY = endPoint.y - startPoint.y;
    return Math.sqrt(distanceX * distanceX + distanceY * distanceY) / 10;
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
  canvas_buf2.addEventListener('mousedown', function(e) {
    mouseOut = false;
    endPoint = null;
    return startPoint = getMousePosOnCanvas(e);
  });
  canvas_buf2.addEventListener('mousemove', function(e) {
    if (mouseOut) {
      mouseOut = false;
      endPoint = null;
      return startPoint = getMousePosOnCanvas(e);
    }
  });
  canvas_buf2.addEventListener('mouseup', function(e) {
    mouseOut = false;
    return endPoint = getMousePosOnCanvas(e);
  });
  canvas_buf2.addEventListener('mouseout', function(e) {
    if (endPoint) {
      return;
    }
    mouseOut = true;
    if (startPoint) {
      return endPoint = getMousePosOnCanvas(e);
    }
  });
  loopAnim = function() {
    var canvasDevPt, devideChange, slashStroke;
    requestAnimFrame(loopAnim);
    if (startPoint && endPoint) {
      if ((Math.abs(startPoint.x - endPoint.x) > 72) || (Math.abs(startPoint.y - endPoint.y) > 72)) {
        canvasDevPt = getCanvasDividePoint(startPoint, endPoint, 720, 720, ctx_buf2);
        slashStroke = getSlashStroke(startPoint, endPoint);
        devideChange = Math.floor(Math.random() * 2) + 1;
        ctx_buf2.restore();
        ctx_buf2.save();
        ctx_buf.restore();
        ctx_buf.save();
        ctx_buf2.clearRect(0, 0, canvas.width, canvas.height);
        if (canvasDevPt[0].x === 0) {
          setSubPath(canvasDevPt[0], canvasDevPt[1], topRightPt, topLeftPt, ctx_buf);
          setSubPath(canvasDevPt[0], canvasDevPt[1], bottomRightPt, bottomLeftPt, ctx_buf2);
        } else {
          setSubPath(canvasDevPt[0], canvasDevPt[1], bottomLeftPt, topLeftPt, ctx_buf);
          setSubPath(canvasDevPt[0], canvasDevPt[1], bottomRightPt, topRightPt, ctx_buf2);
        }
        ctx_buf2.clip();
        ctx_buf.clip();
        if (devideChange === 1) {
          slashImage(canvasDevPt, slashStroke, ctx_buf, canvas);
          slashImage(canvasDevPt, -1 * slashStroke, ctx_buf2, canvas);
        } else if (devideChange === 2) {
          slashImage(canvasDevPt, -1 * slashStroke, ctx_buf, canvas);
          slashImage(canvasDevPt, slashStroke, ctx_buf2, canvas);
        }
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(canvas_buf, 0, 0);
        ctx.drawImage(canvas_buf2, 0, 0);
        ctx_buf2.clearRect(0, 0, canvas.width, canvas.height);
        ctx_buf.clearRect(0, 0, canvas.width, canvas.height);
        ctx_buf2.beginPath();
        ctx_buf2.moveTo(canvasDevPt[0].x, canvasDevPt[0].y);
        ctx_buf2.lineTo(canvasDevPt[1].x, canvasDevPt[1].y);
        ctx_buf2.stroke();
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
    return $('article').css({
      'height': h,
      'width': w
    });
  };
  adjust();
  return $(window).on('resize', function() {
    return adjust();
  });
});
