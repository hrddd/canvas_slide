window.requestAnimFrame = (function() {
  return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
    return window.setTimeout(callback, 1000 / 60);
  };
})();

$(function() {
  var Canvas, Point2d, adjust, bottomLeftPt, bottomRightPt, cvsBackground, cvsBase, cvsBaseHeight, cvsBaseWidth, cvsBuf, cvsBuf2, endPoint, getCanvasDividePoint, getMousePosOnCanvas, imageDirectory, imageObjects, imagesArray, initialize, loopAnim, mouseOut, patternHeight, patternWidth, scaledHeight, scaledWidth, setBackground, setCirclePattern, setLoadImages, setScaledGrayscale, setSubPath, slashImage, startPoint, strokeLimitX, strokeLimitY, topLeftPt, topRightPt;
  Canvas = (function() {
    function Canvas(canvas) {
      if (document.getElementById(canvas)) {
        this.canvas = document.getElementById(canvas);
      } else {
        this.canvas = document.createElement('canvas');
        this.canvas.setAttribute('id', canvas);
      }
      this.ctx = this.canvas.getContext('2d');
      this.ctx.strokeStyle = '#f00';
      this.ctx.lineWidth = 2;
      this.ctx.fillStyle = 'rgba(0,18,36,.2)';
    }

    return Canvas;

  })();
  cvsBackground = new Canvas("image-background");
  cvsBase = new Canvas("image-base");
  cvsBuf = new Canvas("image-buf");
  cvsBuf2 = new Canvas("image-buf2");
  cvsBaseWidth = cvsBase.canvas.width;
  cvsBaseHeight = cvsBase.canvas.height;
  strokeLimitX = cvsBaseWidth / 30;
  strokeLimitY = cvsBaseHeight / 30;
  setCirclePattern = function(w, h, r, ctx) {
    var cvsPattern, pattern;
    cvsPattern = new Canvas("image-pattern");
    cvsPattern.canvas.width = w;
    cvsPattern.canvas.height = h;
    cvsPattern.ctx.beginPath();
    cvsPattern.ctx.arc(w / 2, h / 2, r, 0, 360 * Math.PI / 180, true);
    cvsPattern.ctx.fill();
    pattern = ctx.createPattern(cvsPattern.canvas, 'repeat');
    ctx.fillStyle = pattern;
    return ctx.fillRect(0, 0, cvsBaseWidth, cvsBaseHeight);
  };
  patternWidth = Math.floor(cvsBaseWidth / 144);
  patternHeight = Math.floor(cvsBaseHeight / 144);
  setScaledGrayscale = function(w, h, imgCanvas, canvas) {
    var cvsScale, grayscale, i, imgd, j, pix, ref;
    cvsScale = new Canvas("image-scale");
    cvsScale.canvas.width = w;
    cvsScale.canvas.height = h;
    cvsScale.ctx.fillStyle = 'rgba(0,18,36,.2)';
    imgd = imgCanvas.ctx.getImageData(cvsBaseWidth / 2 - w / 2, cvsBaseHeight / 2 - h / 2, w, h);
    pix = imgd.data;
    for (i = j = 0, ref = pix.length; j <= ref; i = j += 4) {
      grayscale = pix[i] * .3 + pix[i + 1] * .59 + pix[i + 2] * .11;
      pix[i] = grayscale;
      pix[i + 1] = grayscale;
      pix[i + 2] = grayscale;
    }
    cvsScale.ctx.putImageData(imgd, 0, 0);
    cvsScale.ctx.fillRect(0, 0, w, h);
    return canvas.ctx.drawImage(cvsScale.canvas, 0, 0, cvsBaseWidth, cvsBaseHeight);
  };
  scaledWidth = Math.floor(cvsBaseWidth / 2);
  scaledHeight = Math.floor(cvsBaseHeight / 2);
  setBackground = function() {
    setScaledGrayscale(scaledWidth, scaledHeight, cvsBase, cvsBackground);
    return setCirclePattern(patternWidth, patternHeight, .5, cvsBackground.ctx);
  };
  Point2d = (function() {
    function Point2d(x3, y3) {
      this.x = x3;
      this.y = y3;
    }

    return Point2d;

  })();
  topLeftPt = new Point2d(0, 0);
  topRightPt = new Point2d(cvsBaseWidth, 0);
  bottomLeftPt = new Point2d(0, cvsBaseHeight);
  bottomRightPt = new Point2d(cvsBaseWidth, cvsBaseHeight);
  imagesArray = ["1.png"];
  imageDirectory = "../img/";
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
          return cvsBase.ctx.drawImage(imageObjects[0], cvsBaseWidth / 2 - imageObjects[0].width / 4, cvsBaseHeight / 2 - imageObjects[0].height / 4, imageObjects[0].width / 2, imageObjects[0].height / 2);
        }
      });
    }
    return results;
  };
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
  slashImage = function(startPoint, endPoint, ctx, image, vector) {
    var x, y;
    x = Math.floor((endPoint.x - startPoint.x) * vector);
    y = Math.floor((endPoint.y - startPoint.y) * vector);
    return ctx.drawImage(image, x, y);
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
  cvsBuf2.canvas.addEventListener('mousedown', function(e) {
    mouseOut = false;
    endPoint = null;
    return startPoint = getMousePosOnCanvas(e);
  });
  cvsBuf2.canvas.addEventListener('mousemove', function(e) {
    if (mouseOut) {
      mouseOut = false;
      endPoint = null;
      return startPoint = getMousePosOnCanvas(e);
    }
  });
  cvsBuf2.canvas.addEventListener('mouseup', function(e) {
    mouseOut = false;
    return endPoint = getMousePosOnCanvas(e);
  });
  loopAnim = function() {
    var canvasDevPt, devideChange;
    requestAnimFrame(loopAnim);
    if (startPoint && endPoint) {
      if ((Math.abs(startPoint.x - endPoint.x) > strokeLimitX) || (Math.abs(startPoint.y - endPoint.y) > strokeLimitY)) {
        canvasDevPt = getCanvasDividePoint(startPoint, endPoint, cvsBaseWidth, cvsBaseHeight, cvsBuf2.canvas);
        devideChange = Math.floor(Math.random() * 2) + 1;
        cvsBuf2.ctx.restore();
        cvsBuf2.ctx.save();
        cvsBuf.ctx.restore();
        cvsBuf.ctx.save();
        cvsBuf2.ctx.clearRect(0, 0, cvsBaseWidth, cvsBaseHeight);
        if (canvasDevPt[0].x === 0) {
          setSubPath(canvasDevPt[0], canvasDevPt[1], topRightPt, topLeftPt, cvsBuf.ctx);
          setSubPath(canvasDevPt[0], canvasDevPt[1], bottomRightPt, bottomLeftPt, cvsBuf2.ctx);
        } else {
          setSubPath(canvasDevPt[0], canvasDevPt[1], bottomLeftPt, topLeftPt, cvsBuf.ctx);
          setSubPath(canvasDevPt[0], canvasDevPt[1], bottomRightPt, topRightPt, cvsBuf2.ctx);
        }
        cvsBuf2.ctx.clip();
        cvsBuf.ctx.clip();
        slashImage(startPoint, endPoint, cvsBuf.ctx, cvsBase.canvas, .2);
        slashImage(startPoint, endPoint, cvsBuf2.ctx, cvsBase.canvas, -.2);
        cvsBase.ctx.clearRect(0, 0, cvsBaseWidth, cvsBaseHeight);
        cvsBase.ctx.drawImage(cvsBuf.canvas, 0, 0);
        cvsBase.ctx.drawImage(cvsBuf2.canvas, 0, 0);
        cvsBuf2.ctx.clearRect(0, 0, cvsBaseWidth, cvsBaseHeight);
        cvsBuf.ctx.clearRect(0, 0, cvsBaseWidth, cvsBaseHeight);
        setBackground();
        cvsBuf2.ctx.beginPath();
        cvsBuf2.ctx.moveTo(canvasDevPt[0].x, canvasDevPt[0].y);
        cvsBuf2.ctx.lineTo(canvasDevPt[1].x, canvasDevPt[1].y);
        cvsBuf2.ctx.stroke();
      }
      startPoint = null;
      return endPoint = null;
    }
  };
  adjust = function() {
    var h, w;
    w = $(window).width();
    h = $(window).height();
    return $('article').css({
      'width': w,
      'height': h
    });
  };
  initialize = function() {
    setLoadImages(imagesArray);
    loopAnim();
    setBackground();
    adjust();
    return $(window).on('resize', function() {
      return adjust();
    });
  };
  return initialize();
});
