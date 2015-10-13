# requestAnimationFrameFix
window.requestAnimFrame = do ->
    return  window.requestAnimationFrame   ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame    ||
        window.oRequestAnimationFrame      ||
        window.msRequestAnimationFrame     ||
        (callback) ->
            window.setTimeout callback, 1000 / 60

$ ->
    # image(base)
    canvas = document.querySelector("#image-base-container")
    ctx = canvas.getContext('2d')
    ctx.strokeStyle = '#f00'
    ctx.fillStyle = 'rgba(0,255,0,0.2)'

    # image(buffer)
    canvas_buf = document.querySelector("#image-buf-container")
    ctx_buf = canvas_buf.getContext('2d')
    ctx_buf.strokeStyle = '#f00'
    ctx_buf.fillStyle = 'rgba(255,0,0,0.2)'

    canvas_buf2 = document.querySelector("#image-buf2-container")
    ctx_buf2 = canvas_buf2.getContext('2d')
    ctx_buf2.strokeStyle = '#f00'
    ctx_buf2.fillStyle = 'rgba(0,0,255,0.2)'

    #point2d
    class Point2d
        constructor: (@x,@y) ->

    topLeftPt     = new Point2d(0,0) 
    topRightPt    = new Point2d(720,0) 
    bottomLeftPt  = new Point2d(0,720) 
    bottomRightPt = new Point2d(720,720) 

    #preload
    imagesArray = [
        "1.png"
    ]
    imageDirectory = "../img/"
    imageObjects = []

    setLoadImages = (imagesArray) ->
        loadComp = 0
        for imageName, index in imagesArray
            imageObjects.push(new Image())
            imageObjects[index].src = imageDirectory + imageName;
            imageObjects[index].onload = () ->
                loadComp++
                #先読み画像をすべて読み込み終わった時
                if loadComp is imagesArray.length
                    console.log("comp!")
                    ctx.drawImage(imageObjects[0],canvas.width/2-imageObjects[0].width/4,canvas.height/2-imageObjects[0].height/4,imageObjects[0].width/2,imageObjects[0].height/2)

    setLoadImages(imagesArray)

    #二つの直線(ab,cd)の交点を求める
    # 点a(x1,y1),点b(x2,y2)
    # 点abを通る直線をy=p*x+qとすると、 
    # y1=p*x1+q,y2=p*x2+q
    # y1-y2=p*x1-p*x2
    # p = (y1-y2)/(x1-x2)
    # q = y1-p*x1
    # 点dcを通る直線をy=r*x+sとすると、 
    # y3=r*x3+s,y4=r*x4+s
    # y3-y4=r*x3-r*x4
    # r = (y3-y4)/(x3-x4)
    # s = y3-r*x3

    # 交点をxx,yyとすると
    # yy = p*xx + q
    # yy = r*xx + s
    # =>
    # xx = (s - q)/(p - r)
    # yy = p*xx + q

    # getIntersectionPoint = (a,b,c,d) ->
    #     # 場合分けが大変なので却下
    #     # p = (a.y-b.y)/(a.x-b.x)
    #     # q = a.y-p*a.x
        
    #     # r = (c.y-d.y)/(c.x-d.x)
    #     # s = c.y-r*c.x

    #     # xx = (s - q)/(p - r)
    #     # yy = p*xx + q

    #     ax = b.x - a.x
    #     ay = b.y - a.y
    #     bx = d.x - c.x
    #     by = d.y - c.y
    #     cx = c.x - a.x
    #     cy = c.y - a.y
        
    #     cross1 = bx * cy - by * cx;
    #     cross2 = bx * ay - by * ax;
        
    #     if (!cross2) return null
        
    #     t = cross1 / cross2;

    #     return new Point2d a.x + ax * t, y: a.y + ay * t

    # #　直線で交差するか
    # isIntersection = (p1, p2, p3, p4) ->
    #     p = getIntersectionPoint(p1, p2, p3, p4);
    #     return p and (p.x - p3.x) * (p.x - p4.x) + (p.y - p3.y) * (p.y - p4.y) < 0 and (p.x - p1.x) * (p.x - p2.x) + (p.y - p1.y) * (p.y - p2.y) < 0

    #canvasを分割する直線を引く
    #参考->http://jsdo.it/akm2/5sUs
    getCanvasDividePoint = (p1,p2,cw,ch) ->
        a = p2.y - p1.y;
        b = p2.x - p1.x;
        c = p2.x * p1.y - p1.x * p2.y
        
        x1 = 0
        y1 = 0
        x2 = 0
        y2 = 0

        if a is 0 and b is 0
            x1 = x2 = p2.x
            y1 = y2 = p2.y
        else if b is 0
            y1 = 0
            y2 = ch
            x1 = (y1 * b - c) / a
            x2 = (y2 * b - c) / a
        else
            x1 = 0
            x2 = cw
            y1 = (a * x1 + c) / b
            y2 = (a * x2 + c) / b

        devidePoint = []
        devidePoint.push(new Point2d(x1, y1))
        devidePoint.push(new Point2d(x2, y2))

        return devidePoint

    setSubPath = (p1,p2,p3,p4,ctx) ->
        ctx.beginPath();
        ctx.moveTo(p1.x, p1.y)
        ctx.lineTo(p2.x, p2.y)
        ctx.lineTo(p3.x, p3.y)
        ctx.lineTo(p4.x, p4.y)
        ctx.closePath()

    slashImage = (devidePoint,scale,ctx,image) ->
        # 傾きから角度を求め、ずらしの距離が一定になるようにする
        if((devidePoint[1].x - devidePoint[0].x) is 0)
            slope = null
            angle = 90
        else
            slope = (devidePoint[1].y - devidePoint[0].y)/(devidePoint[1].x - devidePoint[0].x)
            angle = Math.atan(slope)

        # 画像がぼけてしまうので、整数にする
        x = Math.floor(scale * Math.cos(angle))
        y = Math.floor(scale * Math.sin(angle))

        ctx.drawImage(image, x, y)

    getSlashStroke = (startPoint,endPoint) ->
        distanceX = (endPoint.x - startPoint.x)
        distanceY = (endPoint.y - startPoint.y)

        return Math.sqrt(distanceX*distanceX + distanceY*distanceY) / 10

    #mouseEvent
    startPoint = null
    endPoint   = null
    mouseOut      = false

    getMousePosOnCanvas = (e) ->
        rect    = e.target.getBoundingClientRect();
        canvasX = e.clientX - rect.left
        canvasY = e.clientY - rect.top
        return new Point2d canvasX, canvasY
    
    canvas_buf2.addEventListener 'mousedown', (e) ->
        mouseOut = false
        endPoint = null
        startPoint = getMousePosOnCanvas(e)
    canvas_buf2.addEventListener 'mousemove', (e) ->
        # mousedownが起こるまでは、入ってきたところを開始点とする
        if mouseOut
            mouseOut = false
            endPoint = null
            startPoint = getMousePosOnCanvas(e)
    canvas_buf2.addEventListener 'mouseup', (e) ->
        mouseOut = false
        endPoint = getMousePosOnCanvas(e)
    canvas_buf2.addEventListener 'mouseout', (e) ->
        # mouseup時に暴発する時があるようなので、returnする
        if endPoint
            return
        mouseOut = true
        # mousedownして、canvas内でmouseupしなかった場合、外れた地点を終点とする
        if startPoint
            endPoint = getMousePosOnCanvas(e)

    loopAnim = () ->
        requestAnimFrame (loopAnim)
        if startPoint and endPoint
            if ((startPoint.x - endPoint.x)<-100 or (startPoint.x - endPoint.x)>100) or ((startPoint.y - endPoint.y)<-100 or (startPoint.y - endPoint.y)>100)
                canvasDevPt = getCanvasDividePoint(startPoint, endPoint, 720, 720, ctx_buf2)
                
                slashStroke = getSlashStroke(startPoint, endPoint)
                # 傾きを割り出す
                # if((canvasDevPt[1].x - canvasDevPt[0].x) is 0)
                #     devideSlope = null
                # else
                #     devideSlope = (canvasDevPt[1].y - canvasDevPt[0].y)/(canvasDevPt[1].x - canvasDevPt[0].x)

                devideChange = Math.floor(Math.random() * 2) + 1
                # サブパスの状態を初回時で固定する
                ctx_buf2.restore()
                ctx_buf2.save()
                ctx_buf.restore()
                ctx_buf.save()
                # 赤い線を消す
                ctx_buf2.clearRect(0, 0, canvas.width, canvas.height)

                # ctx_buf2.drawImage(canvas,0,0)

                if canvasDevPt[0].x is 0
                    #上下でカットする
                    setSubPath(canvasDevPt[0],canvasDevPt[1],topRightPt,topLeftPt,ctx_buf)
                    setSubPath(canvasDevPt[0],canvasDevPt[1],bottomRightPt,bottomLeftPt,ctx_buf2)
                else
                    #左右でカットする
                    setSubPath(canvasDevPt[0],canvasDevPt[1],bottomLeftPt,topLeftPt,ctx_buf)
                    setSubPath(canvasDevPt[0],canvasDevPt[1],bottomRightPt,topRightPt,ctx_buf2)

                ctx_buf2.clip()
                # ctx_buf2.fill()
                ctx_buf.clip()
                # ctx_buf.fill()
                
                slashImage(canvasDevPt,slashStroke,ctx_buf,canvas)
                slashImage(canvasDevPt,-1*slashStroke,ctx_buf2,canvas)

                # 下地に統合する
                ctx.clearRect(0, 0, canvas.width, canvas.height)
                ctx.drawImage(canvas_buf,0,0)
                ctx.drawImage(canvas_buf2,0,0)
                ctx_buf2.clearRect(0, 0, canvas.width, canvas.height)
                ctx_buf.clearRect(0, 0, canvas.width, canvas.height)

                # 赤い線を引く
                ctx_buf2.beginPath();
                ctx_buf2.moveTo(canvasDevPt[0].x, canvasDevPt[0].y)
                ctx_buf2.lineTo(canvasDevPt[1].x, canvasDevPt[1].y)
                ctx_buf2.stroke()

            startPoint = null
            endPoint   = null

    loopAnim()

    #windowHeightAdjust
    adjust = ->
        w = $(window).width()
        h = $(window).height()
        $('article').css({'height': h,'width': w})
        # contextが変更されてしまうのでしない
        # $('canvas').attr('width',w).attr('height', h)
        ctx_buf2.restore()
        ctx.restore()
        console.log("restore")
    adjust()
    $(window).on 'resize', () ->
        adjust()