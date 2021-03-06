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
    #canvas
    class Canvas
        constructor: (canvas) ->
            if document.getElementById(canvas)
                @canvas = document.getElementById(canvas)
            else
                @canvas = document.createElement('canvas')
                @canvas.setAttribute('id',canvas)
            @ctx             = @canvas.getContext('2d')
            @ctx.strokeStyle = '#f00'
            @ctx.lineWidth   = 2
            @ctx.fillStyle   = 'rgba(0,18,36,.2)'

    # image(base)
    cvsBackground = new Canvas("image-background")
    cvsBase       = new Canvas("image-base")
    cvsBuf        = new Canvas("image-buf")
    cvsBuf2       = new Canvas("image-buf2")

    cvsBaseWidth  = cvsBase.canvas.width
    cvsBaseHeight = cvsBase.canvas.height

    strokeLimitX  = cvsBaseWidth / 30
    strokeLimitY  = cvsBaseHeight / 30

    # 背景を作る
    setCirclePattern = (w,h,r,ctx) ->
        cvsPattern               = new Canvas("image-pattern")
        cvsPattern.canvas.width  = w
        cvsPattern.canvas.height = h

        cvsPattern.ctx.beginPath()
        cvsPattern.ctx.arc(w/2, h/2, r, 0, 360*Math.PI/180, true)
        cvsPattern.ctx.fill()

        pattern = ctx.createPattern(cvsPattern.canvas,'repeat')
        ctx.fillStyle = pattern
        ctx.fillRect(0, 0, cvsBaseWidth, cvsBaseHeight)

    patternWidth = Math.floor(cvsBaseWidth / 144)
    patternHeight = Math.floor(cvsBaseHeight / 144)

    setScaledGrayscale = (w,h,imgCanvas,canvas) ->
        cvsScale               = new Canvas("image-scale")
        cvsScale.canvas.width  = w
        cvsScale.canvas.height = h
        cvsScale.ctx.fillStyle = 'rgba(0,18,36,.2)'

        imgd = imgCanvas.ctx.getImageData(cvsBaseWidth/2 - w/2, cvsBaseHeight/2 - h/2, w, h)
        
        pix = imgd.data
        for i in [0..pix.length] by 4
            grayscale = pix[i  ] * .3 + pix[i+1] * .59 + pix[i+2] * .11
            pix[i  ]  = grayscale
            pix[i+1]  = grayscale
            pix[i+2]  = grayscale

        cvsScale.ctx.putImageData(imgd, 0, 0)
        cvsScale.ctx.fillRect(0, 0, w, h)
        canvas.ctx.drawImage(cvsScale.canvas, 0, 0, cvsBaseWidth, cvsBaseHeight)

    scaledWidth  = Math.floor(cvsBaseWidth/2)
    scaledHeight = Math.floor(cvsBaseHeight/2)

    setBackground = () ->
        setScaledGrayscale(scaledWidth, scaledHeight, cvsBase, cvsBackground)
        setCirclePattern(patternWidth, patternHeight, .5, cvsBackground.ctx)

    #point2d
    class Point2d
        constructor: (@x,@y) ->

    topLeftPt     = new Point2d(0, 0) 
    topRightPt    = new Point2d(cvsBaseWidth, 0) 
    bottomLeftPt  = new Point2d(0, cvsBaseHeight) 
    bottomRightPt = new Point2d(cvsBaseWidth, cvsBaseHeight) 

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
            imageObjects[index].src = imageDirectory + imageName
            imageObjects[index].onload = () ->
                loadComp++
                #先読み画像をすべて読み込み終わった時
                if loadComp is imagesArray.length
                    cvsBase.ctx.drawImage(imageObjects[0],cvsBaseWidth/2-imageObjects[0].width/4,cvsBaseHeight/2-imageObjects[0].height/4,imageObjects[0].width/2,imageObjects[0].height/2)

    #canvasを分割する直線を引く
    #参考->http://jsdo.it/akm2/5sUs
    getCanvasDividePoint = (p1,p2,cw,ch) ->
        a = p2.y - p1.y
        b = p2.x - p1.x
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
        ctx.beginPath()
        ctx.moveTo(p1.x, p1.y)
        ctx.lineTo(p2.x, p2.y)
        ctx.lineTo(p3.x, p3.y)
        ctx.lineTo(p4.x, p4.y)
        ctx.closePath()

    # ずらす
    # slashImage = (devidePoint,scale,ctx,image) ->
    #     # 傾きから角度を求め、ずらしの距離が一定になるようにする
    #     # 画像がぼけてしまうので、xyは整数にする
    #     if((devidePoint[1].x - devidePoint[0].x) is 0)
    #         slope = null
    #         angle = 90
    #         x     = 0
    #     else
    #         slope = (devidePoint[1].y - devidePoint[0].y)/(devidePoint[1].x - devidePoint[0].x)
    #         angle = Math.atan(slope)
    #         x     = Math.floor(scale * Math.cos(angle))

    #     y = Math.floor(scale * Math.sin(angle))

    #     ctx.drawImage(image, x, y)

    # # 2点間の距離を取る
    # # ストロークの大きさをずらしの大きさ(scale)に適用
    # getSlashStroke = (startPoint,endPoint) ->
    #     distanceX = (endPoint.x - startPoint.x)
    #     distanceY = (endPoint.y - startPoint.y)

    #     return Math.sqrt(distanceX * distanceX + distanceY * distanceY) / (cvsBaseWidth / 72) 

    # ベクトルからずらしを求める
    slashImage = (startPoint,endPoint,ctx,image,vector) ->
        x = Math.floor((endPoint.x - startPoint.x)*vector)
        y = Math.floor((endPoint.y - startPoint.y)*vector)

        ctx.drawImage(image, x, y)

    #mouseEvent
    startPoint = null
    endPoint   = null
    mouseOut   = false

    getMousePosOnCanvas = (e) ->
        rect    = e.target.getBoundingClientRect()
        canvasX = e.clientX - rect.left
        canvasY = e.clientY - rect.top
        return new Point2d(canvasX, canvasY)
    
    cvsBuf2.canvas.addEventListener 'mousedown', (e) ->
        mouseOut = false
        endPoint = null
        startPoint = getMousePosOnCanvas(e)
    cvsBuf2.canvas.addEventListener 'mousemove', (e) ->
        # mousedownが起こるまでは、入ってきたところを開始点とする
        if mouseOut
            mouseOut = false
            endPoint = null
            startPoint = getMousePosOnCanvas(e)
    cvsBuf2.canvas.addEventListener 'mouseup', (e) ->
        mouseOut = false
        endPoint = getMousePosOnCanvas(e)
    # PCブラウザタブ切り替え等で暴発するので外す
    # cvsBuf2.canvas.addEventListener 'mouseout', (e) ->
    #     # mouseup時に暴発する時があるようなので、returnする
    #     if endPoint
    #         return
    #     mouseOut = true
    #     # mousedownして、canvas内でmouseupしなかった場合、外れた地点を終点とする
    #     if startPoint
    #         endPoint = getMousePosOnCanvas(e)


    loopAnim = () ->
        requestAnimFrame (loopAnim)
        if startPoint and endPoint
            if (Math.abs(startPoint.x - endPoint.x) > strokeLimitX) or (Math.abs(startPoint.y - endPoint.y) > strokeLimitY)
                canvasDevPt = getCanvasDividePoint(startPoint, endPoint, cvsBaseWidth, cvsBaseHeight, cvsBuf2.canvas)
                
                # slashStroke = getSlashStroke(startPoint, endPoint)

                devideChange = Math.floor(Math.random() * 2) + 1

                # サブパスの状態を初回時で固定する
                cvsBuf2.ctx.restore()
                cvsBuf2.ctx.save()
                cvsBuf.ctx.restore()
                cvsBuf.ctx.save()
                # 赤い線を消す
                cvsBuf2.ctx.clearRect(0, 0, cvsBaseWidth, cvsBaseHeight)

                if canvasDevPt[0].x is 0
                    #上下でカットする
                    setSubPath(canvasDevPt[0],canvasDevPt[1],topRightPt,topLeftPt,cvsBuf.ctx)
                    setSubPath(canvasDevPt[0],canvasDevPt[1],bottomRightPt,bottomLeftPt,cvsBuf2.ctx)
                else
                    #左右でカットする
                    setSubPath(canvasDevPt[0],canvasDevPt[1],bottomLeftPt,topLeftPt,cvsBuf.ctx)
                    setSubPath(canvasDevPt[0],canvasDevPt[1],bottomRightPt,topRightPt,cvsBuf2.ctx)

                cvsBuf2.ctx.clip()
                cvsBuf.ctx.clip()
                
                # 形が一定になってしまうので、ランダムでずらしの方向を変える
                # if(devideChange == 1)
                #     slashImage(canvasDevPt,slashStroke,cvsBuf.ctx,cvsBase.canvas,.2)
                #     slashImage(canvasDevPt,-1*slashStroke,cvsBuf2.ctx,cvsBase.canvas,-.2)
                # else if(devideChange == 2)
                #     slashImage(canvasDevPt,-1*slashStroke,cvsBuf.ctx,cvsBase.canvas,-.2)
                #     slashImage(canvasDevPt,slashStroke,cvsBuf2.ctx,cvsBase.canvas,.2)

                # ベクトルでとるようにしたので、方向変換にも対応・・・
                slashImage(startPoint,endPoint,cvsBuf.ctx,cvsBase.canvas,.2)
                slashImage(startPoint,endPoint,cvsBuf2.ctx,cvsBase.canvas,-.2)

                # 下地に統合する
                cvsBase.ctx.clearRect(0, 0, cvsBaseWidth, cvsBaseHeight)
                cvsBase.ctx.drawImage(cvsBuf.canvas,0,0)
                cvsBase.ctx.drawImage(cvsBuf2.canvas,0,0)
                cvsBuf2.ctx.clearRect(0, 0, cvsBaseWidth, cvsBaseHeight)
                cvsBuf.ctx.clearRect(0, 0, cvsBaseWidth, cvsBaseHeight)

                # 背景を作る
                # cvsBackground.ctx.clearRect(0, 0, cvsBaseWidth, cvsBaseHeight)
                setBackground()

                # 赤い線を引く
                cvsBuf2.ctx.beginPath()
                cvsBuf2.ctx.moveTo(canvasDevPt[0].x, canvasDevPt[0].y)
                cvsBuf2.ctx.lineTo(canvasDevPt[1].x, canvasDevPt[1].y)
                cvsBuf2.ctx.stroke()

            startPoint = null
            endPoint   = null

    #windowHeightAdjust
    adjust = ->
        w = $(window).width()
        h = $(window).height()
        $('article').css({'width': w, 'height': h})
        # contextが変更されてしまうのでしない
        # $('canvas').attr('width',w).attr('height', h)

    initialize = ->
        setLoadImages(imagesArray)
        loopAnim()
        setBackground()
        adjust()
        $(window).on 'resize', () ->
            adjust()
    
    initialize()