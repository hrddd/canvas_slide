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
    canvas = document.querySelector('#image-container')
    ctx = canvas.getContext('2d')

    # buffer(effect)
    canvas_buf = document.querySelector('#effect-container')
    ctx_buf = canvas_buf.getContext('2d')

    #preload
    imagesArray = [
        '1.png'
    ]
    imageDirectory = '../img/'
    imageObjects = []

    setLoadImages = (imagesArray) ->
        loadComp = 0
        for imageName, index in imagesArray
            imageObjects.push(new Image())
            imageObjects[index].src = imageDirectory + imageName;
            imageObjects[index].onload = () ->
                loadComp++
                if loadComp is imagesArray.length
                    console.log('comp!')
                    ctx.drawImage(imageObjects[0],0,0)

    setLoadImages(imagesArray)

    # particle
    class Particle
        constructor: (@scale, @color, @speed,@position = x : 100, y : 100) ->
        draw: (_ctx) ->
            _ctx.beginPath()
            _ctx.arc(@position.x, @position.y, @scale, 0, 2*Math.PI, false)
            _ctx.fillStyle = @color
            _ctx.fill()

    # particles    
    density = 100  # パーティクルの密度
    particles = [] # パーティクルをまとめる配列
    
    for i in [0..density]
        particles[i] = new Particle(6, '#D0A000', Math.random()*(4-2)+2)
        particles[i].position.x = Math.random()*canvas.width
        particles[i].position.y = Math.random()*canvas.height
        particles[i].draw(ctx_buf)

    loopAnim = () ->
        requestAnimFrame (loopAnim)
        ctx_buf.clearRect(0, 0, canvas.width, canvas.height)
        for particle in particles
            particle.position.y += particle.speed
            particle.draw(ctx_buf)
            if particle.position.y > canvas.height
                particle.position.y = -30;

    #windowHeightAdjust
    adjust = ->
        h = $(window).width()/2
        $('#slide-image').css('height', h)
    adjust()
    $(window).on 'resize', () ->
        adjust()

    #slide
    $('#start-button').on 'click', ->
        loopAnim()
        console.log('aaa')
    #loopAnim()