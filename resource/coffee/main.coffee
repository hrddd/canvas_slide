window.requestAnimFrame = do ->
    return  window.requestAnimationFrame   ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame    ||
        window.oRequestAnimationFrame      ||
        window.msRequestAnimationFrame     ||
        (callback) ->
            window.setTimeout callback, 1000 / 60

$ ->
    # property
    canvas = document.querySelector('#slide-container');
    ctx = canvas.getContext('2d');

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
        particles[i].draw(ctx)

    loopAnim = ->
        requestAnimFrame (loopAnim)
        ctx.clearRect(0, 0, canvas.width, canvas.height)
        for particle in particles
            particle.position.y += particle.speed
            particle.draw(ctx)
            if particle.position.y > canvas.height
                particle.position.y = -30;

    # 実行
    loopAnim()