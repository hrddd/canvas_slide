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
    # main(img)
    canvas = document.querySelector("#image-container")
    ctx = canvas.getContext('2d')

    # buffer(effect)
    canvas_buf = document.querySelector("#effect-container")
    ctx_buf = canvas_buf.getContext('2d')
    ctx_buf.strokeStyle = '#f00'

    #point2d
    class Point2d
        constructor: (@x,@y) ->

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
                    ctx.save()

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
    drawCanvasDivide = (p1,p2,cw,ch,ctx) ->
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
        ctx.moveTo(x1, y1)
        ctx.lineTo(x2, y2)
        ctx.stroke()
        

    #mouseEvent
    startPoint = null
    endPoint   = null
    mouseOut      = false

    getMousePosOnCanvas = (e) ->
        rect    = e.target.getBoundingClientRect();
        canvasX = e.clientX - rect.left
        canvasY = e.clientY - rect.top
        return new Point2d canvasX, canvasY
    
    canvas_buf.addEventListener 'mousedown', (e) ->
        mouseOut = false
        endPoint = null
        startPoint = getMousePosOnCanvas(e)
    canvas_buf.addEventListener 'mousemove', (e) ->
        # mousedownが起こるまでは、入ってきたところを開始点とする
        if mouseOut
            mouseOut = false
            endPoint = null
            startPoint = getMousePosOnCanvas(e)
    canvas_buf.addEventListener 'mouseup', (e) ->
        mouseOut = false
        endPoint = getMousePosOnCanvas(e)
    canvas_buf.addEventListener 'mouseout', (e) ->
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
                drawCanvasDivide(startPoint, endPoint, 720, 720, ctx_buf)
            startPoint = null
            endPoint   = null
        # ctx_buf.clearRect(0, 0, canvas.width, canvas.height)
        # for particle in particles
        #     particle.position.y += particle.speed
        #     particle.draw(ctx_buf)
        #     if particle.position.y > canvas.height
        #         particle.position.y = -30;

    loopAnim()

    #windowHeightAdjust
    adjust = ->
        w = $(window).width()
        h = $(window).height()
        $('article').css({'height': h,'width': w})
        # contextが変更されてしまうのでしない
        # $('canvas').attr('width',w).attr('height', h)
        ctx_buf.restore()
        ctx.restore()
        console.log("restore")
    adjust()
    $(window).on 'resize', () ->
        adjust()